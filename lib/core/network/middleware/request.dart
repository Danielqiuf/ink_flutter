import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:ink_self_projects/core/network/shared/net_extra.dart';
import 'package:ink_self_projects/core/network/shared/public_data.dart';
import 'package:ink_self_projects/core/network/shared/tools.dart';
import 'package:ink_self_projects/shared/tools/type_guard.dart';

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

    if (TypeGuard.asMapOf<String, dynamic>(options.data) case final data?) {
      // 直接传 user_id
      if (_hasNonEmpty(data[_userIdKey])) return true;

      // 已经封装成 {public, params} 的情况

      if (TypeGuard.asMapOf<String, dynamic>(data[_paramsKey])
          case final params? when _hasNonEmpty(params[_userIdKey]))
        return true;
    }

    if (options.data is FormData) {
      final existed = options.data.fields.any(
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

    if (data == null) {
      if (shouldAddUserId) params[_userIdKey] = uid;
      if (options.queryParameters.isNotEmpty) {
        params.addAll(options.queryParameters);
      }

      options.data = Signature.buildPayload(
        publicMap: publicData,
        paramsMap: params,
        privateKey: privateKey,
      );
      return;
    }

    Log.I(
      'DioClient Request',
      'needUserId=true but body is ${data.runtimeType}, fallback user_id to query',
    );

    if (TypeGuard.asMapOf<String, dynamic>(data) case final d?) {
      final map = Map<String, dynamic>.from(d);

      // 老逻辑：如果已经是 {public:..., params:...}，就取 params 继续追加
      final maybeParams = map[_paramsKey];
      if (TypeGuard.asMapOf<String, dynamic>(maybeParams) case final mp?
          when map.containsKey(_publicKey)) {
        params.addAll(mp);
      } else {
        // 否则把整个 body 当作 params
        params.addAll(map);
      }

      // query 合并进 params
      if (options.queryParameters.isNotEmpty) {
        params.addAll(options.queryParameters);
      }

      if (shouldAddUserId) {
        // body 里没 uid 才加（前面 shouldAddUserId 已保证不覆盖）
        params[_userIdKey] = uid;
      }

      options.data = Signature.buildPayload(
        publicMap: publicData,
        paramsMap: params,
        privateKey: privateKey,
      );
      return;
    }

    if (shouldAddUserId) {
      options.queryParameters = {...options.queryParameters, _userIdKey: uid!};
    }
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final extra = options.extra;

    final log = boolExtraByMap(extra, NetExtra.log, defaultLog);
    final auth = boolExtraByMap(extra, NetExtra.auth, defaultAuth);
    final needUserId = boolExtraByMap(extra, NetExtra.userId, defaultUserId);

    extra[NetExtra.log] = log;
    extra[NetExtra.auth] = auth;
    extra[NetExtra.userId] = needUserId;

    final hdr = extra[NetExtra.headers];
    if (TypeGuard.asMapOf<String, dynamic>(hdr) case final hdrr?) {
      options.headers.addAll(hdrr);
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
      if (TypeGuard.asInt(extra[key]) case final ms? when ms > 0)
        setter(Duration(milliseconds: ms));
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
