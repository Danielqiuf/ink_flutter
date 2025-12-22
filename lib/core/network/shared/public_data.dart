import 'dart:async';

class PublicData {
  PublicData(this.base);
  final Map<String, dynamic> base;

  Map<String, dynamic> toMap({int? nonce}) {
    return <String, dynamic>{
      ...base,
      'nonce': nonce ?? DateTime.now().millisecondsSinceEpoch,
    };
  }
}

abstract class PublicDataProvider {
  Future<PublicData> getPublicData();

  // 切换渠道，语言后调用刷新缓存
  void invalidate() {}
}

class CachedPublicDataProvider implements PublicDataProvider {
  CachedPublicDataProvider({required this.buildBase});

  final FutureOr<Map<String, dynamic>> Function() buildBase;

  Map<String, dynamic>? _cachedBase;
  Future<Map<String, dynamic>>? _building;

  @override
  Future<PublicData> getPublicData() async {
    if (_cachedBase == null) {
      _building ??= Future.sync(() async {
        final base = await Future.value(buildBase());
        return Map<String, dynamic>.from(base);
      });
      _cachedBase = await _building!;
      _building = null;
    }
    return PublicData(_cachedBase!);
  }

  @override
  void invalidate() {
    _cachedBase = null;
    _building = null;
  }
}
