import 'package:flutter/material.dart';

///
/// 缩放按钮：按下缩小，松开回弹（Scale）
///
class ScaleButton extends StatefulWidget {
  const ScaleButton({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.pressedScale = 0.96,
    this.downDuration = const Duration(milliseconds: 80),
    this.upDuration = const Duration(milliseconds: 140),
    this.upCurve = Curves.easeOutBack,
    this.downCurve = Curves.easeOut,
    this.alignment = Alignment.center,
    this.behavior = HitTestBehavior.opaque,
    this.enabled = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// 按下缩放比例（<1 缩小；>1 放大）
  final double pressedScale;

  final Duration downDuration;
  final Duration upDuration;
  final Curve upCurve;
  final Curve downCurve;

  final Alignment alignment;
  final HitTestBehavior behavior;
  final bool enabled;

  @override
  State<ScaleButton> createState() => _ScaleButtonState();
}

class _ScaleButtonState extends State<ScaleButton> {
  bool _pressed = false;

  bool get _isEnabled =>
      widget.enabled && (widget.onTap != null || widget.onLongPress != null);

  void _setPressed(bool v) {
    if (_pressed == v) return;
    setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final scale = _pressed ? widget.pressedScale : 1.0;

    return GestureDetector(
      behavior: widget.behavior,
      onTap: _isEnabled ? widget.onTap : null,
      onLongPress: _isEnabled ? widget.onLongPress : null,
      onTapDown: _isEnabled ? (_) => _setPressed(true) : null,
      onTapUp: _isEnabled ? (_) => _setPressed(false) : null,
      onTapCancel: _isEnabled ? () => _setPressed(false) : null,
      child: AnimatedScale(
        scale: scale,
        alignment: widget.alignment,
        duration: _pressed ? widget.downDuration : widget.upDuration,
        curve: _pressed ? widget.downCurve : widget.upCurve,
        child: widget.child,
      ),
    );
  }
}
