import '../../../locale/translations.g.dart';
import '../contains/api_http_code.dart';

final localeMessageMapper = <int?, String>{
  ApiHttpCode.badRequest: t.networkErrors.badRequest, // 400
  ApiHttpCode.unauthorized: t.networkErrors.unauthorized, // 401
  ApiHttpCode.paymentRequired: t.networkErrors.paymentRequired, // 402
  ApiHttpCode.forbidden: t.networkErrors.forbiddenError, // 403
  ApiHttpCode.methodNotAllowed: t.networkErrors.methodNotAllowed, // 405
  ApiHttpCode.notAcceptable: t.networkErrors.notAcceptable, // 406
  ApiHttpCode.requestTimeout: t.networkErrors.requestTimeout, // 408
  ApiHttpCode.conflict: t.networkErrors.conflict, // 409
  ApiHttpCode.gone: t.networkErrors.gone, // 410
  ApiHttpCode.payloadTooLarge: t.networkErrors.payloadTooLarge, // 413
  ApiHttpCode.unsupportedMediaType: t.networkErrors.unsupportedMediaType, // 415
  ApiHttpCode.tooManyRequests: t.networkErrors.tooManyRequests, // 429
  ApiHttpCode.systemError: t.networkErrors.systemError, // 500
  ApiHttpCode.notImplemented: t.networkErrors.notImplemented, // 501
  ApiHttpCode.gatewayBad: t.networkErrors.connectionTimeout, // 502
  ApiHttpCode.serviceUnavailable: t.networkErrors.serviceUnavailable, // 503
  ApiHttpCode.gatewayTimeout: t.networkErrors.connectionTimeout, // 504
  ApiHttpCode.httpVersionNotSupported:
      t.networkErrors.httpVersionNotSupported, // 505
  null: t.networkErrors.badRequest,
};
