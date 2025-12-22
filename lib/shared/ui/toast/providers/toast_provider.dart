import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../toast.dart';

final scaffoldMessengerKeyProvider =
    Provider<GlobalKey<ScaffoldMessengerState>>(
      (ref) => GlobalKey<ScaffoldMessengerState>(),
    );

final toastProvider = Provider<Toast>((ref) {
  final key = ref.read(scaffoldMessengerKeyProvider);
  return Toast(scaffoldMessengerKey: key);
});
