import 'dart:io';

///
/// 拦截器中间件
///

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink_self_projects/apis/api_hub.dart';
import 'package:ink_self_projects/core/di/env_provider.dart';
import 'package:ink_self_projects/core/network/shared/public_data.dart';
import 'package:ink_self_projects/locale/translations.g.dart';
import 'package:ink_self_projects/shared/tools/device.dart';

import '../network/dio_client.dart';
import '../network/middleware/authorization.dart';
import '../network/middleware/connectivity.dart';
import '../network/middleware/error.dart';
import '../network/middleware/request.dart';
import '../network/middleware/response.dart';
import '../network/middleware/throttle.dart';

///
/// Dio Provider
///
final dioProvider = Provider<Dio>((ref) {
  final env = ref.read(envProvider);
  final dio = DioClient.create(host: env.apiBaseUrl).dio;

  dio.interceptors
    ..add(ConnectivityMiddleware())
    ..add(
      RequestMiddleware(
        tokenProvider: () => "",
        userIdProvider: () => '11',
        apiPrivateSignatureKeyProvider: () => env.apiPrivateSignatureKey,
        publicDataProvider: ref.read(publicDataProvider),
      ),
    )
    ..add(ThrottleMiddleware())
    ..add(ResponseMiddleware())
    ..add(ErrorMiddleware(dio: dio))
    ..add(AuthorizationMiddleware(dio: dio));

  return dio;
});

final publicDataProvider = Provider<PublicDataProvider>(
  (ref) => CachedPublicDataProvider(
    buildBase: () async {
      final versionInfo = await getVersionInfo();

      return {
        'version': versionInfo.version,
        'app_version': versionInfo.version,
        'platform': Platform.isAndroid ? 1 : 2,
        'lang': LocaleSettings.currentLocale.languageTag,
        'channel': ref.read(envProvider).channel,
      };
    },
  ),
);

///
/// re
///
final apiHubProvider = Provider<ApiHub>((ref) {
  final dio = ref.read(dioProvider);
  final host = ref.read(envProvider).apiBaseUrl;

  return ApiHub(dio: dio, host: host);
});
