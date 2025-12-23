import 'package:dio/dio.dart';
import 'package:ink_self_projects/core/network/contains/api_business_code.dart';

import 'api_error.dart';
import 'api_error_type.dart';
import 'locale_http_error_message.dart';

class ApiErrorMapper {
  static ApiError fromDio(DioException e) {
    // 拦截器已生成过 ApiError 就直接用
    final existing = e.error;
    if (existing is ApiError) return existing;

    switch (e.type) {
      case DioExceptionType.cancel:
        return ApiError(ApiErrorType.cancelled, message: '请求已取消', raw: e);
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiError(ApiErrorType.timeout, message: '请求超时，请稍后重试', raw: e);
      case DioExceptionType.connectionError:
        return ApiError(ApiErrorType.offline, message: '网络不可用，请检查网络', raw: e);
      default:
        break;
    }

    final r = e.response;
    if (r != null) return fromResponse(r, raw: e);

    return ApiError(ApiErrorType.unknown, message: '未知错误', raw: e);
  }

  static ApiError fromResponse(Response r, {Object? raw}) {
    final httpCode = r.statusCode;

    // 非 2xx 的 HTTP 错
    if (httpCode == null || httpCode < 200 || httpCode >= 300) {
      return ApiError(
        ApiErrorType.http,
        code: httpCode,
        message: localeHttpMessageMapper[httpCode]!,
        raw: raw ?? r,
      );
    }

    final data = r.data;
    if (data is Map<String, dynamic>) {
      final code = data['code'];
      final msg = (data['msg'] as String?) ?? localeHttpMessageMapper[code]!;

      if (code is int) {
        // token失效
        if (isTokenInvalid(code)) {
          return ApiError(
            ApiErrorType.auth,
            code: code,
            message: msg,
            raw: raw ?? r,
          );
        }
        // 账号背封禁
        if (code == ApiBusinessCode.suspectedAccount) {
          return ApiError(
            ApiErrorType.banned,
            code: code,
            message: msg,
            raw: raw ?? r,
          );
        }
        // 异地登陆被挤下线
        if (code == ApiBusinessCode.loggedOtherDevices) {
          return ApiError(
            ApiErrorType.otherDevice,
            code: code,
            message: msg,
            raw: raw ?? r,
          );
        }

        // 静默
        final silent = isSilent(code);

        return ApiError(
          ApiErrorType.business,
          code: code,
          message: msg,
          silent: silent,
          raw: raw ?? r,
        );
      }
    }

    return ApiError(
      ApiErrorType.unknown,
      message: 'Unknown Error.',
      raw: raw ?? r,
    );
  }
}
