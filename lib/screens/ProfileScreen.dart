import 'package:flutter/material.dart';
import 'package:mobile_app/models/user.dart';

class ProfileScreen extends StatefulWidget {
  final UserInfo userInfo;

  const ProfileScreen({super.key, required this.userInfo});

  @override
  State<StatefulWidget> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Image.network(widget.userInfo.avatar),
          Text(widget.userInfo.displayName),
        ],
      ),
    );
  }

}