import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class Toast {
  Toast({required GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey})
    : _key = scaffoldMessengerKey;

  final GlobalKey<ScaffoldMessengerState> _key;

  final Queue<_ToastRequest> _queue = Queue<_ToastRequest>();
  bool _isFlushing = false;

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

  void hideCurrent() {
    _key.currentState?.hideCurrentSnackBar();
  }

  void clearAll() {
    _queue.clear();
    _key.currentState?.clearSnackBars();
  }

  void _flush() {
    if (_isFlushing) return;
    _isFlushing = true;

    Future<void>(() async {
      while (_queue.isNotEmpty) {
        final req = _queue.removeFirst();

        // 如果 UI 还没 ready（MaterialApp 尚未挂载 scaffoldMessengerKey）
        // 就等下一帧再试
        final messenger = _key.currentState;
        if (messenger == null) {
          await _waitNextFrame();
          // 重新塞回队列头部，保证不丢
          _queue.addFirst(req);
          continue;
        }

        if (req.replaceCurrent) {
          messenger.hideCurrentSnackBar();
          messenger.removeCurrentSnackBar();
        }

        final snackBar = _buildSnackBar(req);
        final controller = messenger.showSnackBar(snackBar);

        // 等这个toast结束再显示下一个
        try {
          await controller.closed;
        } catch (_) {
          // ignore
        }
      }
    }).whenComplete(() {
      _isFlushing = false;
    });
  }

  SnackBar _buildSnackBar(_ToastRequest req) {
    return SnackBar(
      duration: req.duration,
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      backgroundColor: Colors.black87,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: Expanded(
        child: Text(
          req.message,
          style: const TextStyle(color: Colors.white),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Future<void> _waitNextFrame() async {
    final completer = Completer<void>();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      completer.complete();
    });
    return completer.future;
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
