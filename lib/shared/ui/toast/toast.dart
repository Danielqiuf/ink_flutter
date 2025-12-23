import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class Toast {
  Toast({required GlobalKey<OverlayState> overlayKey})
    : _overlayKey = overlayKey;

  final GlobalKey<OverlayState> _overlayKey;

  OverlayEntry? _currentEntry;
  _ToastEntryController? _currentController;

  _ToastRequest? _nextLatest;

  bool get _isShowing => _currentEntry != null;

  /// 语义：
  /// - show 时如果已有 toast：立即触发当前 toast 退场动画
  /// - 退场动画结束后：显示最新那条（中间的会被覆盖）
  void show(String message, {Duration duration = const Duration(seconds: 2)}) {
    final m = message.trim();
    if (m.isEmpty) return;

    _nextLatest = _ToastRequest(message: m, duration: duration);

    if (!_isShowing) {
      _consumeNextAndShow();
      return;
    }

    // 每次 show 都尝试让当前 toast 退场
    // _ToastView 内部会用 _isDismissing 幂等，重复调用没副作用
    _currentController?.dismiss();
  }

  void hideCurrent() => _currentController?.dismiss();

  void clearAll() {
    _nextLatest = null;
    hideCurrent();
  }

  // ---------------- internals ----------------

  void _consumeNextAndShow() {
    final req = _nextLatest;
    if (req == null) return;
    _nextLatest = null;
    _displayNow(req);
  }

  Future<void> _displayNow(_ToastRequest req) async {
    // overlay 可能还没 ready
    final overlay = _overlayKey.currentState;
    if (overlay == null) await _waitNextFrame();
    final realOverlay = _overlayKey.currentState;
    if (realOverlay == null) return;

    final done = Completer<void>();
    final controller = _ToastEntryController(
      onDone: () {
        if (!done.isCompleted) done.complete();
      },
    );
    _currentController = controller;

    final entry = OverlayEntry(
      builder: (context) => _ToastView(
        message: req.message,
        duration: req.duration,
        controller: controller,
      ),
    );

    _currentEntry = entry;
    realOverlay.insert(entry);

    // 等待退场动画结束
    await done.future;

    _removeCurrentEntry();

    // 如果退场期间又 show 了新的，继续显示最新
    _consumeNextAndShow();
  }

  void _removeCurrentEntry() {
    _currentEntry?.remove();
    _currentEntry = null;
    _currentController = null;
  }

  Future<void> _waitNextFrame() async {
    final c = Completer<void>();
    SchedulerBinding.instance.addPostFrameCallback((_) => c.complete());
    return c.future;
  }
}

class _ToastRequest {
  _ToastRequest({required this.message, required this.duration});
  final String message;
  final Duration duration;
}

class _ToastEntryController {
  _ToastEntryController({required this.onDone});

  final VoidCallback onDone;
  VoidCallback? _dismiss;
  bool _done = false;

  void _bindDismiss(VoidCallback dismiss) => _dismiss = dismiss;

  void dismiss({bool immediate = false}) {
    _dismiss?.call();
    if (immediate) _finishOnce();
  }

  void _finishOnce() {
    if (_done) return;
    _done = true;
    onDone();
  }
}

class _ToastView extends StatefulWidget {
  const _ToastView({
    required this.message,
    required this.duration,
    required this.controller,
  });

  final String message;
  final Duration duration;
  final _ToastEntryController controller;

  @override
  State<_ToastView> createState() => _ToastViewState();
}

class _ToastViewState extends State<_ToastView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;

  Timer? _timer;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();

    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
      reverseDuration: const Duration(milliseconds: 110),
    );

    _opacity = CurvedAnimation(
      parent: _ac,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    _scale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _ac,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeInBack,
      ),
    );

    widget.controller._bindDismiss(_dismiss);

    _ac.forward();
    _timer = Timer(widget.duration, _dismiss);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ac.dispose();
    super.dispose();
  }

  void _dismiss() {
    if (_isDismissing) return;
    _isDismissing = true;

    _timer?.cancel();
    try {
      _ac.reverse().whenComplete(() => widget.controller._finishOnce());
    } catch (_) {
      widget.controller._finishOnce();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;
    final maxW = screenW * 0.6;

    return IgnorePointer(
      ignoring: true,
      child: Material(
        type: MaterialType.transparency,
        child: Center(
          child: AnimatedBuilder(
            animation: _ac,
            builder: (_, __) {
              return Opacity(
                opacity: _opacity.value,
                child: Transform.scale(
                  scale: _scale.value,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxW),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          color: Colors.white,
                          height: 1.25,
                        ),
                        textAlign: TextAlign.center,
                        softWrap: true,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
