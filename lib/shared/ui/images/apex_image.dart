// smart_image.dart
import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

enum SmartImageSourceType { asset, network, file }

/// 自动重试策略：指数退避 + 抖动 + 全局限流
@immutable
class SmartRetryPolicy {
  const SmartRetryPolicy({
    this.enableAutoRetry = true,
    this.maxAttempts = 2,
    this.initialDelay = const Duration(milliseconds: 600),
    this.maxDelay = const Duration(seconds: 6),
    this.backoffFactor = 2.0,
    this.jitterRatio = 0.2,
    this.minGlobalIntervalPerKey = const Duration(seconds: 2),
    this.retryIf,
  }) : assert(maxAttempts >= 0),
       assert(backoffFactor >= 1.0),
       assert(jitterRatio >= 0.0 && jitterRatio <= 1.0);

  /// 是否自动重试（仅对网络图有效）
  final bool enableAutoRetry;

  /// 最大自动重试次数（不含首次请求）
  final int maxAttempts;

  /// 第 1 次重试的延迟
  final Duration initialDelay;

  /// 最大退避延迟
  final Duration maxDelay;

  /// 指数因子：delay = initialDelay * backoffFactor^(attempt-1)
  final double backoffFactor;

  /// 抖动比例（防止雪崩），0.2 表示 ±20%
  final double jitterRatio;

  /// 全局限流：同一 key（通常是 url）最少间隔多久才允许再次重试
  final Duration minGlobalIntervalPerKey;

  /// 是否可重试的判断（返回 true 才会重试）
  final bool Function(Object error)? retryIf;

  Duration computeDelay(int attemptIndex, Random rnd) {
    // attemptIndex: 1,2,3...
    final baseMs =
        initialDelay.inMilliseconds *
        pow(backoffFactor, max(0, attemptIndex - 1)).toDouble();
    final cappedMs = min(baseMs, maxDelay.inMilliseconds.toDouble());

    if (jitterRatio <= 0) return Duration(milliseconds: cappedMs.round());

    final jitter = (cappedMs * jitterRatio).round();
    final delta = rnd.nextInt(jitter * 2 + 1) - jitter; // [-jitter, +jitter]
    final withJitter = max(0, cappedMs.round() + delta);
    return Duration(milliseconds: withJitter);
  }
}

/// cacheWidth/cacheHeight 规格
@immutable
class SmartCacheSpec {
  const SmartCacheSpec.manual({this.cacheWidth, this.cacheHeight})
    : autoFromLayout = false;

  /// 自动：优先取 Layout 约束尺寸（有限时），乘以 DPR 得到 cacheWidth/cacheHeight
  /// - 对高性能场景非常推荐：避免解码过大的位图
  const SmartCacheSpec.auto()
    : autoFromLayout = true,
      cacheWidth = null,
      cacheHeight = null;

  final bool autoFromLayout;
  final int? cacheWidth;
  final int? cacheHeight;
}

/// 全局限流器（防止同一 url 在多个组件里同时疯狂重试）
class _GlobalRetryLimiter {
  static final Map<String, DateTime> _nextAllowed = <String, DateTime>{};

  static DateTime nextAllowedTime(String key) =>
      _nextAllowed[key] ?? DateTime.fromMillisecondsSinceEpoch(0);

  static void updateNextAllowed(String key, DateTime time) {
    _nextAllowed[key] = time;
  }

  static void cleanupOld({Duration maxAge = const Duration(minutes: 5)}) {
    final now = DateTime.now();
    _nextAllowed.removeWhere((_, t) => now.difference(t).abs() > maxAge);
  }
}

typedef SmartPlaceholderBuilder =
    Widget Function(
      BuildContext context,
      double? progress, // 0..1, nullable
    );

typedef SmartErrorBuilder =
    Widget Function(BuildContext context, Object error, VoidCallback retry);

/// 高性能通用图片 Widget
class ApexImage extends StatefulWidget {
  const ApexImage._({
    super.key,
    required this.type,
    required this.source,
    this.headers,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.filterQuality = FilterQuality.low,
    this.gaplessPlayback = true,
    this.borderRadius,
    this.clipBehavior = Clip.antiAlias,
    this.isCircle = false,
    this.cacheSpec = const SmartCacheSpec.auto(),
    this.fadeInDuration = const Duration(milliseconds: 120),
    this.thumbnail,
    this.placeholderBuilder,
    this.errorBuilder,
    this.retryPolicy = const SmartRetryPolicy(),
    this.onTap,
    this.semanticLabel,
    this.excludeFromSemantics = false,
  });

