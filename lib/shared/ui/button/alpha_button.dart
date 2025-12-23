import 'package:flutter/material.dart';

///
/// 透明度按钮：按下变淡（Opacity）
///
class AlphaButton extends StatefulWidget {
  const AlphaButton({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.pressedOpacity = 0.85,
    this.downDuration = const Duration(milliseconds: 60),
    this.upDuration = const Duration(milliseconds: 120),
    this.curve = Curves.easeOut,
    this.behavior = HitTestBehavior.opaque,
    this.enabled = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// 按下时透明度（0~1）
  final double pressedOpacity;

  final Duration downDuration;
  final Duration upDuration;
  final Curve curve;

  final HitTestBehavior behavior;
  final bool enabled;

  @override
  State<AlphaButton> createState() => _AlphaButtonState();
}

class _AlphaButtonState extends State<AlphaButton> {
  bool _pressed = false;

  bool get _isEnabled =>
      widget.enabled && (widget.onTap != null || widget.onLongPress != null);

  void _setPressed(bool v) {
    if (_pressed == v) return;
    setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final opacity = _pressed ? widget.pressedOpacity : 1.0;

    return GestureDetector(
      behavior: widget.behavior,
      onTap: _isEnabled ? widget.onTap : null,
      onLongPress: _isEnabled ? widget.onLongPress : null,
      onTapDown: _isEnabled ? (_) => _setPressed(true) : null,
      onTapUp: _isEnabled ? (_) => _setPressed(false) : null,
      onTapCancel: _isEnabled ? () => _setPressed(false) : null,
      child: AnimatedOpacity(
        opacity: opacity,
        duration: _pressed ? widget.downDuration : widget.upDuration,
        curve: widget.curve,
        child: widget.child,
      ),
    );
  }
}
