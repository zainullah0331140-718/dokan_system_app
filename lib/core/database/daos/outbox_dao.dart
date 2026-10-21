import 'dart:convert';

import 'package:drift/drift.dart';

import '../dokan_database.dart';

part 'outbox_dao.g.dart';

@DriftAccessor(tables: [SyncOutbox])
class OutboxDao extends DatabaseAccessor<DokanDatabase> with _$OutboxDaoMixin {
  OutboxDao(super.db);

  Future<void> enqueue({
    required String entityType,
    required String entityId,
    required OutboxAction action,
    required Map<String, Object?> payload,
  }) {
    return into(syncOutbox).insert(
      SyncOutboxCompanion.insert(
        entityType: entityType,
        entityId: entityId,
        action: action,
        payload: jsonEncode(payload),
      ),
    );
  }

  Stream<List<SyncOutboxData>> watchPending({int limit = 100}) =>
      (select(syncOutbox)
            ..where((r) => r.status.equals('pending'))
            ..orderBy([
              (r) => OrderingTerm.asc(r.createdAt),
            ])
            ..limit(limit))
          .watch();

  Future<List<SyncOutboxData>> pendingBatch({int limit = 50}) =>
      (select(syncOutbox)
            ..where((r) => r.status.equals('pending'))
            ..orderBy([
              (r) => OrderingTerm.asc(r.createdAt),
            ])
            ..limit(limit))
          .get();

  Future<int> pendingCount() async {
    final count = syncOutbox.status.count();
    final query = selectOnly(syncOutbox)
      ..addColumns([count])
      ..where(syncOutbox.status.equals('pending'));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  Stream<int> watchPendingCount() => (select(syncOutbox)
        ..where((r) => r.status.equals(OutboxStatus.pending.name)))
      .watch()
      .map((rows) => rows.length);

  Future<void> markSent(String id) =>
      (delete(syncOutbox)..where((r) => r.id.equals(id))).go();

  Future<void> markFailed({
    required String id,
    required String error,
    required DateTime nextRetryAt,
    required int attempts,
    required OutboxStatus status,
  }) =>
      (update(syncOutbox)..where((r) => r.id.equals(id))).write(
        SyncOutboxCompanion(
          lastError: Value(error),
          nextRetryAt: Value(nextRetryAt),
          attempts: Value(attempts),
          status: Value(status),
        ),
      );

  Future<void> clear() => delete(syncOutbox).go();
}
