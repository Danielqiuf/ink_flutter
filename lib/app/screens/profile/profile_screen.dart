import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink_self_projects/shared/ui/toast/toast_provider.dart';

import '../../../__locale__/translations.g.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.red[500],
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.t.page.profile.title,
              style: const TextStyle(fontSize: 30, color: Colors.blue),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(toastProvider).show("toattoattoattoattoat!!!");
              },
              child: Text('show toast'),
            ),
          ],
        ),
      ),
    );
  }
}
