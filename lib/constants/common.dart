import 'package:flutter/material.dart';
import 'package:mobile_app/models/user.dart';

// application constants
const baseURL = 'http://10.0.2.2:3107';
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
const transparentBorderStyle = OutlineInputBorder(
  borderSide: BorderSide(color: Colors.transparent),
);
