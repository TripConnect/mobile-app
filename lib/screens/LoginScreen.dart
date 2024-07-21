import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  final bool isAdmin;

  const LoginScreen(this.isAdmin, {super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late bool isAdmin;

  @override
  void initState() {
    super.initState();
    isAdmin = widget.isAdmin;
  }

  void _switchRole() {
    setState(() {
      isAdmin = !isAdmin;
    });
  }

  String _getRoleString() {
    return isAdmin ? "Admin" : "User";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text("Sign in"),
      ),
      body: Center(
          child: Text(
            isAdmin ? "Admin login" : "User login",
            style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w400
            ),
          ),
      ),
      persistentFooterButtons: <Widget>[
        OutlinedButton.icon(
          onPressed: _switchRole,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
            textStyle: const TextStyle(fontSize: 20),
            foregroundColor: Colors.white,
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            side: const BorderSide(color: Colors.red, width: 2.5)
          ),
          icon: const Icon(Icons.outbond),
          label: Text("Leave ${_getRoleString()} role"),
        )
      ],
    );
  }
}