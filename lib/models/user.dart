import 'package:mobile_app/constants/common.dart';

class UserInfo {
  final String id;
  final String displayName;
  final String avatar;

  const UserInfo({
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

class SignInResponse {
  final UserInfo userInfo;

  SignInResponse({
    required this.userInfo,
  });

  factory SignInResponse.fromJson(Map<String, dynamic> json) {
    return SignInResponse(
      userInfo: UserInfo.fromJson(json['userInfo']),
    );
  }
}