  /// Assets
  factory ApexImage.asset(
    String assetPath, {
    Key? key,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Alignment alignment = Alignment.center,
    FilterQuality filterQuality = FilterQuality.low,
    bool gaplessPlayback = true,
    BorderRadius? borderRadius,
    Clip clipBehavior = Clip.antiAlias,
    bool isCircle = false,
    SmartCacheSpec cacheSpec = const SmartCacheSpec.auto(),
    Duration fadeInDuration = const Duration(milliseconds: 120),
    ImageProvider? thumbnail,
    SmartPlaceholderBuilder? placeholderBuilder,
    SmartErrorBuilder? errorBuilder,
    VoidCallback? onTap,
    String? semanticLabel,
    bool excludeFromSemantics = false,
  }) {
    return ApexImage._(
      key: key,
      type: SmartImageSourceType.asset,
      source: assetPath,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      filterQuality: filterQuality,
      gaplessPlayback: gaplessPlayback,
      borderRadius: borderRadius,
      clipBehavior: clipBehavior,
      isCircle: isCircle,
      cacheSpec: cacheSpec,
      fadeInDuration: fadeInDuration,
      thumbnail: thumbnail,
      placeholderBuilder: placeholderBuilder,
      errorBuilder: errorBuilder,
      retryPolicy: const SmartRetryPolicy(enableAutoRetry: false), // 本地资源不自动重试
      onTap: onTap,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
    );
  }

  /// Network
  factory ApexImage.network(
    String url, {
    Key? key,
    Map<String, String>? headers,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Alignment alignment = Alignment.center,
    FilterQuality filterQuality = FilterQuality.low,
    bool gaplessPlayback = true,
    BorderRadius? borderRadius,
    Clip clipBehavior = Clip.antiAlias,
    bool isCircle = false,
    SmartCacheSpec cacheSpec = const SmartCacheSpec.auto(),
    Duration fadeInDuration = const Duration(milliseconds: 120),
    ImageProvider? thumbnail,
    SmartPlaceholderBuilder? placeholderBuilder,
    SmartErrorBuilder? errorBuilder,
    SmartRetryPolicy retryPolicy = const SmartRetryPolicy(),
    VoidCallback? onTap,
    String? semanticLabel,
    bool excludeFromSemantics = false,
  }) {
    return ApexImage._(
      key: key,
      type: SmartImageSourceType.network,
      source: url,
      headers: headers,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      filterQuality: filterQuality,
      gaplessPlayback: gaplessPlayback,
      borderRadius: borderRadius,
      clipBehavior: clipBehavior,
      isCircle: isCircle,
      cacheSpec: cacheSpec,
      fadeInDuration: fadeInDuration,
      thumbnail: thumbnail,
      placeholderBuilder: placeholderBuilder,
      errorBuilder: errorBuilder,
      retryPolicy: retryPolicy,
      onTap: onTap,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
    );
  }

  /// File（支持 file:// 或 纯路径）
  factory ApexImage.file(
    String filePathOrUri, {
    Key? key,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Alignment alignment = Alignment.center,
    FilterQuality filterQuality = FilterQuality.low,
    bool gaplessPlayback = true,
    BorderRadius? borderRadius,
    Clip clipBehavior = Clip.antiAlias,
    bool isCircle = false,
    SmartCacheSpec cacheSpec = const SmartCacheSpec.auto(),
    Duration fadeInDuration = const Duration(milliseconds: 120),
    ImageProvider? thumbnail,
    SmartPlaceholderBuilder? placeholderBuilder,
    SmartErrorBuilder? errorBuilder,
    VoidCallback? onTap,
    String? semanticLabel,
    bool excludeFromSemantics = false,
  }) {
    return ApexImage._(
      key: key,
      type: SmartImageSourceType.file,
      source: filePathOrUri,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      filterQuality: filterQuality,
      gaplessPlayback: gaplessPlayback,
      borderRadius: borderRadius,
      clipBehavior: clipBehavior,
      isCircle: isCircle,
      cacheSpec: cacheSpec,
      fadeInDuration: fadeInDuration,
      thumbnail: thumbnail,
      placeholderBuilder: placeholderBuilder,
      errorBuilder: errorBuilder,
      retryPolicy: const SmartRetryPolicy(enableAutoRetry: false), // 本地文件不自动重试
      onTap: onTap,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
    );
  }

  final SmartImageSourceType type;
  final String source;
  final Map<String, String>? headers;

  final double? width;
  final double? height;
  final BoxFit fit;
  final Alignment alignment;
  final FilterQuality filterQuality;
  final bool gaplessPlayback;

