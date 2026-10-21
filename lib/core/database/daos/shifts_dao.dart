import 'package:drift/drift.dart';

import '../dokan_database.dart';

part 'shifts_dao.g.dart';

@DriftAccessor(tables: [Shifts, ShiftTransactions])
class ShiftsDao extends DatabaseAccessor<DokanDatabase> with _$ShiftsDaoMixin {
  ShiftsDao(super.db);

  Stream<Shift?> watchOpenShift(String userId, String branchId) {
    return (select(shifts)
          ..where(
            (s) =>
                s.userId.equals(userId) &
                s.branchId.equals(branchId) &
                s.status.equals('open'),
          )
          ..limit(1))
        .watch()
        .map((rows) => rows.isEmpty ? null : rows.first);
  }

  Future<Shift?> getOpenShift(String userId, String branchId) {
    return (select(shifts)
          ..where(
            (s) =>
                s.userId.equals(userId) &
                s.branchId.equals(branchId) &
                s.status.equals('open'),
          )
          ..limit(1))
        .getSingleOrNull();
  }

  Future<Shift> openShift({
    required String userId,
    required String branchId,
    required int openingCashMinor,
    String? notes,
  }) async {
    final existing = await getOpenShift(userId, branchId);
    if (existing != null) return existing;
    await into(shifts).insert(
      ShiftsCompanion(
        branchId: Value(branchId),
        userId: Value(userId),
        openingCashMinor: Value(openingCashMinor),
        expectedCashMinor: Value(openingCashMinor),
        notes: Value(notes),
      ),
    );
    final opened = await getOpenShift(userId, branchId);
    return opened!;
  }

  Future<void> addCashTransaction({
    required String shiftId,
    required ShiftTxType type,
    required int amountMinor,
    String? reason,
    String? userId,
  }) async {
    await into(shiftTransactions).insert(
      ShiftTransactionsCompanion.insert(
        shiftId: shiftId,
        type: type,
        amountMinor: amountMinor,
        reason: Value(reason),
        userId: Value(userId),
      ),
    );
    final shift = await (select(shifts)..where((s) => s.id.equals(shiftId)))
        .getSingleOrNull();
    if (shift == null) return;
    var cashIn = shift.cashInMinor;
    var cashOut = shift.cashOutMinor;
    if (type == ShiftTxType.cashIn) {
      cashIn += amountMinor;
    } else {
      cashOut += amountMinor;
    }
    final expected = _expectedCash(
      opening: shift.openingCashMinor,
      cashSales: shift.cashSalesMinor,
      cashRefunds: shift.cashRefundsMinor,
      cashIn: cashIn,
      cashOut: cashOut,
    );
    await (update(shifts)..where((s) => s.id.equals(shiftId))).write(
      ShiftsCompanion(
        cashInMinor: Value(cashIn),
        cashOutMinor: Value(cashOut),
        expectedCashMinor: Value(expected),
      ),
    );
  }

  Future<void> applySaleCash({
    required String shiftId,
    required int cashAmountMinor,
  }) async {
    final shift = await (select(shifts)..where((s) => s.id.equals(shiftId)))
        .getSingleOrNull();
    if (shift == null || shift.status != ShiftStatus.open) return;
    final cashSales = shift.cashSalesMinor + cashAmountMinor;
    final expected = _expectedCash(
      opening: shift.openingCashMinor,
      cashSales: cashSales,
      cashRefunds: shift.cashRefundsMinor,
      cashIn: shift.cashInMinor,
      cashOut: shift.cashOutMinor,
    );
    await (update(shifts)..where((s) => s.id.equals(shiftId))).write(
      ShiftsCompanion(
        cashSalesMinor: Value(cashSales),
        expectedCashMinor: Value(expected),
      ),
    );
  }

  Future<Shift> closeShift({
    required String shiftId,
    required int countedCashMinor,
    String? notes,
  }) async {
    final shift = await (select(shifts)..where((s) => s.id.equals(shiftId)))
        .getSingle();
    final expected = _expectedCash(
      opening: shift.openingCashMinor,
      cashSales: shift.cashSalesMinor,
      cashRefunds: shift.cashRefundsMinor,
      cashIn: shift.cashInMinor,
      cashOut: shift.cashOutMinor,
    );
    await (update(shifts)..where((s) => s.id.equals(shiftId))).write(
      ShiftsCompanion(
        status: Value(ShiftStatus.closed),
        closedAt: Value(DateTime.now()),
        expectedCashMinor: Value(expected),
        countedCashMinor: Value(countedCashMinor),
        differenceMinor: Value(countedCashMinor - expected),
        notes: Value(notes ?? shift.notes),
      ),
    );
    return (select(shifts)..where((s) => s.id.equals(shiftId))).getSingle();
  }

  Stream<List<ShiftTransaction>> watchTransactions(String shiftId) {
    return (select(shiftTransactions)
          ..where((t) => t.shiftId.equals(shiftId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Stream<List<Shift>> watchRecent({String? userId, int limit = 30}) {
    final q = select(shifts)
      ..orderBy([(s) => OrderingTerm.desc(s.openedAt)])
      ..limit(limit);
    if (userId != null) {
      q.where((s) => s.userId.equals(userId));
    }
    return q.watch();
  }

  int _expectedCash({
    required int opening,
    required int cashSales,
    required int cashRefunds,
    required int cashIn,
    required int cashOut,
  }) =>
      opening + cashSales - cashRefunds + cashIn - cashOut;
}
