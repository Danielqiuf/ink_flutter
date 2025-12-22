abstract final class NetExtra {
  static const log = 'log';
  static const auth = 'auth';
  static const userId = 'userId';
  static const toast = 'toast';

  static const responseType = 'responseType';
  static const headers = 'headers';

  static const connectTimeoutMs = 'connectTimeoutMs';
  static const sendTimeoutMs = 'sendTimeoutMs';
  static const receiveTimeoutMs = 'receiveTimeoutMs';

  static const retryEnable = 'retryEnable'; // bool
  static const retryMaxAttempts =
      'retryMaxAttempts'; // int (总次数，含首次) 例如 3 = 最多重试 2 次
  static const retryBaseDelayMs = 'retryBaseDelayMs'; // int
  static const retryMaxDelayMs = 'retryMaxDelayMs'; // int
  static const retryJitterMs = 'retryJitterMs'; // int
  static const retryUseRetryAfter = 'retryUseRetryAfter'; // bool

  static const retryOnMethods = 'retryOnMethods';

  static const retryOnStatusCodes = 'retryOnStatusCodes';

  static const retryOnConnectionError = 'retryOnConnectionError';

  static const throttle = 'throttleEnable'; // bool 是否节流

  static const retrying =
      '__retrying__'; // bool: 标记本次 fetch 是重试发起，避免 onError 递归
  static const attempt = '__retry_attempt__'; // int: 当前尝试次数（从 1 开始）

  static const kickAuth = '__kick_auth__';

  static const passByUserBanned = '__pass_by_user_banned__';
  static const passByUserLogged = '__pass_by_user_logged__';
  static const passByUserBannedProcessing =
      '__pass_by_user_banned_processing__';
}
