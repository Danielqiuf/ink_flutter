import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:ink_self_projects/core/di/storage_provider.dart';

///
/// 授权类存储
/// user_id token
///
class AuthLocalRepo {
  AuthLocalRepo(this._box);

  final Box _box;

  static const String _kToken = "_k_token";
  static const String _kUserId = "_k_uid";

  String? get token => _box.get(_kToken) as String?;
  String? get userId => _box.get(_kUserId) as String?;

  Future<void> setToken(String? token) async {
    if (token != null) {
      await _box.put(_kToken, token);
    }
  }

  Future<void> setUid(String? uid) async {
    if (uid != null) {
      await _box.put(_kUserId, uid);
    }
  }
}

final authLocalRepoProvider = Provider<AuthLocalRepo>((ref) {
  final box = ref.watch(authBoxProvider);
  return AuthLocalRepo(box);
});
