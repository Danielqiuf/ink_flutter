part of middleware;

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
