import 'package:flutter/material.dart';
import 'package:first_app/screens/LoginScreen.dart';

void main() {
  runApp(const Application());
}

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SafeArea(
        child: LoginScreen(false),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

