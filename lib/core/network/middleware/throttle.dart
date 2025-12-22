import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:ink_self_projects/core/network/shared/net_extra.dart';
import 'package:ink_self_projects/core/network/shared/tools.dart';

import '../../../shared/tools/log.dart';

///
/// 请求节流，
///
class ThrottleMiddleware extends Interceptor {
  final Map<String, int> _lastAllowedMs = HashMap(); // 最近一次放行时间
  final Map<String, Future<void>> _chain = HashMap(); // 同 key 的串行链

  // 防重放到重试请求之间的时间差
  final int replayDelayMs = 200;

  int? _lastSweepMs;

  static const int throttleDelayDuration = 800;

  // lastAllowed 设置一个生存期（TTL），过期就移除，避免地图无限增长
  int get _ttlMs => throttleDelayDuration * 10;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final bool throttleEnable = boolExtraByMap(
      options.extra,
      NetExtra.throttle,
      true,
    );

    if (!throttleEnable) {
      return handler.next(options);
    }

    final key = _generateRequestKey(options);
    final now = DateTime.now().millisecondsSinceEpoch;
    final windowMs = throttleDelayDuration;

    // 过期键的快速清理避免冷门 key 长期驻留
    _maybeSweep(now);

    // 防重放，窗口内重复请求不再抛异常，而是延迟 200ms 后再进入节流队列
    final last = _lastAllowedMs[key];

    if (last != null && now - last < windowMs) {
      Log.E("Throttle", '防重放 --- ${options.uri}');
      await _awaitSlot(key, windowMs, extraDelayMs: replayDelayMs);
      handler.next(options);
      return;
    }

    // 节流串行
    final previous = _chain[key];
    final myTurn = (previous ?? Future.value()).then((_) async {
      final t = _lastAllowedMs[key];
      final now2 = DateTime.now().millisecondsSinceEpoch;
      final gap = (t == null) ? 0 : (windowMs - (now2 - t));
      if (gap > 0) await Future.delayed(Duration(milliseconds: gap));
      _lastAllowedMs[key] = DateTime.now().millisecondsSinceEpoch; // 真正放行的时间
    });

    _chain[key] = myTurn.whenComplete(() {
      if (identical(_chain[key], myTurn)) _chain.remove(key);
    });

    await myTurn;
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _cleanupIfIdle(_generateRequestKey(response.requestOptions));
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _cleanupIfIdle(_generateRequestKey(err.requestOptions));
    handler.next(err);
  }

  Future<void> _awaitSlot(String key, int windowMs, {int extraDelayMs = 0}) {
    final previous = _chain[key];
    final myTurn = (previous ?? Future.value()).then((_) async {
      // 命中防重放时的固定额外等待
      if (extraDelayMs > 0) {
        await Future.delayed(Duration(milliseconds: extraDelayMs));
      }
      // 确保与上次放行的最小间隔
      final t = _lastAllowedMs[key];
      final now2 = DateTime.now().millisecondsSinceEpoch;
      final gap = (t == null) ? 0 : (windowMs - (now2 - t));
      if (gap > 0) await Future.delayed(Duration(milliseconds: gap));
      _lastAllowedMs[key] = DateTime.now().millisecondsSinceEpoch; // 真正放行的时间
    });

    _chain[key] = myTurn.whenComplete(() {
      if (identical(_chain[key], myTurn)) _chain.remove(key);
    });

    return myTurn;
  }

  void _cleanupIfIdle(String key) {
    // 链上没人等我，且超过 TTL 就移除 lastAllowed
    if (!_chain.containsKey(key)) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final last = _lastAllowedMs[key];
      if (last != null && now - last >= _ttlMs) {
        _lastAllowedMs.remove(key);
      }
    }
  }

  void _maybeSweep(int now) {
    if (_lastSweepMs != null && now - _lastSweepMs! < _ttlMs) return;
    _lastSweepMs = now;
    // 只扫少量，避免大 map 时卡顿；这里全扫也行，量通常很小
    final expired = <String>[];
    _lastAllowedMs.forEach((k, t) {
      if (now - t >= _ttlMs && !_chain.containsKey(k)) expired.add(k);
    });
    for (final k in expired) {
      _lastAllowedMs.remove(k);
    }
  }
}

String _generateRequestKey(RequestOptions options) =>
    '${options.method}:${options.uri}';
