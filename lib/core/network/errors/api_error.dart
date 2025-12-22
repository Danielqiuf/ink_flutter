import 'api_error_type.dart';

class ApiError implements Exception {
  ApiError(
    this.type, {
    this.code,
    required this.message,
    this.raw,
    this.silent = false,
  });

  final ApiErrorType type;
  final int? code; // http code 或业务 code
  final String message; // 给 UI 的人类可读文案
  final bool silent; // 可忽略的异常
  final Object? raw; // 原始异常/response（用于日志）
}
