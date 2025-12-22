import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[500],
      body: Center(
        child: Text(
          "Login title!",
          style: const TextStyle(fontSize: 30, color: Colors.black),
        ),
      ),
    );
  }
}
