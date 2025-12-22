import 'dart:ui';

import 'package:flutter_riverpod/legacy.dart';

final localeProvider = StateProvider<Locale>((ref) => const Locale('en'));
