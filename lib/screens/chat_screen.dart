import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_app/constants/common.dart';
import 'package:mobile_app/models/chat.dart';
import 'package:mobile_app/models/storage.dart';
import 'package:provider/provider.dart';

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

class ChatScreen extends StatefulWidget {
  final String _conversationId;

  const ChatScreen(this._conversationId, {super.key});

  @override
  State<StatefulWidget> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  int _currentChatHistoryPageNum = 1;
  final int pageSize = 100;

  Future<List<ChatMessage>> getChatHistory(GraphQLClient gqlClient) async {
    var result = await gqlClient.query(
      QueryOptions(
        document: gql(chatHistoryQuery),
        variables: {
          'id': widget._conversationId,
          'page': _currentChatHistoryPageNum,
          'limit': pageSize
        },
      ),
    );
    return (result.data?["conversation"]["messages"] as List)
        .map((m) => ChatMessage.fromJson(m))
        .toList();
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
          String title = ConversationType.private == conversation.type ?
            conversation.members.firstWhere((m) => m.id != globalStorage.currentUser.id).displayName :
            "Chat title"; // FIXME: Remember update here for other types

          return Padding(
            padding: const EdgeInsets.all(paddingMedium),
            child: Column(
              children: <Widget>[
                Row(
                  children: [
                    Text(title, style: const TextStyle(fontSize: 25))
                  ],
                ),
                Container(
                  child: FutureBuilder<List<ChatMessage>>(
                    future: getChatHistory(globalStorage.gqlClient.value),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Column(children: []);
                      } else {
                        return Column(
                          children: snapshot.data
                            !.map((m) => Align(
                              alignment: m.sender.id == globalStorage.currentUser.id ?
                                Alignment.centerRight : Alignment.centerLeft,
                              child: Text(m.content)
                            ),
                          )
                          .toList()
                        );
                      }
                    }
                  ),
                )
              ],
            ),
          );
        }
      )
    );
  }

}