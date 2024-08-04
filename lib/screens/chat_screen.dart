import 'package:flutter/material.dart';
import 'package:mobile_app/constants/common.dart';

class ChatScreen extends StatefulWidget {
  final String _conversationId;

  const ChatScreen(this._conversationId, {super.key});

  @override
  State<StatefulWidget> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(paddingMedium),
        child: Column(
          children: <Widget>[
            Flexible(flex: 1, child: Text(widget._conversationId)),
            Flexible(
                flex: 10,
                child: Column(
                  children: <Widget>[

                  ],
                )
            ),
          ],
        ),
      ),
    );
  }

}