import 'package:flutter/material.dart';
import 'package:mobile_app/constants/common.dart';
import 'package:mobile_app/models/storage.dart';
import 'package:mobile_app/models/user.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    var globalStorage = Provider.of<Storage>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(globalStorage.currentUser.displayName),
        backgroundColor: appBarBackgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(globalStorage.currentUser.avatar),
                ),
                const SizedBox(width: 30),
                Expanded(
                  child: Text(
                    globalStorage.currentUser.displayName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Additional Info',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}
