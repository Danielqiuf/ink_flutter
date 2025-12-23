library tap.ripple.tone;

import 'package:flutter/material.dart';

part 'tap_image_ripple.dart';
part 'tap_ripple.dart';

/// Ripple 主题
///
/// auto：跟随 Theme.brightness 自动选择
/// light：适配浅色背景（默认用黑色系 ripple）
/// dark：适配深色背景（默认用白色系 ripple）
enum TapRippleTone { auto, light, dark }

class _RipplePalette {
  const _RipplePalette({
    required this.splash,
    required this.highlight,
    required this.hover,
    required this.focus,
  });

  final Color splash;
  final Color highlight;
  final Color hover;
  final Color focus;

  static _RipplePalette resolve(
    BuildContext context, {
    required TapRippleTone tone,
    Color? rippleColor,
    Color? splashColor,
    Color? highlightColor,
    Color? hoverColor,
    Color? focusColor,
  }) {
    final brightness = Theme.of(context).brightness;
    final bool isDark = switch (tone) {
      TapRippleTone.dark => true,
      TapRippleTone.light => false,
      TapRippleTone.auto => brightness == Brightness.dark,
    };

    // 基础颜色,允许自定义，否则 dark 用白 / light 用黑
    final Color base = rippleColor ?? (isDark ? Colors.white : Colors.black);

    final Color dSplash = base.withOpacity(isDark ? 0.18 : 0.14);
    final Color dFocus = base.withOpacity(isDark ? 0.12 : 0.10);
    final Color dHighlight = base.withOpacity(isDark ? 0.10 : 0.06);
    final Color dHover = base.withOpacity(isDark ? 0.08 : 0.04);

    return _RipplePalette(
      splash: splashColor ?? dSplash,
      highlight: highlightColor ?? dHighlight,
      hover: hoverColor ?? dHover,
      focus: focusColor ?? dFocus,
    );
  }
}
