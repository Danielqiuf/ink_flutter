import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'toast.dart';

final toastOverlayKeyProvider = Provider<GlobalKey<OverlayState>>((ref) {
  return GlobalKey<OverlayState>();
});

final toastProvider = Provider<Toast>((ref) {
  final overlayKey = ref.read(toastOverlayKeyProvider);
  return Toast(overlayKey: overlayKey);
});
