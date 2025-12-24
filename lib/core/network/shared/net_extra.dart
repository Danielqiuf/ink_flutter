import 'package:flutter/foundation.dart';

///
/// 对接口发起前进行参数传递
/// @Extra({
///   NetExtra.log: true,
///   NetExtra.auth: false
/// })
/// @POST('/get_user_info')
/// Future<UserInfoModel> getUserInfo();
///
///
abstract final class NetExtra {
  static const log = 'log'; // 开启日志
  static const auth = 'auth'; // 请求携带token
  static const userId = 'userId'; // 请求携带user_id
  static const toast = 'toast'; // 请求错误后弹吐司

  static const responseType = 'responseType';
  static const headers = 'headers';

  static const connectTimeoutMs = 'connectTimeoutMs';
  static const sendTimeoutMs = 'sendTimeoutMs';
  static const receiveTimeoutMs = 'receiveTimeoutMs';

  static const retryEnable = 'retryEnable'; // 开启重试
  static const retryMaxAttempts =
      'retryMaxAttempts'; // (总次数，含首次) 例如 3 = 最多重试 2 次
  static const retryBaseDelayMs =
      'retryBaseDelayMs'; // 重试等待时间的起始基准,指数退避的基数,默认300
  static const retryMaxDelayMs =
      'retryMaxDelayMs'; // 重试等待时间的上限，指数退避再大也不超过它, 默认3000ms
  static const retryJitterMs =
      'retryJitterMs'; // 在重试等待时间上随机再加 0~N ms，防止大量客户端同一时刻一起重试，默认150ms
  static const retryUseRetryAfter =
      'retryUseRetryAfter'; // 是否优先使用响应头 Retry-After 指定的等待时间再重试(429, 503)

  static const retryOnMethods = 'retryOnMethods'; // 过滤重试的请求方法

  static const retryOnStatusCodes =
      'retryOnStatusCodes'; // 需要重试的http status code

  static const retryOnConnectionError =
      'retryOnConnectionError'; // 网络连接类错误重试（如超时、断网、连接失败

  static const throttle = 'throttleEnable'; // bool 是否节流

  // ===== 内部使用变量 =====
  @internal
  static const retrying = '__retrying__'; // bool: 标记本次 fetch 是重试发起，避免 onError 递归
  @internal
  static const attempt = '__retry_attempt__'; //  当前尝试次数（从 1 开始）
  @internal
  static const kickAuth = '__kick_auth__';

  @internal
  static const passByUserBanned = '__pass_by_user_banned__';
  @internal
  static const passByUserLogged = '__pass_by_user_logged__';
  @internal
  static const passByUserBannedProcessing =
      '__pass_by_user_banned_processing__';
}
