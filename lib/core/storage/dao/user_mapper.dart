import 'package:drift/drift.dart';
import 'package:ink_self_projects/apis/user/user_models.dart';
import 'package:ink_self_projects/core/storage/db.dart';

/// 同UserinfoModel映射成UserRowModel
extension UserRowModelMapper on UserinfoModel {
  DbUsersCompanion toInsertCompanion({int? nowMillis}) {
    final ts = nowMillis ?? DateTime.now().millisecondsSinceEpoch;

    return DbUsersCompanion(
      userId: Value(userId),
      age: Value(age),
      sex: Value(sex),

      avatarUrl: Value(avatarUrl),
      birth: Value(birth),
      gold: Value(gold),

      createdAt: Value(ts),
    );
  }

  /// 更新用,一般不改 createAt
  DbUsersCompanion toUpdateCompanion() {
    return DbUsersCompanion(
      age: Value(age),
      sex: Value(sex),
      avatarUrl: Value(avatarUrl),
      birth: Value(birth),
      gold: Value(gold),
    );
  }
}
