part of tap.ripple.tone;

/// TapImageRipple：给图片类 Widget加点击 Ripple
///
/// image 接收 Widget：支持 ApexImage / Image / CachedNetworkImage / 任意自定义图片组件
/// Ripple 使用 Stack + 顶层透明 Material，确保 ripple 一定在图片之上
/// 圆角/自定义形状、阴影、长按、颜色配置
///
class TapImageRipple extends StatelessWidget {
  const TapImageRipple({
    super.key,
    required this.image,
    this.onTap,
    this.onLongPress,
    this.width,
    this.height,
    this.borderRadius,
    this.customBorder,
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
    this.child, // 可叠加角标/蒙层等
  });

  /// 兼容 ImageProvider 的快捷构造（可选用）
  TapImageRipple.provider({
    super.key,
    required ImageProvider image,
    this.onTap,
    this.onLongPress,
    this.width,
    this.height,
    BoxFit fit = BoxFit.cover,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    FilterQuality filterQuality = FilterQuality.low,
    this.borderRadius,
    this.customBorder,
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
    this.child,
  }) : image = Image(
         image: image,
         fit: fit,
         alignment: alignment,
         repeat: repeat,
         filterQuality: filterQuality,
       );

  final Widget image;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  final double? width;
  final double? height;

  final BorderRadius? borderRadius;
  final ShapeBorder? customBorder;

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

  final Widget? child;

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

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: materialColor,
        elevation: elevation,
        shape: customBorder,
        borderRadius: br,
        clipBehavior: clipBehavior,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(child: image),
            if (child != null) child!,

            // Ripple 永远在图片之上
            Positioned.fill(
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: onTap,
                  onLongPress: onLongPress,
                  borderRadius: br,
                  customBorder: customBorder,
                  splashColor: palette.splash,
                  highlightColor: palette.highlight,
                  hoverColor: palette.hover,
                  focusColor: palette.focus,
                  enableFeedback: enableFeedback,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
