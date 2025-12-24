import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'db.g.dart';

@DriftDatabase(include: {'schemas/db_schema.drift'})
class Db extends _$Db {
  static const String dbName = "self_ink.db";
  static const int dbVersion = 1;

  Db([QueryExecutor? e]) : super(e ?? _open());

  @override
  int get schemaVersion => dbVersion;

  static QueryExecutor _open() {
    // drift_flutter 提供的便捷打开方式（会放到合适的目录）
    return driftDatabase(name: dbName);
  }

  ///
  /// @TODO 表字段更新与迁移
  /// 升级version后进行表字段迁移，同步增加db_scheme.drift内的字段
  ///
  // @override
  // MigrationStrategy get migration => MigrationStrategy(
  //   onCreate: (m) async => m.createAll(),
  //   onUpgrade: (m, from, to) async {
  //     if (from < 2) {
  //       /// 添加新字段
  //       await m.addColumn(dbUsers, dbUsers.ws);
  //
  //       /// 添加新索引
  //       await m.createIndex(idxUserWs);
  //
  //       /// 删除老字段或更新字段类型同理，在drift文件内删除后自动兼容新数据
  //       /// INTEGER -> REAL这种都属于int类型可以用下面的方式，但是INTEGER -> TEXT这种int -> String要换成columnTransformer
  //       await m.alterTable(TableMigration(dbUsers));
  //
  //       /// columnTransformer类型转换，把int -> String
  //       await m.alterTable(TableMigration(
  //         dbUsers,
  //         columnTransformer: {
  //           dbUsers.birth: const CustomExpression<String>(
  //             "CAST(birth AS TEXT)"
  //           )
  //         }
  //       ));
  //     }
  //   },
  //   beforeOpen: (details) async {
  //     // 如需外键
  //     await customStatement('PRAGMA foreign_keys = ON');
  //   },
  // );
}
