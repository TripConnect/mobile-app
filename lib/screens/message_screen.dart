import 'package:flutter/material.dart';
import 'package:mobile_app/constants/common.dart';
import 'package:mobile_app/models/user.dart';

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
    return Container(
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
    );
  }

}

class _MessageScreenState extends State<MessageScreen> {
  List<UserInfo> _searchResult = [];

  @override
  void initState() {
    super.initState();
    _searchResult = [defaultUser, defaultUser, defaultUser];
  }

  void onSearchTermSubmit(String term) {
    setState(() {
      _searchResult = [defaultUser];
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
              child: TextField(
                decoration: const InputDecoration(
                  border: transparentBorderStyle,
                  enabledBorder: transparentBorderStyle,
                  focusedBorder: transparentBorderStyle,
                  labelText: 'Search',
                  prefixIcon: Icon(Icons.search),
                ),
                onSubmitted: onSearchTermSubmit,
              ),
            ),
            Expanded(
              child: ListView(
                children: _searchResult.map((result) => _SearchResultUser(result)).toList(),
              )
            )
          ],
        ),
      ),
    );
  }
}