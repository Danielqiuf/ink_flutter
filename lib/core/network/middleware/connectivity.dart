import 'package:dio/dio.dart';
import 'package:ink_self_projects/core/network/errors/api_error.dart';
import 'package:ink_self_projects/core/network/errors/api_error_type.dart';
import 'package:ink_self_projects/core/network/shared/tools.dart';

import '../../../shared/tools/connectivity.dart';

///
/// 接口网络状态验证 (发起请求前网络导致的问题就抛异常)
///
class ConnectivityMiddleware extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!await isNetworkConnected()) {
      return handler.reject(
        wrapAsDio(
          ApiError(ApiErrorType.offline, message: "Network offline"),
          options,
          null,
        ),
      );
    }

    handler.next(options);
  }
}
