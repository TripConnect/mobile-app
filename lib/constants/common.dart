import 'package:flutter/material.dart';
import 'package:mobile_app/models/user.dart';

// application constants
const baseURL = 'http://10.0.2.2:31071';
const gqlEndpoint = '$baseURL/graphql';
const socketIOChatNameSpace = '$baseURL/chat';
const appBarBackgroundColor = Colors.transparent;
const paddingMedium = 20.0;

// user constants
const defaultUserAvatar = '$baseURL/assets/images/default-avatar.jpg';
const avatarSizeSmall = 22.0;
const defaultUser = UserInfo(
    id: "00000000-0000-0000-0000-000000000000",
    displayName: "Unknown",
    avatar: defaultUserAvatar
);

// chat constants
const socketChatNamespace = "chat";

// UI constants
const googleLogoURL = 'assets/images/google-logo.png';
const transparentBorderStyle = OutlineInputBorder(
  borderSide: BorderSide(color: Colors.transparent),
);
const conversationTitleMaxLength = 20;

// Enum definitions
enum Language {
  vi("vi", "Vietnamese"),
  en("en", "English");

  final String code;
  final String text;

  const Language(this.code, this.text);
}

enum ConversationType {
  private("PRIVATE");

  final String code;

  const ConversationType(this.code);

  static ConversationType valueOf(String text) {
    for(ConversationType type in values) {
      if(type.code == text) return type;
    }
    throw Exception('Incorrect value: $text');
  }
}