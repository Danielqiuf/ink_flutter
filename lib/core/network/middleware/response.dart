import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:ink_self_projects/core/di/container_provider.dart';
import 'package:ink_self_projects/core/network/contains/api_business_code.dart';
import 'package:ink_self_projects/core/network/shared/net_extra.dart';
import 'package:ink_self_projects/core/network/shared/tools.dart';
import 'package:ink_self_projects/shared/tools/type_guard.dart';
import 'package:ink_self_projects/shared/ui/toast/toast_provider.dart';

import '../../../shared/tools/log.dart';
import '../contains/api_http_code.dart';
import '../errors/api_error.dart';
import '../errors/api_error_mapper.dart';

///
/// 响应拦截器，公共响应处理
///
class ResponseMiddleware extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final extra = response.requestOptions.extra;
    final log = boolExtraByMap(extra, NetExtra.log, false);

    if (log) {
      Log.D(
        "DioClient Response",
        "${response.statusCode}: ${response.realUri}",
      );
      Log.D("DioClient Response", "Data: ${jsonEncode(response.data)}");
    }

    if (response.statusCode == null ||
        response.statusCode != ApiHttpCode.success) {
      final ApiError apiError = ApiErrorMapper.fromResponse(
        response,
        raw: response,
      );
      showToastIfNeeded(apiError.message, extra: extra);

      return handler.reject(
        wrapAsDio(apiError, response.requestOptions, response),
      );
    }

    final data = response.data;

    if (data is! Map<String, dynamic>) {
      return handler.next(response);
    }

    final code = TypeGuard.asInt(data['code']) ?? -1;

    if (code == ApiBusinessCode.success) {
      return handler.next(response);
    }

    final apiError = ApiErrorMapper.fromResponse(response, raw: data);

    /// 静默错误，直接reject
    if (apiError.silent) {
      return handler.reject(
        wrapAsDio(apiError, response.requestOptions, response),
      );
    }

    // token失效判断
    if (isTokenInvalid(code)) {
      showToastIfNeeded(apiError.message, extra: extra);
      return handler.next(response);
    }

    final bool passUserBannedHandler = boolExtraByMap(
      extra,
      NetExtra.passByUserBanned,
      false,
    );
    final bool passUserLoginOtherHandler = boolExtraByMap(
      extra,
      NetExtra.passByUserLogged,
      false,
    );

    showToastIfNeeded(apiError.message, extra: extra);

    // 封禁账户
    if (code == ApiBusinessCode.suspectedAccount && !passUserBannedHandler) {
      final bool passSuspectedAccountProcess = boolExtraByMap(
        extra,
        NetExtra.passByUserBannedProcessing,
        false,
      );
      if (!passSuspectedAccountProcess) {
        /// @TODO 封禁账户处理
      } else {
        return handler.next(response);
      }
    }

    // 异地登录
    if (code == ApiBusinessCode.loggedOtherDevices &&
        !passUserLoginOtherHandler) {
      /// @TODO 异地登录处理
    }

    // 普通业务错误
    response.statusMessage = apiError.message;

    return handler.reject(
      wrapAsDio(apiError, response.requestOptions, response),
    );
  }
}

void showToastIfNeeded(String message, {required Map<String, dynamic> extra}) {
  final bool toastEnable = boolExtraByMap(extra, NetExtra.toast, true);

  if (!toastEnable) return;

  container.read(toastProvider).show(message);
}
