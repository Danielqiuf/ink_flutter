import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink_self_projects/apis/user/user_models.dart';
import 'package:ink_self_projects/core/storage/dao/user_mapper.dart';
import 'package:ink_self_projects/core/storage/db.dart';

import '../../di/storage_provider.dart';

class UserDao {
  final Db _db;

  UserDao(this._db);

  /// 从DTO实体模型类转成Db实体模型并插入
  Future<void> upsertFromDto(UserinfoModel dto) async {
    await _db.transaction(() async {
      // 先尝试更新
      final updated =
          await (_db.update(_db.dbUsers)
                ..where((t) => t.userId.equals(dto.userId)))
              .write(dto.toUpdateCompanion());

      if (updated > 0) return;

      // 不存在则插入
      await _db.into(_db.dbUsers).insert(dto.toInsertCompanion());
    });
  }

  Future<UserRowModel?> findByUserId(int userId) {
    return (_db.select(
      _db.dbUsers,
    )..where((t) => t.userId.equals(userId))).getSingleOrNull();
  }

  ///
  /// updateByUserId(
  ///   userId,
  ///   DbUsersCompanion(username: Value(username)),
  /// );
  /// .....
  ///
  Future<int> updateByUserId(int userId, DbUsersCompanion patch) {
    return (_db.update(
      _db.dbUsers,
    )..where((t) => t.userId.equals(userId))).write(patch);
  }

  Future<int> deleteById(int id) {
    return (_db.delete(_db.dbUsers)..where((t) => t.id.equals(id))).go();
  }

  Future<int> deleteByUserIds(List<int> userIds) {
    if (userIds.isEmpty) return Future.value(0);
    return (_db.delete(_db.dbUsers)..where((t) => t.userId.isIn(userIds))).go();
  }

  Future<int> clearAll() {
    return _db.delete(_db.dbUsers).go();
  }

  Stream<List<UserRowModel>> watchAll() {
    return (_db.select(
      _db.dbUsers,
    )..orderBy([(t) => OrderingTerm.desc(t.id)])).watch();
  }
}

final userDaoProvider = Provider<UserDao>((ref) {
  final db = ref.watch(dbProvider);
  return UserDao(db);
});
