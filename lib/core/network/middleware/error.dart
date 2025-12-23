import 'dart:math';

import 'package:dio/dio.dart';
import 'package:ink_self_projects/core/network/shared/tools.dart';
import 'package:ink_self_projects/shared/tools/log.dart';
import 'package:ink_self_projects/shared/tools/type_guard.dart';

import '../errors/api_error_mapper.dart';
import '../shared/net_extra.dart';

final _rng = Random();

///
/// 错误拦截器， 公共错误处理
///
class ErrorMiddleware extends Interceptor {
  ErrorMiddleware({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final normalized = copyWithAppError(err, ApiErrorMapper.fromDio(err));

    final ro = normalized.requestOptions;
    final extra = ro.extra;

    Log.E("Request Error", "${normalized.message}");

    // 若这是重试fetch导致的 error,直接透传给外层 while 循环.避免递归 onError
    if (extra[NetExtra.retrying] == true) {
      return handler.next(normalized);
    }

    // 读取retry策略
    final enableRetry = boolExtraByMap(extra, NetExtra.retryEnable, false);
    if (!enableRetry) return handler.next(normalized);

    final maxAttempts = intExtraByMap(
      extra,
      NetExtra.retryMaxAttempts,
      1,
    ); // 1 表示不重试
    if (maxAttempts <= 1) return handler.next(normalized);

    final methods =
        _stringList(extra[NetExtra.retryOnMethods]) ?? const ['GET', 'HEAD'];

    final statusCodes =
        _intList(extra[NetExtra.retryOnStatusCodes]) ??
        const [408, 429, 500, 502, 503, 504];

    final retryOnConnErr = boolExtraByMap(
      extra,
      NetExtra.retryOnConnectionError,
      true,
    );
    final useRetryAfter = boolExtraByMap(
      extra,
      NetExtra.retryUseRetryAfter,
      true,
    );

    final baseDelayMs = intExtraByMap(extra, NetExtra.retryBaseDelayMs, 300);
    final maxDelayMs = intExtraByMap(extra, NetExtra.retryMaxDelayMs, 3000);
    final jitterMs = intExtraByMap(extra, NetExtra.retryJitterMs, 150);

    // 方法白名单（默认只重试幂等方法）
    final method = ro.method.toUpperCase();
    if (!methods.contains(method)) return handler.next(normalized);

    // 判断是否可重试的错误
    final status = normalized.response?.statusCode;
    final retryableStatus = status != null && statusCodes.contains(status);

    final retryableConn = retryOnConnErr && _isRetryableDioError(normalized);

    final shouldRetry = retryableStatus || retryableConn;
    if (!shouldRetry) return handler.next(normalized);

    // 当前尝试次数（从 1 开始），首次失败时 attempt=1
    int attempt = intExtraByMap(extra, NetExtra.attempt, 1);

    // while 循环发起重试,避免interceptor递归
    DioException lastErr = normalized;
    Response? lastResp = normalized.response;

    while (attempt < maxAttempts) {
      // 计算 delay（优先 Retry-After，否则指数退避 + jitter）
      final delay = _computeRetryDelay(
        attempt: attempt,
        baseDelayMs: baseDelayMs,
        maxDelayMs: maxDelayMs,
        jitterMs: jitterMs,
        useRetryAfter: useRetryAfter,
        response: lastResp,
      );

      if (delay.inMilliseconds > 0) {
        await Future.delayed(delay);
      }

      // 尝试次数+1
      attempt += 1;
      extra[NetExtra.attempt] = attempt;

      extra[NetExtra.retrying] = true;

      // 如果上游 onRequest 包装过 {'public':..., 'params':...}，这里解包 params
      _unwrapParamsForRetry(ro);

      try {
        final resp = await _dio.fetch<dynamic>(ro);

        // 成功：直接 resolve
        extra.remove(NetExtra.retrying);
        extra.remove(NetExtra.attempt);
        return handler.resolve(resp);
      } on DioException catch (e) {
        // 继续下一轮 or 结束
        lastErr = copyWithAppError(e, ApiErrorMapper.fromDio(e));
        lastResp = lastErr.response;

        final s = lastResp?.statusCode;
        final canRetryMore =
            attempt < maxAttempts &&
            ((s != null && statusCodes.contains(s)) ||
                (retryOnConnErr && _isRetryableDioError(lastErr)));

        if (!canRetryMore) break;
        // else continue loop
      } finally {
        // 本轮结束清理 _retrying，让下一轮 fetch 再设置
        extra.remove(NetExtra.retrying);
      }
    }

    extra.remove(NetExtra.attempt);
    return handler.next(lastErr);
  }
}

List<String>? _stringList(Object? v) {
  if (TypeGuard.asListOf(v) case final list?)
    return list.map((e) => e.toString().toUpperCase()).toList();
  return null;
}

List<int>? _intList(Object? v) {
  if (TypeGuard.asListOf(v) case final list?) {
    final out = <int>[];
    for (final e in list) {
      final n = TypeGuard.asInt(e) ?? int.tryParse(e.toString());
      if (n != null) out.add(n);
    }
    return out;
  }
  return null;
}

Duration _computeRetryDelay({
  required int attempt, // 当前失败对应 attempt(从1开始)，即第 attempt 次尝试失败后要等多久再重试
  required int baseDelayMs,
  required int maxDelayMs,
  required int jitterMs,
  required bool useRetryAfter,
  required Response? response,
}) {
  if (useRetryAfter) {
    final ra = response?.headers.value('retry-after');
    final secs = int.tryParse((ra ?? '').trim());
    if (secs != null && secs >= 0) return Duration(seconds: secs);
  }

  // 指数退避：base * 2^(attempt-1)
  final exp = baseDelayMs * (1 << (attempt - 1));
  final capped = exp > maxDelayMs ? maxDelayMs : exp;

  // jitter：0..jitterMs
  final j = jitterMs <= 0 ? 0 : _rng.nextInt(jitterMs + 1);
  return Duration(milliseconds: capped + j);
}

void _unwrapParamsForRetry(RequestOptions ro) {
  if (TypeGuard.asMapOf(ro.data) case final data? when data['params'] != null) {
    ro.data = data['params'];
  }
}

bool _isRetryableDioError(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      return true;
    default:
      return false;
  }
}
