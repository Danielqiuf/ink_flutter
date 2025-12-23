import 'package:flutter/material.dart';

///
/// 阴影/压扁按钮：按下的质感（Elevation）
///
class ElevationButton extends StatefulWidget {
  const ElevationButton({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.color = Colors.transparent,
    this.shadowColor = const Color(0x33000000),
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.elevation = 10,
    this.pressedElevation = 2,
    this.pressedScale = 0.985,
    this.duration = const Duration(milliseconds: 120),
    this.curve = Curves.easeOut,
    this.behavior = HitTestBehavior.opaque,
    this.enabled = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  final Color color;
  final Color shadowColor;
  final BorderRadius borderRadius;

  final double elevation;
  final double pressedElevation;
  final double pressedScale;

  final Duration duration;
  final Curve curve;

  final HitTestBehavior behavior;
  final bool enabled;

  @override
  State<ElevationButton> createState() => _ElevationButtonState();
}

class _ElevationButtonState extends State<ElevationButton> {
  bool _pressed = false;

  bool get _isEnabled =>
      widget.enabled && (widget.onTap != null || widget.onLongPress != null);

  void _setPressed(bool v) {
    if (_pressed == v) return;
    setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final e = _pressed ? widget.pressedElevation : widget.elevation;
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
        duration: widget.duration,
        curve: widget.curve,
        child: AnimatedContainer(
          duration: widget.duration,
          curve: widget.curve,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: widget.borderRadius,
            boxShadow: [
              BoxShadow(
                color: widget.shadowColor,
                blurRadius: e,
                spreadRadius: 0,
                offset: Offset(0, e * 0.35),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: widget.borderRadius,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
