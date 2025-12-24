import 'package:flutter/material.dart';
import 'package:ink_self_projects/core/ext/sizing_ext.dart';

/// 字号 Token，从大到超小
enum TypographyToken { xxl, xl, l, m, s, xs, xxs, micro }

/// 不同字体用途
enum TypographyRole { primary }

/// 家族字体规范定义
@immutable
class TypographyFamilySpec {
  static const String primary = 'NotoSansSC';

  static const List<String> fallback = <String>[
    // iOS
    'PingFang SC',
    'SF Pro Text',
    // Android
    'Roboto',
    'Noto Sans CJK SC',
    'Noto Sans SC',
  ];

  static String family(TypographyRole role) => switch (role) {
    TypographyRole.primary => primary,

    /// ....
  };
}

final class TypographyThemedSpec extends ThemeExtension<TypographyThemedSpec> {
  const TypographyThemedSpec();

  TextStyle styleOf(
    TypographyToken token, {
    TypographyRole role = TypographyRole.primary,
  }) {
    final (fontSize, lineHeight, weight, letterSpacing) = _spec(token);

    final fsDp = fontSize.dp;
    final lhDp = lineHeight.dp;
    final lsDp = letterSpacing.dp;

    return TextStyle(
      fontFamily: TypographyFamilySpec.family(role),
      fontFamilyFallback: TypographyFamilySpec.fallback,
      fontSize: fsDp,
      height: lhDp / fsDp,
      fontWeight: weight,
      letterSpacing: lsDp,
    );
  }

  (double fontSize, double lineHeight, FontWeight weight, double letterSpacing)
  _spec(TypographyToken token) {
    switch (token) {
      case TypographyToken.xxl:
        return (32, 40, FontWeight.w600, -0.2);
      case TypographyToken.xl:
        return (24, 32, FontWeight.w600, 0);
      case TypographyToken.l:
        return (20, 28, FontWeight.w600, 0);
      case TypographyToken.m:
        return (16, 24, FontWeight.w400, 0);
      case TypographyToken.s:
        return (14, 20, FontWeight.w400, 0);
      case TypographyToken.xs:
        return (12, 16, FontWeight.w400, 0);
      case TypographyToken.xxs:
        return (10, 14, FontWeight.w500, 0.2);
      case TypographyToken.micro:
        return (8, 10, FontWeight.w400, 0.25);
    }
  }

  @override
  TypographyThemedSpec copyWith() => TypographyThemedSpec();

  @override
  TypographyThemedSpec lerp(
    ThemeExtension<TypographyThemedSpec>? other,
    double t,
  ) {
    // 该扩展目前是离散配置，不需要插值
    if (other is! TypographyThemedSpec) return this;
    return t < 0.5 ? this : other;
  }
}
