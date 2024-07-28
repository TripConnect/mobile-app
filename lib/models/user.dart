import 'package:mobile_app/constants/common.dart';

class UserInfo {
  final String id;
  final String displayName;
  final String avatar;

  UserInfo({
    required this.id,
    required this.displayName,
    required this.avatar,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'],
      displayName: json['displayName'],
      avatar: (json['avatar'] ?? '').isEmpty ? defaultUserAvatar : json['avatar'],
    );
  }

  @override
  String toString() {
    return 'UserInfo: id=$id displayName=$displayName avatar=$avatar';
  }
}

class Token {
  final String accessToken;
  final String refreshToken;

  Token({
    required this.accessToken,
    required this.refreshToken,
  });

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'] ?? '',
    );
  }
}

class SignInResponse {
  final UserInfo userInfo;
  final Token token;

  SignInResponse({
    required this.userInfo,
    required this.token,
  });

  factory SignInResponse.fromJson(Map<String, dynamic> json) {
    return SignInResponse(
      userInfo: UserInfo.fromJson(json['userInfo']),
      token: Token.fromJson(json['token']),
    );
  }
}
