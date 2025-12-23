import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink_self_projects/app/router/di/router_provider.dart';
import 'package:ink_self_projects/core/bootstrap/bootstrap_provider.dart';
import 'package:ink_self_projects/core/di/container_provider.dart';

import '../../shared/ui/toast/providers/toast_provider.dart';
import '../di/locale_provider.dart';

class AppRoot extends ConsumerWidget {
  final String initialLocation;
  const AppRoot({super.key, required this.initialLocation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    ref.watch(bootstrapProvider);

    final baseTheme = ThemeData(
      scaffoldBackgroundColor: Colors.transparent,
      useMaterial3: true,
      fontFamily: null,
      //  使用 iOS 的排版基线（间距/字号等更接近 iOS）
      platform: TargetPlatform.iOS,
      typography: Typography.material2021(platform: TargetPlatform.iOS),
      cupertinoOverrideTheme: CupertinoThemeData(
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(decoration: TextDecoration.none),
        ),
      ),
    );

    ThemeData theme = baseTheme;

    if (Platform.isIOS) {
      // 默认SF（系统字体），这里不指定 family
      final materialIOSText = baseTheme.textTheme.apply(fontFamily: null);
      theme = baseTheme.copyWith(textTheme: materialIOSText);
    }

    final router = ref.watch(routerProvider(initialLocation));

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: theme,
      locale: locale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      routerConfig: router,
      builder: (ctx, child) {
        final mq = MediaQuery.of(ctx);
        final overlayKey = container.read(toastOverlayKeyProvider);

        final wrapped = MediaQuery(
          data: mq.copyWith(textScaler: const TextScaler.linear(1.0)),
          child: Overlay(
            key: overlayKey,
            initialEntries: [
              OverlayEntry(builder: (_) => child ?? const SizedBox.shrink()),
            ],
          ),
        );

        return wrapped;
      },
    );
  }
}
