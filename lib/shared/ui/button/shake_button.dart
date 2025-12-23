import 'package:flutter/material.dart';

///
/// 轻微抖动按钮：常用于“不可用/校验失败提示”（Shake）
///
class ShakeButton extends StatefulWidget {
  const ShakeButton({
    super.key,
    required this.child,
    required this.onTap,
    this.enabled = true,
    this.shakeDistance = 6,
    this.shakeCount = 2,
    this.duration = const Duration(milliseconds: 320),
    this.curve = Curves.easeOut,
    this.behavior = HitTestBehavior.opaque,
    this.triggerShakeWhenTap = false,
  });

  final Widget child;
  final VoidCallback onTap;

  /// 正常是否可点；若 false，会触发 shake（常用来提示“先填完再点”）
  final bool enabled;

  final double shakeDistance;
  final int shakeCount;
  final Duration duration;
  final Curve curve;
  final HitTestBehavior behavior;

  /// true：每次点击都 shake（不常用）
  /// false：只有 enabled==false 时 shake（推荐）
  final bool triggerShakeWhenTap;

  @override
  State<ShakeButton> createState() => _ShakeButtonState();
}

class _ShakeButtonState extends State<ShakeButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _dx;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.duration);

    // 0 -> +d -> -d -> +d -> 0
    _dx = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0, end: widget.shakeDistance),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: widget.shakeDistance, end: -widget.shakeDistance),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -widget.shakeDistance, end: widget.shakeDistance),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween(begin: widget.shakeDistance, end: 0),
        weight: 1,
      ),
    ]).animate(CurvedAnimation(parent: _c, curve: widget.curve));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _shake() async {
    if (_c.isAnimating) return;
    await _c.forward(from: 0);
  }

  void _handleTap() {
    if (widget.enabled) {
      if (widget.triggerShakeWhenTap) _shake();
      widget.onTap();
    } else {
      _shake();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: widget.behavior,
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _dx,
        builder: (_, child) =>
            Transform.translate(offset: Offset(_dx.value, 0), child: child),
        child: widget.child,
      ),
    );
  }
}
