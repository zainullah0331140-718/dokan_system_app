import 'dart:convert';

import 'package:drift/drift.dart';

import '../dokan_database.dart';

part 'audit_dao.g.dart';

@DriftAccessor(tables: [AuditLogs])
class AuditDao extends DatabaseAccessor<DokanDatabase> with _$AuditDaoMixin {
  AuditDao(super.db);

  Future<void> log({
    required String action,
    required String entity,
    String? entityId,
    String? userId,
    String? branchId,
    String? deviceId,
    Object? before,
    Object? after,
  }) {
    return into(auditLogs).insert(
      AuditLogsCompanion.insert(
        action: action,
        entity: entity,
        entityId: Value(entityId),
        userId: Value(userId),
        branchId: Value(branchId),
        deviceId: Value(deviceId),
        beforeJson: Value(before == null ? null : jsonEncode(before)),
        afterJson: Value(after == null ? null : jsonEncode(after)),
      ),
    );
  }

  Stream<List<AuditLog>> watchRecent({int limit = 100}) =>
      (select(auditLogs)
            ..orderBy([
              (t) => OrderingTerm.desc(t.createdAt),
            ])
            ..limit(limit))
          .watch();

  Future<int> countFor(String entity) async {
    final count = auditLogs.id.count();
    final query = selectOnly(auditLogs)
      ..addColumns([count])
      ..where(auditLogs.entity.equals(entity));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }
}
