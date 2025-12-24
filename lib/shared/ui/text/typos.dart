import 'package:flutter/material.dart';
import 'package:ink_self_projects/core/ext/context_ext.dart';
import 'package:ink_self_projects/shared/specs/typography_themed_spec.dart';

///
/// 文字组件，与[TypographyThemedSpec]规范对齐，自带字体
///
class Typos extends StatelessWidget {
  const Typos(
    this.data, {
    super.key,
    this.token = TypographyToken.m,
    this.fontRole = TypographyRole.primary,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.color,
    this.fontWeight,
    this.fontSize,
    this.height,
    this.letterSpacing,
    this.decoration,
    this.selectable = false,
  });

  final String data;

  /// 文字规范入口
  final TypographyToken token;
  final TypographyRole fontRole;

  /// 常用 Text 参数
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;

  /// 允许覆盖（一般只在特殊场景使用）
  final Color? color;
  final FontWeight? fontWeight;
  final double? fontSize;
  final double? height;
  final double? letterSpacing;
  final TextDecoration? decoration;

  /// 是否可选中
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;
    final c = context.colors;

    final base = typography.styleOf(token, role: fontRole);
    final resolvedColor = color ?? c.textPrimary;
    final resolvedSize = fontSize ?? base.fontSize;
    final resolvedWeight = fontWeight ?? base.fontWeight;
    final resolvedHeight = height ?? base.height;
    final resolvedLetterSpacing = letterSpacing ?? base.letterSpacing;
    final resolvedDecoration = decoration ?? base.decoration;

    final style = base.copyWith(
      color: resolvedColor,
      fontWeight: resolvedWeight,
      fontSize: resolvedSize,
      height: resolvedHeight,
      letterSpacing: resolvedLetterSpacing,
      decoration: resolvedDecoration,
    );

    if (selectable) {
      return SelectableText(
        data,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
      );
    }

    return Text(
      data,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
    );
  }
}
