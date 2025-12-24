import 'package:flutter/material.dart';

/// 自由颜色值，不会随系统主题色切换而影响
@immutable
class ColorFreeSpec {
  const ColorFreeSpec({
    // 基础固定色
    required this.white,
    required this.black,
    required this.transparent,

    // 常用蒙层/遮罩（固定 alpha）
    required this.mask20,
    required this.mask40,
    required this.mask60,

    required this.pureRed,
    required this.pureGreen,
  });

  final Color white;
  final Color black;
  final Color transparent;

  final Color mask20;
  final Color mask40;
  final Color mask60;

  final Color pureRed;
  final Color pureGreen;
}

///
/// 颜色值规范，dart, light会随系统主题色变化， free相反，很自由
///
final class ColorThemedSpec extends ThemeExtension<ColorThemedSpec> {
  const ColorThemedSpec({
    // Brand
    required this.primary,
    required this.onPrimary,
    required this.link,

    // Background / Surface
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.border,

    // Text
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,

    // Status
    required this.danger,
    required this.onDanger,
    required this.success,
    required this.warning,
  });

  // Brand
  final Color primary;
  final Color onPrimary;
  final Color link;

  // Background / Surface
  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color border;

  // Text
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textDisabled;

  // Status
  final Color danger;
  final Color onDanger;
  final Color success;
  final Color warning;

  static const free = ColorFreeSpec(
    white: Color(0xFFFFFFFF),
    black: Color(0xFF000000),
    transparent: Colors.transparent,

    mask20: Color(0x33000000), // 20% black
    mask40: Color(0x66000000), // 40% black
    mask60: Color(0x99000000), // 60% black

    pureRed: Color(0xFFFF0000),
    pureGreen: Color(0xFF00FF00),
  );

  /// Light 默认值
  static const light = ColorThemedSpec(
    primary: Color(0xFF2F6BFF),
    onPrimary: Color(0xFFFFFFFF),
    link: Color(0xFF2F6BFF),

    background: Color(0xFFF7F8FA),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFFFFFFF),
    border: Color(0xFFE5E6EB),

    textPrimary: Color(0xFF1D2129),
    textSecondary: Color(0xFF4E5969),
    textTertiary: Color(0xFF86909C),
    textDisabled: Color(0xFFBFBFBF),

    danger: Color(0xFFD92D20),
    onDanger: Color(0xFFFFFFFF),
    success: Color(0xFF12B76A),
    warning: Color(0xFFF79009),
  );

  /// Dark 默认值
  static const dark = ColorThemedSpec(
    primary: Color(0xFF7AA2FF),
    onPrimary: Color(0xFF0B1020),
    link: Color(0xFF7AA2FF),

    background: Color(0xFF0B0F17),
    surface: Color(0xFF121826),
    surfaceElevated: Color(0xFF1A2233),
    border: Color(0xFF2A344A),

    textPrimary: Color(0xFFE6E8EE),
    textSecondary: Color(0xFFB8C0D4),
    textTertiary: Color(0xFF7E8AA7),
    textDisabled: Color(0xFF4A5570),

    danger: Color(0xFFFF5A4F),
    onDanger: Color(0xFF0B0F17),
    success: Color(0xFF2EE59D),
    warning: Color(0xFFFFB44D),
  );

  @override
  ColorThemedSpec copyWith({
    Color? primary,
    Color? onPrimary,
    Color? link,
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textDisabled,
    Color? danger,
    Color? onDanger,
    Color? success,
    Color? warning,
  }) {
    return ColorThemedSpec(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      link: link ?? this.link,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textDisabled: textDisabled ?? this.textDisabled,
      danger: danger ?? this.danger,
      onDanger: onDanger ?? this.onDanger,
      success: success ?? this.success,
      warning: warning ?? this.warning,
    );
  }

  /// 插值变化，随系统主题动态切换实现线性插值
  @override
  ColorThemedSpec lerp(ThemeExtension<ColorThemedSpec>? other, double t) {
    if (other is! ColorThemedSpec) return this;
    return ColorThemedSpec(
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      link: Color.lerp(link, other.link, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      onDanger: Color.lerp(onDanger, other.onDanger, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
    );
  }
}
