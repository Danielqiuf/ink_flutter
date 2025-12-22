import 'package:flutter/material.dart';
import 'package:ink_self_projects/locale/translations.g.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[500],
      body: Center(
        child: Text(
          context.t.page.home.title,
          style: const TextStyle(fontSize: 30, color: Colors.red),
        ),
      ),
    );
  }
}
