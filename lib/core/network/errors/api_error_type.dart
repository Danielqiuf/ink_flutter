enum ApiErrorType {
  offline,
  timeout,
  cancelled,
  http, // http响应码非2xx
  business, // 业务层响应码非0
  auth, // token失效
  banned, // 封禁
  otherDevice, // 异地登录
  unknown,
}
