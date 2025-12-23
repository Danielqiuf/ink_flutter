import 'dart:ui';

import 'package:flutter_riverpod/legacy.dart';

///
/// 全局本地化上下文
///
final localeProvider = StateProvider<Locale>((ref) => const Locale('en'));
