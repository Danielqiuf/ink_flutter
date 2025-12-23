import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

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
  ///先固定 TAG，再打日志（更像 Android 的：private static final String TAG = "xxx";）
  static TagLogger tag(String tag) => TagLogger._(tag);

  static void I(
    String tag,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    bool withStackTrace = false, // 主动打印当前调用堆栈
  }) {
    logger.i(
      TaggedMessage(tag, message),
      error: error,
      stackTrace: stackTrace ?? (withStackTrace ? StackTrace.current : null),
    );
  }

  static void D(
    String tag,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    bool withStackTrace = false,
  }) {
    logger.d(
      TaggedMessage(tag, message),
      error: error,
      stackTrace: stackTrace ?? (withStackTrace ? StackTrace.current : null),
    );
  }

  static void T(
    String tag,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    bool withStackTrace = false,
  }) {
    logger.t(
      TaggedMessage(tag, message),
      error: error,
      stackTrace: stackTrace ?? (withStackTrace ? StackTrace.current : null),
    );
  }

  static void W(
    String tag,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    bool withStackTrace = false,
  }) {
    logger.w(
      TaggedMessage(tag, message),
      error: error,
      stackTrace: stackTrace ?? (withStackTrace ? StackTrace.current : null),
    );
  }

  static void E(
    String tag,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    logger.e(
      TaggedMessage(tag, message),
      error: error,
      stackTrace: stackTrace ?? StackTrace.current,
    );
  }

  static void F(
    String tag,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    logger.f(
      TaggedMessage(tag, message),
      error: error,
      stackTrace: stackTrace ?? StackTrace.current,
    );
  }
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
  }) => Log.I(
    _tag,
    msg,
    error: error,
    stackTrace: stackTrace,
    withStackTrace: withStackTrace,
  );

  void d(
    String msg, {
    Object? error,
    StackTrace? stackTrace,
    bool withStackTrace = false,
  }) => Log.D(
    _tag,
    msg,
    error: error,
    stackTrace: stackTrace,
    withStackTrace: withStackTrace,
  );

  void t(
    String msg, {
    Object? error,
    StackTrace? stackTrace,
    bool withStackTrace = false,
  }) => Log.T(
    _tag,
    msg,
    error: error,
    stackTrace: stackTrace,
    withStackTrace: withStackTrace,
  );

  void w(
    String msg, {
    Object? error,
    StackTrace? stackTrace,
    bool withStackTrace = false,
  }) => Log.W(
    _tag,
    msg,
    error: error,
    stackTrace: stackTrace,
    withStackTrace: withStackTrace,
  );

  void e(String msg, {Object? error, StackTrace? stackTrace}) =>
      Log.E(_tag, msg, error: error, stackTrace: stackTrace);

  void f(String msg, {Object? error, StackTrace? stackTrace}) =>
      Log.F(_tag, msg, error: error, stackTrace: stackTrace);
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
