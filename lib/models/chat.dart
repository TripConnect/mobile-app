import 'package:mobile_app/constants/common.dart';
import 'package:mobile_app/models/user.dart';

class ChatMessage {
  String id;
  String content;
  UserInfo sender;

  ChatMessage({
    required this.id,
    required this.content,
    required this.sender,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      content: json['messageContent'],
      sender: UserInfo.fromJson(json["fromUser"]),
    );
  }

  @override
  String toString() {
    return 'ChatMessage: id=$id content=$content sender=$sender';
  }
}

class Conversation {
  String id;
  String name;
  ConversationType type;
  List<UserInfo> members;

  Conversation({
    required this.id,
    required this.name,
    required this.type,
    required this.members,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
        id: json["id"],
        name: json["name"] ?? '',
        type: ConversationType.valueOf(json["type"]),
        members: (json['members'] as List)
          .map((u) => UserInfo.fromJson(u))
          .toList(),
    );
  }
}