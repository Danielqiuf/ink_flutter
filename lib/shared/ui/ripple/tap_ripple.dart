part of tap.ripple.tone;

/// TapRipple：给任意普通布局（Row/Column/Container 等）添加点击 Ripple
///
/// 圆角/自定义形状
/// padding、长按等
///
class TapRipple extends StatelessWidget {
  const TapRipple({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.onTapDown,
    this.onTapCancel,
    this.borderRadius,
    this.customBorder,
    this.padding,
    this.materialColor = Colors.transparent,
    this.elevation = 0,
    this.tone = TapRippleTone.auto,
    this.rippleColor,
    this.splashColor,
    this.highlightColor,
    this.hoverColor,
    this.focusColor,
    this.enableFeedback = true,
    this.clipBehavior = Clip.antiAlias,
  });

  final Widget child;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final GestureTapDownCallback? onTapDown;
  final VoidCallback? onTapCancel;

  final BorderRadius? borderRadius;
  final ShapeBorder? customBorder;
  final EdgeInsetsGeometry? padding;

  final Color materialColor;
  final double elevation;

  /// 主题：dark/light/auto
  final TapRippleTone tone;

  /// 自定义 ripple 基础色（不传则：light=黑、dark=白、auto 跟随主题）
  final Color? rippleColor;

  /// 自定义覆盖（不传则由 tone 自动算最佳默认值）
  final Color? splashColor;
  final Color? highlightColor;
  final Color? hoverColor;
  final Color? focusColor;

  final bool enableFeedback;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final BorderRadius? br = customBorder == null
        ? (borderRadius ?? BorderRadius.zero)
        : null;

    final palette = _RipplePalette.resolve(
      context,
      tone: tone,
      rippleColor: rippleColor,
      splashColor: splashColor,
      highlightColor: highlightColor,
      hoverColor: hoverColor,
      focusColor: focusColor,
    );

    return Material(
      color: materialColor,
      elevation: elevation,
      shape: customBorder,
      borderRadius: br,
      clipBehavior: clipBehavior,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        onTapDown: onTapDown,
        onTapCancel: onTapCancel,
        borderRadius: br,
        customBorder: customBorder,
        splashColor: palette.splash,
        highlightColor: palette.highlight,
        hoverColor: palette.hover,
        focusColor: palette.focus,
        enableFeedback: enableFeedback,
        child: padding == null
            ? child
            : Padding(padding: padding!, child: child),
      ),
    );
  }
}
