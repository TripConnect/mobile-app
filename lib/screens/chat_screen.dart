import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_app/constants/common.dart';
import 'package:mobile_app/models/chat.dart';
import 'package:mobile_app/models/storage.dart';
import 'package:provider/provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const conversationSummaryQuery = r"""
  query Conversation($id: String!) {
    conversation(id: $id) {
      id
      name
      type
      members {
        id
        displayName
        avatar
      }
    }
  }
""";

const chatHistoryQuery = r"""
  query Conversation($id: String!, $messagePage: Int, $messageLimit: Int) {
    conversation(id: $id) {
      messages(messagePage: $messagePage, messageLimit: $messageLimit) {
        id
        messageContent
        fromUser {
          id
          avatar
          displayName
        }
        createdAt
      }
    }
  }
""";

class ChatMessageItem extends StatelessWidget {
  final ChatMessage message;
  const ChatMessageItem(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    var globalStorage = Provider.of<GlobalStorage>(context);
    bool isMine = message.sender.id == globalStorage.currentUser.id;

    return Row(
      mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 35,
          height: 35,
          child: isMine ? null : CircleAvatar(
            backgroundImage: NetworkImage(message.sender.avatar),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: isMine ? Colors.blueAccent : Colors.grey,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if(!isMine)
                Text(
                  message.sender.displayName,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)
                ),
              Text(message.content),
            ],
          ),
        )
      ],
    );
  }

}

class ChatScreen extends StatefulWidget {
  final String _conversationId;

  const ChatScreen(this._conversationId, {super.key});

  @override
  State<StatefulWidget> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  IO.Socket? _socket;
  List<ChatMessage> _messages = [];
  bool _isDuringChatMessagesFetching = false;
  bool _isReachOldestPage = false;
  bool _shouldShowScrollButton = false;
  int _currentChatHistoryPageNum = 1;
  final int pageSize = 100;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onMessageChange);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    super.dispose();
    _socket?.io.disconnect();
    _messageController.removeListener(_onMessageChange);
    _scrollController.removeListener(_onScroll);
    _messageController.dispose();
  }

  void _refreshConversation() {
    _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    setState(() {
      _messages = [];
      _currentChatHistoryPageNum = 1;
      _isReachOldestPage = false;
      _shouldShowScrollButton = false;
    });
  }

  void setupChatSocket(String accessToken) {
    _socket = IO.io(
      socketIOChatNameSpace,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': accessToken})
          .build(),
    );

    _socket?.on('message', (data) {
      print('Incoming message: $data');
      if(_scrollController.position.pixels == _scrollController.position.minScrollExtent) {
        print('realtime appear new message');
        _refreshConversation();
      } else {
        print('show scroll button then re-fetch when hit');
        setState(() {
          _shouldShowScrollButton = true;
        });
      }
    });
  }

  void _sendChatMessage(String conversationId, String content) {
    Map<String, String> payload = {
      'conversationId': conversationId,
      'content': content
    };
    if (_socket?.connected == true) {
      _socket?.emit('message', payload);
      print('sent: $payload');
    } else {
      print('Socket not connected, cannot send message.');
    }
    _refreshConversation();
  }

  void _onMessageChange() {
    // do something
    setState(() {});
  }

  void _onScroll() {
    if(_isReachOldestPage) return;
    if(_isDuringChatMessagesFetching) return;

    if(_scrollController.position.atEdge) {
      bool isTop = _scrollController.position.pixels == _scrollController.position.maxScrollExtent;
      if (isTop) {
        setState(() {
          _currentChatHistoryPageNum++;
        });
      }
    }
  }

  Future<List<ChatMessage>> _fetchMoreChatHistory(GraphQLClient gqlClient) async {
    if(_isDuringChatMessagesFetching) return [];

    _isDuringChatMessagesFetching = true;
    QueryResult result = await gqlClient.query(
      QueryOptions(
        document: gql(chatHistoryQuery),
        variables: {
          'id': widget._conversationId,
          'messagePage': _currentChatHistoryPageNum,
          'messageLimit': pageSize
        },
      ),
    );
    _isDuringChatMessagesFetching = false;
    List<ChatMessage> response = (result.data?["conversation"]["messages"] as List)
        .map((m) => ChatMessage.fromJson(m))
        .toList();
    if(response.isEmpty) _isReachOldestPage = true;
    return response;

    // await Future.delayed(const Duration(seconds: 2));
    // _isDuringChatMessagesFetching = false;
    // return List.generate(pageSize, (index) => ChatMessage(
    //   id: '',
    //   content: 'fake content page=$_currentChatHistoryPageNum index=$index',
    //   sender: defaultUser
    // ));
  }

  @override
  Widget build(BuildContext context) {
    var globalStorage = Provider.of<GlobalStorage>(context);

    if(_socket == null) {
      setupChatSocket(globalStorage.token!.accessToken);
    }

    return Scaffold(
      body: Query(
        options: QueryOptions(
          document: gql(conversationSummaryQuery),
          variables: {'id': widget._conversationId},
        ),
        builder: (QueryResult result, { VoidCallback? refetch, FetchMore? fetchMore }) {
          if (result.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (result.hasException) {
            return Center(child: Text(result.exception.toString()));
          }

          Conversation conversation = Conversation.fromJson(result.data?["conversation"]);

          String title = conversation.name.isNotEmpty ?
              conversation.name :
              conversation.members
                .where((m) => m.id != globalStorage.currentUser.id)
                .map((m) => m.displayName)
                .join(", ");
          String conversationAvatar = ConversationType.private == conversation.type ?
            conversation.members.firstWhere((m) => m.id != globalStorage.currentUser.id).avatar:
            globalStorage.currentUser.avatar;

          return Padding(
            padding: const EdgeInsets.all(paddingMedium),
            child: Column(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        flex: 1,
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(conversationAvatar),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Flexible(
                        flex: 5,
                        child: Text(
                          title,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 25)
                        )
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      FutureBuilder<List<ChatMessage>>(
                        future: _fetchMoreChatHistory(globalStorage.gqlClient.value),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            if(_messages.isEmpty) {
                              return Center(
                                child: LoadingAnimationWidget.twistingDots(
                                  leftDotColor: const Color(0xFF1A1A3F),
                                  rightDotColor: const Color(0xFFEA3799),
                                  size: 50,
                                ),
                              );
                            }
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          }
                          _messages.addAll(snapshot.data!);
                          return ListView(
                            reverse: true,
                            controller: _scrollController,
                            children: _messages.map((m) => ChatMessageItem(m, key: Key(m.id))).toList()
                          );
                        }
                      ),
                      if(_shouldShowScrollButton) GestureDetector(
                        onTap: () {
                          _refreshConversation();
                        },
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            padding: const EdgeInsets.all(30.0),
                            decoration: BoxDecoration(
                              gradient: const RadialGradient(
                                colors: [Colors.lightGreenAccent, Colors.white],
                                center: Alignment.center,
                                radius: 0.5,
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: const Icon(Icons.arrow_downward),
                          ),
                        ),
                      ),
                    ]
                  ),
                ),
                TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    border: transparentBorderStyle,
                    enabledBorder: transparentBorderStyle,
                    focusedBorder: transparentBorderStyle,
                    hintText: AppLocalizations.of(context)!.message_place_holder,
                    suffixIcon: _messageController.text.isNotEmpty ?
                      GestureDetector(
                        onTap: () {
                          _sendChatMessage(widget._conversationId, _messageController.text);
                          _messageController.text = '';
                        },
                        child: const Icon(Icons.send, color: Colors.blue)
                      ) : null
                  ),
                ),
              ],
            ),
          );
        }
      )
    );
  }

}