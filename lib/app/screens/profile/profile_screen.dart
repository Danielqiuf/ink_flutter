import 'package:flutter/material.dart';

import '../../../locale/translations.g.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[500],
      body: Center(
        child: Text(
          context.t.page.profile.title,
          style: const TextStyle(fontSize: 30, color: Colors.blue),
        ),
      ),
    );
  }
}