  /// 圆角（isCircle=true 时忽略）
  final BorderRadius? borderRadius;
  final Clip clipBehavior;
  final bool isCircle;

  final SmartCacheSpec cacheSpec;

  /// 主图加载成功后的淡入时长（0 表示不淡入）
  final Duration fadeInDuration;

  /// 缩略图（先显示，主图成功后淡入覆盖）
  final ImageProvider? thumbnail;

  /// loading 占位（progress 可能为空）
  final SmartPlaceholderBuilder? placeholderBuilder;

  /// error 占位（提供 retry 回调）
  final SmartErrorBuilder? errorBuilder;

  final SmartRetryPolicy retryPolicy;

  final VoidCallback? onTap;

  final String? semanticLabel;
  final bool excludeFromSemantics;

  @override
  State<ApexImage> createState() => _ApexImageState();
}

class _ApexImageState extends State<ApexImage> {
  final Random _rnd = Random();

  Timer? _retryTimer;
  int _autoRetryCount = 0; // 已经自动重试了几次（不含首次）
  bool _retryScheduledForThisError = false;

  bool _loaded = false;
  Object? _lastError;

  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
  }

  void _scheduleAutoRetryIfNeeded(Object error) {
    if (!mounted) return;
    if (widget.type != SmartImageSourceType.network) return;
    if (!widget.retryPolicy.enableAutoRetry) return;

    final retryIf = widget.retryPolicy.retryIf;
    if (retryIf != null && !retryIf(error)) return;

    if (_autoRetryCount >= widget.retryPolicy.maxAttempts) return;
    if (_retryScheduledForThisError) return; // 防止 build/errorBuilder 反复触发

    _retryScheduledForThisError = true;

    final attemptIndex = _autoRetryCount + 1; // 1..max
    var delay = widget.retryPolicy.computeDelay(attemptIndex, _rnd);

    // 全局限流：同一 url 不能太频繁重试
    final key = widget.source;
    _GlobalRetryLimiter.cleanupOld();
    final now = DateTime.now();
    final nextAllowed = _GlobalRetryLimiter.nextAllowedTime(key);
    final minInterval = widget.retryPolicy.minGlobalIntervalPerKey;

    DateTime scheduledAt = now.add(delay);
    if (scheduledAt.isBefore(nextAllowed)) {
      scheduledAt = nextAllowed;
      delay = scheduledAt.difference(now);
    }
    // 更新下一次允许时间（确保至少 minInterval）
    _GlobalRetryLimiter.updateNextAllowed(key, scheduledAt.add(minInterval));

    _retryTimer?.cancel();
    _retryTimer = Timer(delay, () {
      if (!mounted) return;
      _autoRetryCount += 1;
      _retryScheduledForThisError = false;
      _evictAndReload();
    });
  }

  void _evictAndReload() {
    setState(() {
      _loaded = false;
      _lastError = null;
    });

    // 主动把失败的 provider 从内存 cache 里踢掉，确保下一次能重新请求/解码
    final provider = _createImageProvider(
      cacheWidth: null,
      cacheHeight: null,
      // 这里先不带 resize 规格 evict；后面 build 会用最终 cacheWidth/cacheHeight resolve
    );
    provider.evict().ignore();
  }

  void _manualRetry() {
    _retryTimer?.cancel();
    _retryScheduledForThisError = false;
    _autoRetryCount = 0; // 手动重试就重新给一轮自动重试机会
    _evictAndReload();
  }

  ImageProvider _createImageProvider({
    required int? cacheWidth,
    required int? cacheHeight,
  }) {
    switch (widget.type) {
      case SmartImageSourceType.asset:
        return AssetImage(widget.source);
      case SmartImageSourceType.file:
        final src = widget.source;
        final uri = Uri.tryParse(src);
        final path = (uri != null && uri.scheme == 'file')
            ? uri.toFilePath()
            : src;
        return FileImage(File(path));
      case SmartImageSourceType.network:
        return NetworkImage(widget.source, headers: widget.headers);
    }
  }

  Widget _defaultPlaceholder(BuildContext context, double? progress) {
    final theme = Theme.of(context);
    final bg = theme.colorScheme.surfaceContainerHighest.withOpacity(0.6);
    return Container(
      color: bg,
      alignment: Alignment.center,
      child: progress == null
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : SizedBox(
              width: 36,
              child: LinearProgressIndicator(value: progress),
            ),
    );
  }

  Widget _defaultError(BuildContext context, Object error, VoidCallback retry) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: retry,
      child: Container(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.6),
        alignment: Alignment.center,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _wrapClip(Widget child) {
    if (widget.isCircle) {
      return ClipOval(clipBehavior: widget.clipBehavior, child: child);
    }
    final br = widget.borderRadius;
    if (br == null) return child;
    return ClipRRect(
      borderRadius: br,
      clipBehavior: widget.clipBehavior,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = LayoutBuilder(
      builder: (context, constraints) {
        final dpr = MediaQuery.devicePixelRatioOf(context);

        int? cw = widget.cacheSpec.cacheWidth;
        int? ch = widget.cacheSpec.cacheHeight;

        if (widget.cacheSpec.autoFromLayout) {
          // 优先用布局约束（有限时），其次用显式 width/height
          final w = constraints.hasBoundedWidth && constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : widget.width;
          final h =
              constraints.hasBoundedHeight && constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : widget.height;

          if (w != null && w.isFinite && w > 0) cw = max(1, (w * dpr).round());
          if (h != null && h.isFinite && h > 0) ch = max(1, (h * dpr).round());
        }

        final provider = _createImageProvider(cacheWidth: cw, cacheHeight: ch);
        final resizedProvider = (cw != null || ch != null)
            ? ResizeImage.resizeIfNeeded(cw, ch, provider)
            : provider;

        Widget image = Image(
          key: ValueKey(
            '${widget.type}:${widget.source}:$cw:$ch:${_autoRetryCount}:${_lastError != null}',
          ),
          image: resizedProvider,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          alignment: widget.alignment,
          filterQuality: widget.filterQuality,
          gaplessPlayback: widget.gaplessPlayback,
          semanticLabel: widget.semanticLabel,
          excludeFromSemantics: widget.excludeFromSemantics,

          // loading（含进度）
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;

            final expected = loadingProgress.expectedTotalBytes;
            final loaded = loadingProgress.cumulativeBytesLoaded;
            final progress = (expected != null && expected > 0)
                ? (loaded / expected)
                : null;

            final placeholder =
                (widget.placeholderBuilder ?? _defaultPlaceholder)(
                  context,
                  progress,
                );
            return Stack(
              fit: StackFit.passthrough,
              children: [
                if (widget.thumbnail != null)
                  Positioned.fill(
                    child: Image(
                      image: widget.thumbnail!,
                      fit: widget.fit,
                      alignment: widget.alignment,
                      filterQuality: FilterQuality.low,
                    ),
                  ),
                Positioned.fill(child: placeholder),
              ],
            );
          },

          // error（支持自动重试 + 点击重试）
          errorBuilder: (context, error, stack) {
            _lastError = error;
            _loaded = false;

            // 自动重试（仅网络图）
            _scheduleAutoRetryIfNeeded(error);

            final errWidget = (widget.errorBuilder ?? _defaultError)(
              context,
              error,
              _manualRetry,
            );

            return Stack(
              fit: StackFit.passthrough,
              children: [
                if (widget.thumbnail != null)
                  Positioned.fill(
                    child: Image(
                      image: widget.thumbnail!,
                      fit: widget.fit,
                      alignment: widget.alignment,
                      filterQuality: FilterQuality.low,
                    ),
                  ),
                Positioned.fill(child: errWidget),
              ],
            );
          },

          // 主图淡入（可关）
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded ||
                widget.fadeInDuration == Duration.zero) {
              if (!_loaded) _loaded = true;
              return child;
            }

            final hasFrame = frame != null;
            if (hasFrame && !_loaded) {
              // 标记已加载（避免反复 setState）
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) setState(() => _loaded = true);
              });
            }

            // 如果没加载出来，交给 loadingBuilder
            if (!hasFrame) return child;

            final opacity = _loaded ? 1.0 : 0.0;
            return AnimatedOpacity(
              opacity: opacity,
              duration: widget.fadeInDuration,
              child: child,
            );
          },
        );

        // 缩略图：主图上层淡入覆盖
        if (widget.thumbnail != null) {
          image = Stack(
            fit: StackFit.passthrough,
            children: [
              Positioned.fill(
                child: Image(
                  image: widget.thumbnail!,
                  fit: widget.fit,
                  alignment: widget.alignment,
                  filterQuality: FilterQuality.low,
                ),
              ),
              Positioned.fill(child: image),
            ],
          );
        }

        return image;
      },
    );

    content = _wrapClip(content);

    if (widget.onTap != null) {
      content = InkWell(onTap: widget.onTap, child: content);
    }

    return content;
  }
}
