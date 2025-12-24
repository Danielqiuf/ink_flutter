import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:uuid/uuid.dart';

class HivSecure {
  HivSecure._();

  static final HivSecure instance = HivSecure._();

  static const String _metaBoxName = '__secure_meta__';
  static const String _authBoxName = '__auth_box__';

  // secure storage 里只存 master key + keyId
  static const String _secureKeyName = 'hiv_master_key_v1';
  static const String _secureKeyIdName = 'hiv_master_key_id_v1';

  // meta 里存 keyId用于检测 hive 里数据是否匹配当前 key
  static const String _metaKeyIdField = 'keyId';

  final FlutterSecureStorage _secure = const FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  late final Box _metaBox;
  late final Box _authBox;

  bool _inited = false;

  Box get authBox {
    if (!_inited) throw StateError('SecureHiveManager not initialized');
    return _authBox;
  }

  Future<void> init() async {
    if (_inited) return;

    await Hive.initFlutter();
    _metaBox = await Hive.openBox(_metaBoxName);

    // 先确保 master key / keyId 与 meta 一致，并处理 secure storage 清空但 hive 还在 的情况
    await _ensureKeyConsistencyAndRecoverIfNeeded(
      encryptedBoxName: _authBoxName,
    );

    // 打开加密 auth box（如果 key 不对会抛异常，catch 后 wipe+rekey 再开）
    _authBox = await _openEncryptedBoxWithRecovery(_authBoxName);

    _inited = true;
  }

  Future<void> _ensureKeyConsistencyAndRecoverIfNeeded({
    required String encryptedBoxName,
  }) async {
    final String? keyB64 = await _secure.read(key: _secureKeyName);
    final String? keyId = await _secure.read(key: _secureKeyIdName);
    final String? hiveKeyId = _metaBox.get(_metaKeyIdField) as String?;
    final bool boxExists = await Hive.boxExists(encryptedBoxName);

    //secure storage 被清空，但 Hive 还有数据：无法解密，只能 wipe + rekey
    if (keyB64 == null || keyId == null) {
      if (boxExists || hiveKeyId != null) {
        await _wipeEncryptedBox(encryptedBoxName);
      }
      await _generateAndPersistNewKey();
      return;
    }

    // keyId 不匹配：说明 hive 数据不是当前 key 加密 -> wipe + rekey
    if (hiveKeyId != null && hiveKeyId != keyId) {
      await _wipeEncryptedBox(encryptedBoxName);
      await _generateAndPersistNewKey();
      return;
    }

    // meta 缺失（例如 hive 被清过），补写回
    if (hiveKeyId == null) {
      await _metaBox.put(_metaKeyIdField, keyId);
    }
  }

  Future<Box> _openEncryptedBoxWithRecovery(String boxName) async {
    try {
      final key = await _readMasterKeyBytes();
      return await Hive.openBox(boxName, encryptionCipher: HiveAesCipher(key));
    } catch (_) {
      // key 不对/数据损坏等, wipe + rekey 再开
      await _wipeEncryptedBox(boxName);
      await _generateAndPersistNewKey();

      final key = await _readMasterKeyBytes();
      return await Hive.openBox(boxName, encryptionCipher: HiveAesCipher(key));
    }
  }

  Future<List<int>> _readMasterKeyBytes() async {
    final String? keyB64 = await _secure.read(key: _secureKeyName);
    if (keyB64 == null)
      throw StateError('Master key missing in secure storage.');
    final bytes = base64Url.decode(keyB64);
    if (bytes.length != 32)
      throw StateError('Invalid master key length: ${bytes.length}');
    return bytes;
  }

  Future<void> _generateAndPersistNewKey() async {
    final keyBytes = Hive.generateSecureKey(); // 32 bytes
    final keyB64 = base64UrlEncode(keyBytes);
    final keyId = const Uuid().v4();

    await _secure.write(key: _secureKeyName, value: keyB64);
    await _secure.write(key: _secureKeyIdName, value: keyId);
    await _metaBox.put(_metaKeyIdField, keyId);
  }

  Future<void> _wipeEncryptedBox(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      await Hive.box(boxName).close();
    }
    if (await Hive.boxExists(boxName)) {
      await Hive.deleteBoxFromDisk(boxName);
    }
    await _metaBox.delete(_metaKeyIdField);
  }

  /// 退出登录
  Future<void> wipeAllAndRekey() async {
    if (!_inited) return;
    await _wipeEncryptedBox(_authBoxName);
    await _secure.delete(key: _secureKeyName);
    await _secure.delete(key: _secureKeyIdName);
    await _metaBox.clear();

    _inited = false;
  }
}
