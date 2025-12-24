import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:ink_self_projects/core/storage/hiv/hiv_secure.dart';

import '../storage/db.dart';

final authBoxProvider = Provider<Box<dynamic>>((ref) {
  throw UnimplementedError('authBoxProvider must be overridden in main()');
});

final hivSecureProvider = Provider((ref) => HivSecure.instance);

final dbProvider = Provider<Db>((ref) {
  final db = Db();
  ref.onDispose(() {
    db.close();
  });
  return db;
});
