import 'package:dio/dio.dart';

import '../errors/api_error.dart';

/// 将ApiError异常类包装成DioException类
DioException wrapAsDio(ApiError apiError, RequestOptions ro, Response? resp) =>
    DioException(
      requestOptions: ro,
      response: resp,
      type: DioExceptionType.badResponse,
      error: apiError,
      message: apiError.message,
    );

DioException copyWithAppError(DioException err, ApiError apiError) =>
    DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: apiError,
      message: apiError.message,
      stackTrace: err.stackTrace,
    );

/// 取dio extras中的值
bool boolExtraByMap(Map<String, dynamic> extra, String key, bool def) {
  final v = extra.containsKey(key) ? extra[key] : null;
  return v is bool ? v : def;
}

int intExtraByMap(Map<String, dynamic> extra, String key, int def) {
  final v = extra.containsKey(key) ? extra[key] : null;
  return v is int ? v : def;
}
