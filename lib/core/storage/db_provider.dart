import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink_self_projects/core/storage/db.dart';

import 'dao/user_dao.dart';

final dbProvider = Provider<Db>((ref) {
  final db = Db();
  ref.onDispose(() {
    db.close();
  });
  return db;
});

final userDaoProvider = Provider<UserDao>((ref) {
  final db = ref.watch(dbProvider);
  return UserDao(db);
});
