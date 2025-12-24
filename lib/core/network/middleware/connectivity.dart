import 'package:dio/dio.dart';
import 'package:ink_self_projects/core/di/container_provider.dart';
import 'package:ink_self_projects/core/network/errors/api_error.dart';
import 'package:ink_self_projects/core/network/errors/api_error_type.dart';
import 'package:ink_self_projects/core/network/shared/net_extra.dart';
import 'package:ink_self_projects/core/network/shared/tools.dart';
import 'package:ink_self_projects/shared/ui/toast/toast_provider.dart';

import '../../../__locale.g__/translations.g.dart';
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
      final ApiError apiError = ApiError(
        ApiErrorType.offline,
        message: t.networkErrors.networkOffline,
      );
      final toast = boolExtraByMap(options.extra, NetExtra.toast, true);

      if (toast) container.read(toastProvider).show(apiError.message);

      return handler.reject(wrapAsDio(apiError, options, null));
    }

    handler.next(options);
  }
}
