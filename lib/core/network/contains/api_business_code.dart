class ApiBusinessCode {
  /// 响应成功
  static const int success = 0;

  /// 防重放
  static const int illegalAttackRequest = 993;

  /// 参数签名无效
  static final int signatureInvalid = 994;

  /// Token过期（比对不一致）
  static const int unauthorizedRequest = 995;

  /// Token 过期（超过有效期）
  static const int tokenExpired = 996;

  /// token无效
  static const int tokenInvalid = 997;

  /// 请求参数params不是字典对象
  static const int paramsInvalid = 998;

  /// 请求body为空
  static const int requestBodyInvalid = 999;

  /// 账号再其它设备登录
  static const int loggedOtherDevices = 1000;

  /// 请求过快
  static const int operateFrequently = 1001;

  /// const
  static const int suspectedAccount = 1002;
}

/// token失效
bool isTokenInvalid(int code) => [
  ApiBusinessCode.unauthorizedRequest,
  ApiBusinessCode.tokenExpired,
  ApiBusinessCode.tokenInvalid,
].contains(code);

/// 静默异常(不处理业务弹窗逻辑)
bool isSilent(int code) => [
  ApiBusinessCode.operateFrequently,
  ApiBusinessCode.illegalAttackRequest,
  ApiBusinessCode.unauthorizedRequest,
  ApiBusinessCode.tokenInvalid,
  ApiBusinessCode.tokenExpired,
].contains(code);
