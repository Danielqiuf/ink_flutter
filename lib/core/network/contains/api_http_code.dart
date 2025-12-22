class ApiHttpCode {
  static const int success = 200;

  // 客户端错误
  static const int badRequest = 400; // 请求有误
  static const int unauthorized = 401; // 未授权/未登录
  static const int paymentRequired = 402; // 需要付费
  static const int forbidden = 403; // 禁止访问
  static const int notFound = 404; // 资源不存在
  static const int methodNotAllowed = 405; // 方法不被允许
  static const int notAcceptable = 406; // 请求不被接受
  static const int requestTimeout = 408; // 请求超时
  static const int conflict = 409; // 资源冲突
  static const int gone = 410; // 资源已失效
  static const int payloadTooLarge = 413; // 内容过大
  static const int unsupportedMediaType = 415; // 不支持的媒体类型
  static const int tooManyRequests = 429; // 请求过多

  // 服务端错误
  static const int systemError = 500; // 服务器内部错误
  static const int notImplemented = 501; // 未实现
  static const int gatewayBad = 502; // 错误网关
  static const int gatewayTimeout = 504; // 网关超时
  static const int serviceUnavailable = 503; // 服务不可用
  static const int httpVersionNotSupported = 505; // 不支持的 HTTP 版本
}
