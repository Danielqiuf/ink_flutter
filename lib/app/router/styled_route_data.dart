import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../shared/ui/system/system_status_bar_theme.dart';

/// 让每个 GoRouteData 只需要声明一个 statusBarColor，
/// 其余统一处理（AnnotatedRegion + 顶部背景条）。
abstract class StyledRouteData extends GoRouteData {
  const StyledRouteData();

  StatusBarTheme get statusBarTheme;

  @visibleForOverriding
  Widget buildScreen(BuildContext context, GoRouterState state);

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: transparentStatusBarStyle(statusBarTheme),
      child: buildScreen(context, state),
    );
  }
}
