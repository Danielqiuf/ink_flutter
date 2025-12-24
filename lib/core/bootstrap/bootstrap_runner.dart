import 'package:flutter/cupertino.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink_self_projects/core/di/container_provider.dart';
import 'package:ink_self_projects/core/di/storage_provider.dart';
import 'package:ink_self_projects/shared/tools/system.dart';

import '../../__locale.g__/translations.g.dart';
import '../di/locale_provider.dart';
import '../ext/sizing_ext.dart';
import 'app_initializer.dart';
import 'app_root.dart';
import 'bootstrap_result.dart';

///
/// 初始化+构造
///
class BootstrapRunner extends StatefulWidget {
  const BootstrapRunner({super.key});

  BootstrapRunner.preserve() : super(key: const Key('bootstrap')) {
    FlutterNativeSplash.preserve(widgetsBinding: WidgetsBinding.instance);
  }

  static const envMap = {"dev": "env/dev.env", "prod": "env/prod.env"};

  static const defaultEnv = "env/dev.env";

  @override
  State<StatefulWidget> createState() => _BootstrapRunnerState();
}

class _BootstrapRunnerState extends State<BootstrapRunner> {
  BootstrapResult? _result;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        /// 初始化页面缩放基准
        Sizing.init(context, designWidth: 375, maxLogicalWidth: 430);
      }
    });

    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final result = await AppInitializer(
      envFile: BootstrapRunner.envMap[kFlavorEnv] ?? BootstrapRunner.defaultEnv,
    ).run();

    setState(() => _result = result);

    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    if (_result == null) {
      return const SizedBox.shrink();
    }

    final result = _result;

    return ProviderScope(
      overrides: [
        localeProvider.overrideWith((ref) => Locale(result!.localeCode)),
        authBoxProvider.overrideWithValue(result!.authBox),
      ],
      child: TranslationProvider(
        child: UncontrolledProviderScope(
          container: container,
          child: AppRoot(initialLocation: result.initialLocation),
        ),
      ),
    );
  }
}
