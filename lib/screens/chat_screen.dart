import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_app/constants/common.dart';
import 'package:mobile_app/models/chat.dart';
import 'package:mobile_app/models/storage.dart';
import 'package:provider/provider.dart';
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
  query Conversation($id: String!, $page: Int, $limit: Int) {
    conversation(id: $id) {
      messages(page: $page, limit: $limit) {
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
            backgroundImage: NetworkImage(globalStorage.currentUser.avatar),
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
  List<ChatMessage> messages = [];
  bool _isReadySendMessage = false;
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
    _messageController.removeListener(_onMessageChange);
    _messageController.dispose();
    super.dispose();
  }

  void _onMessageChange() {
    setState(() {
      _isReadySendMessage = _messageController.text.isNotEmpty;
    });
  }

  void _onScroll() {
    print("scrolling...");
    if(_scrollController.position.atEdge) {
      bool isTop = _scrollController.position.pixels == 0;
      if (isTop) {
        _currentChatHistoryPageNum++;
        setState(() {});
      }
    }
  }

  Future<List<ChatMessage>> _fetchChatHistory(GraphQLClient gqlClient) async {
    // var result = await gqlClient.query(
    //   QueryOptions(
    //     document: gql(chatHistoryQuery),
    //     variables: {
    //       'id': widget._conversationId,
    //       'page': _currentChatHistoryPageNum,
    //       'limit': pageSize
    //     },
    //   ),
    // );
    // return (result.data?["conversation"]["messages"] as List)
    //     .map((m) => ChatMessage.fromJson(m))
    //     .toList();
    return List.generate(pageSize, (index) => ChatMessage(
      id: '',
      content: 'fake content page=$_currentChatHistoryPageNum index=$index',
      sender: defaultUser
    ));
  }

  @override
  Widget build(BuildContext context) {
    var globalStorage = Provider.of<GlobalStorage>(context);

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
          if(title.length > conversationTitleMaxLength) {
            title = '${title.substring(0, conversationTitleMaxLength)}...';
          }

          return Padding(
            padding: const EdgeInsets.all(paddingMedium),
            child: Column(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(globalStorage.currentUser.avatar),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(title, style: const TextStyle(fontSize: 25))
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<ChatMessage>>(
                    future: _fetchChatHistory(globalStorage.gqlClient.value),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Column(children: []);
                      } else {
                        messages.insertAll(0, snapshot.data!);
                        return ListView(
                            controller: _scrollController,
                            children: messages
                              .map((m) => ChatMessageItem(m))
                              .toList()
                        );
                      }
                    }
                  ),
                ),
                TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    border: transparentBorderStyle,
                    enabledBorder: transparentBorderStyle,
                    focusedBorder: transparentBorderStyle,
                    hintText: AppLocalizations.of(context)!.message,
                    suffixIcon: _isReadySendMessage ?
                      GestureDetector(
                        onTap: () {
                          print("send: ${_messageController.text}");
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