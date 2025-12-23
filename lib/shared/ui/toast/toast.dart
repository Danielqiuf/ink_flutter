import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class Toast {
  Toast({required GlobalKey<OverlayState> overlayKey})
    : _overlayKey = overlayKey;

  final GlobalKey<OverlayState> _overlayKey;

  final Queue<_ToastRequest> _queue = Queue<_ToastRequest>();
  bool _isFlushing = false;

  OverlayEntry? _currentEntry;
  _ToastEntryController? _currentController;

  void show(
    String message, {
    Duration duration = const Duration(seconds: 2),
    bool replaceCurrent = true,
  }) {
    if (message.trim().isEmpty) return;

    _queue.add(
      _ToastRequest(
        message: message,
        duration: duration,
        replaceCurrent: replaceCurrent,
      ),
    );
    _flush();
  }

  void hideCurrent() => _currentController?.dismiss();

  void clearAll() {
    _queue.clear();
    hideCurrent();
  }

  void _flush() {
    if (_isFlushing) return;
    _isFlushing = true;

    Future<void>(() async {
      while (_queue.isNotEmpty) {
        final req = _queue.removeFirst();

        final overlay = _overlayKey.currentState;
        if (overlay == null) {
          await _waitNextFrame();
          _queue.addFirst(req);
          continue;
        }

        if (req.replaceCurrent) {
          _currentController?.dismiss(immediate: true);
          _removeCurrentEntry();
        }

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
        overlay.insert(entry);

        await done.future;
        _removeCurrentEntry();
      }
    }).whenComplete(() => _isFlushing = false);
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
  _ToastRequest({
    required this.message,
    required this.duration,
    required this.replaceCurrent,
  });
  final String message;
  final Duration duration;
  final bool replaceCurrent;
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
      duration: const Duration(milliseconds: 220),
      reverseDuration: const Duration(milliseconds: 180),
    );

    _opacity = CurvedAnimation(
      parent: _ac,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    // 轻微“弹簧”：进场 easeOutBack / 退场 easeInBack
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
