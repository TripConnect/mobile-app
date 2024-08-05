import 'dart:async'; // Import for Timer
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_app/constants/common.dart';
import 'package:mobile_app/models/storage.dart';
import 'package:mobile_app/models/user.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile_app/screens/chat_screen.dart';
import 'package:mobile_app/screens/home_screen.dart';
import 'package:mobile_app/screens/profile_screen.dart';
import 'package:provider/provider.dart';

const searchUsersQuery = r"""
  query SearchUsers($searchTerm: String!) {
    users(searchTerm: $searchTerm) {
      id
      avatar
      displayName
    }
  }
""";

const createConversationMutation = r"""
  mutation CreateConversation($type: String!, $members: String!) {
    createConversation(type: $type, members: $members) {
      id
    }
  }
""";

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MessageScreenState();
  }
}

class _SearchResultUser extends StatelessWidget {
  final UserInfo userInfo;

  const _SearchResultUser(this.userInfo);

  @override
  Widget build(BuildContext context) {
    var globalStorage = Provider.of<GlobalStorage>(context);

    return GestureDetector (
      onTap: () async {
        if(globalStorage.currentUser.id == userInfo.id) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen()
            ),
          );
          return;
        }

        final mutationResult = await globalStorage.gqlClient.value.mutate(
            MutationOptions(
              document: gql(createConversationMutation),
              variables: {
                'type': ConversationType.private.code,
                'members': [globalStorage.currentUser.id, userInfo.id].join(",")
              },
            )
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(mutationResult.data!["createConversation"]["id"])
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(2),
        child: Row(
          children: [
            CircleAvatar(
              radius: avatarSizeSmall,
              backgroundImage: NetworkImage(userInfo.avatar),
            ),
            const SizedBox(width: 12),
            Text(userInfo.displayName)
          ],
        ),
      ),
    );
  }
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Duration _debounceTime = const Duration(seconds: 1);
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(_debounceTime, () {
      // Trigger a rebuild and execute the query
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(paddingMedium),
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Query(
                options: QueryOptions(
                  document: gql(searchUsersQuery),
                  variables: {'searchTerm': _searchController.text},
                  // Optionally, set pollInterval to auto-refresh
                  // pollInterval: Duration(seconds: 5),
                ),
                builder: (QueryResult result, {refetch, fetchMore}) {
                  if (result.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (result.hasException) {
                    return Center(child: Text(result.exception.toString()));
                  }

                  final List users = result.data?['users'] ?? [];

                  return Column(
                    children: <Widget>[
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          border: transparentBorderStyle,
                          enabledBorder: transparentBorderStyle,
                          focusedBorder: transparentBorderStyle,
                          hintText: AppLocalizations.of(context)!.search,
                          prefixIcon: const Icon(Icons.search),
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          children: users
                              .map((user) => _SearchResultUser(UserInfo.fromJson(user)))
                              .toList(),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }
}
