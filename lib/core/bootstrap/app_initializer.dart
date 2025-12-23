import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'bootstrap_result.dart';

class AppInitializer {
  AppInitializer({required this.envFile});

  final String envFile;

  Future<BootstrapResult> run() async {
    // 强制竖屏
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    // edge to edge
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await dotenv.load(fileName: envFile);

    final initial = '/home';

    return BootstrapResult(initialLocation: initial, localeCode: 'en');
  }
}
