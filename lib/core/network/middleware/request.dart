import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:ink_self_projects/core/network/shared/net_extra.dart';
import 'package:ink_self_projects/core/network/shared/public_data.dart';

import '../../../shared/tools/log.dart';
import '../shared/signature.dart';

typedef TokenProvider = FutureOr<String?> Function();
typedef UserIdProvider = FutureOr<String?> Function();
typedef ApiPrivateSignatureKeyProvider = FutureOr<String?> Function();

///
/// 请求拦截器，公共请求处理
///
class RequestMiddleware extends Interceptor {
  RequestMiddleware({
    required this.tokenProvider,
    required this.userIdProvider,
    required this.apiPrivateSignatureKeyProvider,
    required this.publicDataProvider,
    this.defaultLog = false,
    this.defaultAuth = true,
    this.defaultUserId = true,
  });

  final TokenProvider tokenProvider;
  final UserIdProvider userIdProvider;
  final ApiPrivateSignatureKeyProvider apiPrivateSignatureKeyProvider;

  final bool defaultLog;
  final bool defaultAuth;
  final bool defaultUserId;

  final PublicDataProvider publicDataProvider;

  static const String _userIdKey = 'user_id';
  static const String _paramsKey = 'params';
  static const String _publicKey = 'public';

  bool _hasNonEmpty(dynamic v) {
    if (v == null) return false;
    if (v is String) return v.trim().isNotEmpty;
    return v.toString().trim().isNotEmpty;
  }

  bool _alreadyHasUserId(RequestOptions options) {
    if (_hasNonEmpty(options.queryParameters[_userIdKey])) return true;

    final data = options.data;

    if (data is Map) {
      // 直接传 user_id
      if (_hasNonEmpty(data[_userIdKey])) return true;

      // 已经封装成 {public, params} 的情况
      final params = data[_paramsKey];
      if (params is Map && _hasNonEmpty(params[_userIdKey])) return true;
    }

    if (data is FormData) {
      final existed = data.fields.any(
        (e) => e.key == _userIdKey && e.value.trim().isNotEmpty,
      );
      if (existed) return true;
    }

    return false;
  }

  Future<void> _applyParams(RequestOptions options, bool needUserId) async {
    final isMultipartRequest =
        (options.contentType?.toLowerCase().startsWith('multipart/form-data') ??
            false) ||
        (options.data is FormData);

    // 已经带了 user_id 就不再取 uid、不再覆盖
    final shouldAddUserId = needUserId && !_alreadyHasUserId(options);

    String? uid;

    if (shouldAddUserId) {
      uid = await userIdProvider();
      if (uid == null || uid.trim().isEmpty) {
        throw StateError('needUserId=true but userIdProvider returned empty');
      }
    }

    // 生成 public + key（只算一次）
    final publicData = await _generatePublicData();
    final privateKey = (await apiPrivateSignatureKeyProvider()) ?? '';

    if (isMultipartRequest) {
      final form = (options.data is FormData)
          ? (options.data as FormData)
          : FormData();

      if (shouldAddUserId) {
        final hasUid = form.fields.any(
          (e) => e.key == _userIdKey && e.value.trim().isNotEmpty,
        );
        if (!hasUid) form.fields.add(MapEntry(_userIdKey, uid!));
      }

      final hasPublic = form.fields.any((e) => e.key == _publicKey);
      if (!hasPublic) {
        form.fields.add(MapEntry(_publicKey, jsonEncode(publicData)));
      }

      options.data = form;
      return;
    }

    final params = <String, dynamic>{};
    final data = options.data;

    if (data is Map) {
      final maybeParams = data[_paramsKey];
      if (data.containsKey(_publicKey) && maybeParams is Map) {
        params.addAll(
          Map<String, dynamic>.from(maybeParams.cast<String, dynamic>()),
        );
      } else {
        params.addAll(Map<String, dynamic>.from(data.cast<String, dynamic>()));
      }
    } else {
      if (shouldAddUserId) {
        options.queryParameters = {
          ...options.queryParameters,
          _userIdKey: uid!,
        };
      }
      Log.I(
        'DioClient Request',
        'body is ${data.runtimeType}, skip wrap(public/params/sig).',
      );
      return;
    }

    if (options.queryParameters.isNotEmpty) {
      params.addAll(options.queryParameters);
    }

    if (shouldAddUserId) {
      params[_userIdKey] = uid;
    }

    options.data = Signature.buildPayload(
      publicMap: publicData,
      paramsMap: params,
      privateKey: privateKey,
    );

    Log.I(
      'DioClient Request',
      'needUserId=true but body is ${data.runtimeType}, fallback user_id to query',
    );
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final extra = options.extra;

    final log = (extra[NetExtra.log] as bool?) ?? defaultLog;
    final auth = (extra[NetExtra.auth] as bool?) ?? defaultAuth;
    final needUserId = (extra[NetExtra.userId] as bool?) ?? defaultUserId;

    extra[NetExtra.log] = log;
    extra[NetExtra.auth] = auth;
    extra[NetExtra.userId] = needUserId;

    final hdr = extra[NetExtra.headers];
    if (hdr is Map) {
      options.headers.addAll(hdr.cast<String, dynamic>());
    }

    final rt = extra[NetExtra.responseType];
    if (rt is ResponseType) {
      options.responseType = rt;
    }

    if (log) {
      Log.I('DioClient Request', '${options.method}: ${options.uri}');
      Log.I('DioClient Request', 'Headers: ${options.headers}');
      Log.I('DioClient Request', 'Body: ${options.data}');
      Log.I('DioClient Request', 'Extra: ${options.extra}');
    }

    void applyTimeout(String key, void Function(Duration d) setter) {
      final ms = extra[key];
      if (ms is int && ms > 0) setter(Duration(milliseconds: ms));
    }

    applyTimeout(NetExtra.connectTimeoutMs, (d) => options.connectTimeout = d);
    applyTimeout(NetExtra.sendTimeoutMs, (d) => options.sendTimeout = d);
    applyTimeout(NetExtra.receiveTimeoutMs, (d) => options.receiveTimeout = d);

    if (auth) {
      final token = await tokenProvider();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    await _applyParams(options, needUserId);

    return handler.next(options);
  }

  Future<Map<String, dynamic>> _generatePublicData() async {
    final pd = await publicDataProvider.getPublicData();
    return pd.toMap(); // 自动带 nonce
  }
}
