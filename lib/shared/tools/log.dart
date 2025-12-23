import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

///
/// 日志工具
///
class TaggedMessage {
  final String tag;
  final String message;

  const TaggedMessage(this.tag, this.message);

  @override
  String toString() => '【$tag】$message';
}

/// 统一日志打印，根据日志级别自行选择
final logger = Logger(
  // 正式环境下只输出致命错误日志
  level: kReleaseMode ? Level.fatal : Level.all,
  printer: PrefixPrinter(
    PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 12,
      stackTraceBeginIndex: 2,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    fatal: '🔴🙅',
    error: '🔴',
    info: '🟢',
    debug: '🔵🔹',
  ),
);

class Log {
  Log._();

  /// 默认 TAG
  static const String defaultTag = 'APP';

  /// 先固定 TAG，再打日志（Android 风格）
  static TagLogger tag(String tag) => TagLogger._(tag);

  /// Info
  static void i(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    bool withStackTrace = false, // 主动打印当前调用堆栈
  }) {
    logger.i(
      TaggedMessage(tag ?? defaultTag, message),
      error: error,
      stackTrace: stackTrace ?? (withStackTrace ? StackTrace.current : null),
    );
  }

  /// Debug
  static void d(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    bool withStackTrace = false,
  }) {
    logger.d(
      TaggedMessage(tag ?? defaultTag, message),
      error: error,
      stackTrace: stackTrace ?? (withStackTrace ? StackTrace.current : null),
    );
  }

  /// Trace
  static void t(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    bool withStackTrace = false,
  }) {
    logger.t(
      TaggedMessage(tag ?? defaultTag, message),
      error: error,
      stackTrace: stackTrace ?? (withStackTrace ? StackTrace.current : null),
    );
  }

  /// Warning
  static void w(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    bool withStackTrace = false,
  }) {
    logger.w(
      TaggedMessage(tag ?? defaultTag, message),
      error: error,
      stackTrace: stackTrace ?? (withStackTrace ? StackTrace.current : null),
    );
  }

  /// Error：默认带 StackTrace.current
  static void e(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    logger.e(
      TaggedMessage(tag ?? defaultTag, message),
      error: error,
      stackTrace: stackTrace ?? StackTrace.current,
    );
  }

  /// Fatal：默认带 StackTrace.current
  static void f(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    logger.f(
      TaggedMessage(tag ?? defaultTag, message),
      error: error,
      stackTrace: stackTrace ?? StackTrace.current,
    );
  }

  static void I(
    String tag,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    bool withStackTrace = false,
  }) => i(
    message,
    tag: tag,
    error: error,
    stackTrace: stackTrace,
    withStackTrace: withStackTrace,
  );

  static void D(
    String tag,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    bool withStackTrace = false,
  }) => d(
    message,
    tag: tag,
    error: error,
    stackTrace: stackTrace,
    withStackTrace: withStackTrace,
  );

  static void T(
    String tag,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    bool withStackTrace = false,
  }) => t(
    message,
    tag: tag,
    error: error,
    stackTrace: stackTrace,
    withStackTrace: withStackTrace,
  );

  static void W(
    String tag,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    bool withStackTrace = false,
  }) => w(
    message,
    tag: tag,
    error: error,
    stackTrace: stackTrace,
    withStackTrace: withStackTrace,
  );

  static void E(
    String tag,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) => e(message, tag: tag, error: error, stackTrace: stackTrace);

  static void F(
    String tag,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) => f(message, tag: tag, error: error, stackTrace: stackTrace);
}

/// 固定 TAG 的 logger
class TagLogger {
  final String _tag;
  TagLogger._(this._tag);

  void i(
    String msg, {
    Object? error,
    StackTrace? stackTrace,
    bool withStackTrace = false,
  }) => Log.i(
    msg,
    tag: _tag,
    error: error,
    stackTrace: stackTrace,
    withStackTrace: withStackTrace,
  );

  void d(
    String msg, {
    Object? error,
    StackTrace? stackTrace,
    bool withStackTrace = false,
  }) => Log.d(
    msg,
    tag: _tag,
    error: error,
    stackTrace: stackTrace,
    withStackTrace: withStackTrace,
  );

  void t(
    String msg, {
    Object? error,
    StackTrace? stackTrace,
    bool withStackTrace = false,
  }) => Log.t(
    msg,
    tag: _tag,
    error: error,
    stackTrace: stackTrace,
    withStackTrace: withStackTrace,
  );

  void w(
    String msg, {
    Object? error,
    StackTrace? stackTrace,
    bool withStackTrace = false,
  }) => Log.w(
    msg,
    tag: _tag,
    error: error,
    stackTrace: stackTrace,
    withStackTrace: withStackTrace,
  );

  void e(String msg, {Object? error, StackTrace? stackTrace}) =>
      Log.e(msg, tag: _tag, error: error, stackTrace: stackTrace);

  void f(String msg, {Object? error, StackTrace? stackTrace}) =>
      Log.f(msg, tag: _tag, error: error, stackTrace: stackTrace);
}

///
/// 没有Tag的日志
/// "log日志".le();
/// "log日志".lw();
/// ....
///
extension LoggerExt on String {
  void le() => logger.e(this);
  void lf() => logger.f(this);
  void li() => logger.i(this);
  void lt() => logger.t(this);
  void lw() => logger.w(this);
}
