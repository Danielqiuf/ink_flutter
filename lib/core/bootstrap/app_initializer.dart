import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ink_self_projects/core/storage/hiv/hiv_secure.dart';

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

    await HivSecure.instance.init();

    final initialLocation = '/home';

    return BootstrapResult(
      initialLocation: initialLocation,
      localeCode: 'en',
      authBox: HivSecure.instance.authBox,
    );
  }
}
