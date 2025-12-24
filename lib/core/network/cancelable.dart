import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 一个 provider 生命周期内的 CancelToken 管理器：
/// next(): 生成新 token，并自动 cancel 旧 token, 避免并发/过期覆盖
/// dispose(): provider 销毁时自动 cancel
final class CancelTokenPool {
  CancelTokenPool(this._ref) {
    _ref.onDispose(() => cancel('provider disposed'));
  }

  final Ref _ref;
  CancelToken? _active;

  CancelToken next({String reason = 'replaced by new request'}) {
    _active?.cancel(reason);
    final t = CancelToken();
    _active = t;
    return t;
  }

  void cancel([String reason = 'cancelled']) {
    _active?.cancel(reason);
    _active = null;
  }
}

/// 多路 token（同一个 Notifier 里并行多个请求时用）
/// 例如：profile / feed / config 各一条 token
class CancelBag {
  CancelBag(this._ref) {
    _ref.onDispose(() => cancelAll('provider disposed'));
  }

  final Ref _ref;
  final _map = <String, CancelToken>{};

  CancelToken next(String key, {String reason = 'replaced by new request'}) {
    _map[key]?.cancel(reason);
    final t = CancelToken();
    _map[key] = t;
    return t;
  }

  void cancel(String key, [String reason = 'cancelled']) {
    _map.remove(key)?.cancel(reason);
  }

  void cancelAll([String reason = 'cancelled']) {
    for (final t in _map.values) {
      t.cancel(reason);
    }
    _map.clear();
  }
}

/// 给 AsyncNotifier 用的基类,不用每次自己写 onDispose cancel
abstract class CancelableAsyncNotifier<T> extends AsyncNotifier<T> {
  late final CancelTokenPool cancelToken = CancelTokenPool(ref);
  late final CancelBag cancelBag = CancelBag(ref);
}

/// 给 Notifier 用的基类,不用每次自己写 onDispose cancel
abstract class CancelableNotifier<T> extends Notifier<T> {
  late final CancelTokenPool cancelToken = CancelTokenPool(ref);
  late final CancelBag cancelBag = CancelBag(ref);
}
