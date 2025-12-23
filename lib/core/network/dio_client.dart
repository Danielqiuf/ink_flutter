import 'package:dio/dio.dart';

///
/// Dio Client
///
class DioClient {
  DioClient._(this.dio);

  final Dio dio;

  ///
  /// 创建dio实例
  ///
  static DioClient create({
    required String host,
    String? basePath,
    Duration connectTimeout = const Duration(seconds: 15),
    Duration receiveTimeout = const Duration(seconds: 15),
    Duration sendTimeout = const Duration(seconds: 20),
    Map<String, String> defaultHeaders = const {},
  }) {
    final BaseOptions options = BaseOptions(
      baseUrl: basePath == null ? host : _joinUrl(host, basePath),
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      contentType: Headers.jsonContentType,
      headers: {'Accept': 'application/json', ...defaultHeaders},
      responseType: ResponseType.json,
      validateStatus: (code) => code != null && code >= 200 && code < 300,
    );

    final dio = Dio(options);

    return DioClient._(dio);
  }

  static String _joinUrl(String host, String path) {
    if (host.endsWith('/') && path.startsWith('/')) {
      return host.substring(0, host.length - 1) + path;
    }
    if (!host.endsWith('/') && !path.startsWith('/')) {
      return '$host/$path';
    }
    return host + path;
  }
}
