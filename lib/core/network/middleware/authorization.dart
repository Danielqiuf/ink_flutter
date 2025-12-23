import 'dart:async';

import 'package:dio/dio.dart';
import 'package:ink_self_projects/core/network/contains/api_business_code.dart';
import 'package:ink_self_projects/core/network/shared/net_extra.dart';
import 'package:ink_self_projects/core/network/shared/tools.dart';
import 'package:ink_self_projects/shared/tools/log.dart';

///
/// Token时效性验证 (Token过期刷新)
///
class AuthorizationMiddleware extends Interceptor {
  AuthorizationMiddleware({
    required Dio dio,
    Future<void> Function()? refreshToken,
    bool Function(RequestOptions options)? skipWhen,
    int maxRetry = 1,
  }) : _dio = dio,
       _refreshToken = refreshToken ?? _defaultRefreshToken,
       _skipWhen = skipWhen ?? _defaultSkipWhen,
       _maxRetry = maxRetry;

  final Dio _dio;

  /// 外部注入：真正的 refresh token 逻辑（内部应把新 token 写入你的存储里）。
  final Future<void> Function() _refreshToken;

  /// 外部注入：哪些请求需要跳过（例如 refresh/login 自己、或明确不需要鉴权的接口）。
  final bool Function(RequestOptions options) _skipWhen;

  /// 每个请求最多触发几次「刷新 + 重试」。
  final int _maxRetry;

  Completer<void>? _refreshCompleter;

  static const String _kAuthRetryCount = '__auth_retry_count__';

  static bool _defaultSkipWhen(RequestOptions options) {
    // 未开启 auth 的请求，不处理
    final auth = boolExtraByMap(options.extra, NetExtra.auth, true);
    if (!auth) return true;

    //被显式标记为 kickAuth 的请求，不处理（用于避免重试死循环 & 给 refresh/login 自己跳过）
    final kickAuth = boolExtraByMap(options.extra, NetExtra.kickAuth, false);
    if (kickAuth) return true;

    return false;
  }

  static Future<void> _defaultRefreshToken() async {
    "开始_refreshToken---".li();
    // TODO: 用真实的 refresh token API 替换，并在成功后写入新的 access token
    await Future.delayed(const Duration(milliseconds: 700));
  }

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    final ro = response.requestOptions;

    if (_skipWhen(ro)) return handler.next(response);

    "token refresh 过期..".lw();
    // 业务 code token 失效（常见：HTTP 200 但 code 表示 token 过期）
    final bizCode = _extractBizCode(response.data);
    if (bizCode == null || !isTokenInvalid(bizCode)) {
      return handler.next(response);
    }

    // 防止死循环：每个请求最多重试 _maxRetry 次
    final retryCount = (ro.extra[_kAuthRetryCount] as int?) ?? 0;
    if (retryCount >= _maxRetry) return handler.next(response);

    try {
      await _ensureRefreshed();
    } catch (_) {
      // 刷新失败：把当前 token 失效响应交给下游（通常会触发重新登录）
      return handler.next(response);
    }

    // 刷新成功：重试原请求（并标记本次请求不再触发 auth 处理）
    ro.extra[_kAuthRetryCount] = retryCount + 1;
    ro.extra[NetExtra.kickAuth] = true;

    _unwrapParamsForRetry(ro);

    try {
      final resp = await _dio.fetch<dynamic>(ro);
      return handler.next(resp);
    } on DioException catch (e) {
      return handler.reject(e);
    }
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final ro = err.requestOptions;
    if (_skipWhen(ro)) return handler.next(err);

    // HTTP 401/403（validateStatus 仅允许 2xx 时，会走到这里）
    final status = err.response?.statusCode;
    final httpUnauthorized = status == 401 || status == 403;

    // 少数情况下 validateStatus 允许非 2xx，也可能在 error 中带业务 code
    final bizCode = _extractBizCode(err.response?.data);

    final shouldHandle =
        httpUnauthorized || (bizCode != null && isTokenInvalid(bizCode));
    if (!shouldHandle) return handler.next(err);

    final retryCount = (ro.extra[_kAuthRetryCount] as int?) ?? 0;
    if (retryCount >= _maxRetry) return handler.next(err);

    try {
      await _ensureRefreshed();
    } catch (_) {
      // 刷新失败：透传原错误（一般会被统一错误处理引导去登录）
      return handler.next(err);
    }

    ro.extra[_kAuthRetryCount] = retryCount + 1;
    ro.extra[NetExtra.kickAuth] = true;

    _unwrapParamsForRetry(ro);

    try {
      final resp = await _dio.fetch<dynamic>(ro);
      return handler.resolve(resp);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }

  Future<void> _ensureRefreshed() async {
    // 已经在刷新中：等待同一个 future
    final existing = _refreshCompleter;
    if (existing != null) return existing.future;

    final completer = Completer<void>();
    _refreshCompleter = completer;

    try {
      await _refreshToken();
      completer.complete();
      return completer.future;
    } catch (e, st) {
      completer.completeError(e, st);
      rethrow;
    } finally {
      _refreshCompleter = null;
    }
  }

  static int? _extractBizCode(dynamic data) {
    if (data is Map) {
      final v = data['code'];
      if (v is int) return v;
      if (v is String) return int.tryParse(v);
    }
    return null;
  }

  static void _unwrapParamsForRetry(RequestOptions ro) {
    final data = ro.data;
    if (data is Map && data['params'] != null) {
      ro.data = data['params'];
    }
  }
}
