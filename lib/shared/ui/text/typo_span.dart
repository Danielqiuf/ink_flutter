import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../specs/typography_themed_spec.dart';

@immutable
class TypoSpanSegment {
  const TypoSpanSegment(
    this.text, {
    this.onTap,
    this.token,
    this.role,
    this.color,
    this.fontWeight,
    this.decoration,
    this.decorationColor,
    this.styleOverride,
  });

  final String text;

  /// 覆盖字号 token
  final TypographyToken? token;

  /// 覆盖字体 role
  final TypographyRole? role;

  /// 不为 null 时，该片段可点击
  final VoidCallback? onTap;

  /// 覆盖字重
  final FontWeight? fontWeight;

  /// 覆盖下划线
  final TextDecoration? decoration;

  final Color? color;

  final Color? decorationColor;

  final TextStyle? styleOverride;

  bool get isClickable => onTap != null;
}

///
/// 多文本字体，内容可以点击，一般用于隐私协议等需要文字嵌套且可以点击的场景
///
class TypoSpan extends StatefulWidget {
  const TypoSpan({
    super.key,
    required this.segments,
    this.token = TypographyToken.m,
    this.role = TypographyRole.primary,

    /// 普通文本默认颜色,不传则使用 colorScheme.onSurface
    this.defaultColor,

    /// 可点击片段默认颜色,不传则使用 colorScheme.primary
    this.linkColor,

    /// 可点击片段默认下划线
    this.defaultLinkDecoration = TextDecoration.underline,

    this.textAlign,
    this.maxLines,
    this.overflow = TextOverflow.clip,
    this.softWrap,
    this.selectable = false,
  });

  final List<TypoSpanSegment> segments;

  final TypographyToken token;
  final TypographyRole role;

  final Color? defaultColor;
  final Color? linkColor;
  final TextDecoration defaultLinkDecoration;

  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow overflow;
  final bool? softWrap;

  /// 是否可选中（SelectableText.rich）
  final bool selectable;

  @override
  State<TypoSpan> createState() => _TypoSpanState();
}

class _TypoSpanState extends State<TypoSpan> {
  final List<TapGestureRecognizer?> _recognizers = <TapGestureRecognizer?>[];

  @override
  void initState() {
    super.initState();
    _syncRecognizers();
  }

  @override
  void didUpdateWidget(covariant TypoSpan oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.segments.length != widget.segments.length ||
        !_sameTapHandlers(oldWidget.segments, widget.segments)) {
      _disposeRecognizers();
      _syncRecognizers();
    }
  }

  bool _sameTapHandlers(List<TypoSpanSegment> a, List<TypoSpanSegment> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].onTap != b[i].onTap) return false;
    }
    return true;
  }

  void _syncRecognizers() {
    _recognizers
      ..clear()
      ..addAll(
        widget.segments.map((seg) {
          if (seg.onTap == null) return null;
          return TapGestureRecognizer()..onTap = seg.onTap;
        }),
      );
  }

  void _disposeRecognizers() {
    for (final r in _recognizers) {
      r?.dispose();
    }
    _recognizers.clear();
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final typography =
        theme.extension<TypographyThemedSpec>() ?? const TypographyThemedSpec();

    final resolvedDefaultColor = widget.defaultColor ?? cs.onSurface;
    final resolvedLinkColor = widget.linkColor ?? cs.primary;

    // 根样式：用默认 token/role，颜色用 defaultColor
    final baseStyle = typography
        .styleOf(widget.token, role: widget.role)
        .copyWith(color: resolvedDefaultColor);

    final children = <InlineSpan>[];

    for (var i = 0; i < widget.segments.length; i++) {
      final seg = widget.segments[i];

      final segToken = seg.token ?? widget.token;
      final segRole = seg.role ?? widget.role;

      // 基于规范生成 segStyle
      TextStyle segStyle = typography.styleOf(segToken, role: segRole);

      // 颜色策略：seg.color > (clickable ? linkColor : defaultColor)
      final segColor =
          seg.color ??
          (seg.isClickable ? resolvedLinkColor : resolvedDefaultColor);

      // 点击默认下划线（但允许 segment.decoration 覆盖）
      final segDecoration =
          seg.decoration ??
          (seg.isClickable ? widget.defaultLinkDecoration : null);

      segStyle = segStyle.copyWith(
        color: segColor,
        fontWeight: seg.fontWeight,
        decoration: segDecoration,
        decorationColor: seg.decorationColor,
      );

      // 最高优先级 styleOverride
      if (seg.styleOverride != null) {
        segStyle = segStyle.merge(seg.styleOverride);
      }

      children.add(
        TextSpan(text: seg.text, style: segStyle, recognizer: _recognizers[i]),
      );
    }

    final span = TextSpan(style: baseStyle, children: children);

    if (widget.selectable) {
      return SelectableText.rich(
        span,
        textAlign: widget.textAlign,
        maxLines: widget.maxLines,
      );
    }

    return Text.rich(
      span,
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
      softWrap: widget.softWrap,
    );
  }
}
