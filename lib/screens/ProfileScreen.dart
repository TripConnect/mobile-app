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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            Row(
              children: [
                CircleAvatar(
                  radius: 50, // Adjust the radius as needed
                  backgroundImage: NetworkImage(widget.userInfo.avatar),
                ),
                const SizedBox(width: 30),
                Text(
                  widget.userInfo.displayName,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w500
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

}