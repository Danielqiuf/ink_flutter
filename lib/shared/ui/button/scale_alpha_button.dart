import 'package:flutter/material.dart';

///
/// 缩放 + 透明度组合
///
class ScaleAlphaButton extends StatefulWidget {
  const ScaleAlphaButton({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.pressedScale = 0.965,
    this.pressedOpacity = 0.85,
    this.downDuration = const Duration(milliseconds: 70),
    this.upDuration = const Duration(milliseconds: 150),
    this.downCurve = Curves.easeOut,
    this.upCurve = Curves.easeOutBack,
    this.behavior = HitTestBehavior.opaque,
    this.enabled = true,
    this.alignment = Alignment.center,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  final double pressedScale;
  final double pressedOpacity;

  final Duration downDuration;
  final Duration upDuration;
  final Curve downCurve;
  final Curve upCurve;

  final HitTestBehavior behavior;
  final bool enabled;
  final Alignment alignment;

  @override
  State<ScaleAlphaButton> createState() => _ScaleAlphaButtonState();
}

class _ScaleAlphaButtonState extends State<ScaleAlphaButton> {
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
    final opacity = _pressed ? widget.pressedOpacity : 1.0;

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
        child: AnimatedOpacity(
          opacity: opacity,
          duration: _pressed ? widget.downDuration : widget.upDuration,
          curve: _pressed ? widget.downCurve : Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}
