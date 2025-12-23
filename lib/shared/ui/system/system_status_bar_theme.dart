import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// dark = 深色图标（适合浅色背景）
/// light = 浅色图标（适合深色背景）
enum StatusBarTheme { dark, light }

SystemUiOverlayStyle transparentStatusBarStyle(StatusBarTheme theme) {
  final bool darkIcons = theme == StatusBarTheme.dark;

  return SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,

    // Android：控制状态栏图标明暗（仅 Android M+
    statusBarIconBrightness: darkIcons ? Brightness.dark : Brightness.light,

    statusBarBrightness: darkIcons ? Brightness.light : Brightness.dark,

    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,

    // Android：导航栏图标亮暗
    systemNavigationBarIconBrightness: darkIcons
        ? Brightness.dark
        : Brightness.light,

    // 避免 Android 10+ 透明状态栏时系统自动加对比度遮罩
    systemStatusBarContrastEnforced: false,
    systemNavigationBarContrastEnforced: false,
  );
}
