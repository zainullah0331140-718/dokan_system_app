import 'package:drift/drift.dart';

import '../enums.dart';
import '../../utils/uuid.dart';
import 'identity_tables.dart';
import 'syncable.dart';
import 'system_tables.dart';

class Shifts extends SyncableTable {
  TextColumn get id => text().clientDefault(newId)();
  TextColumn get branchId =>
      text().references(Branches, #id, onDelete: KeyAction.cascade)();
  TextColumn get userId =>
      text().references(Users, #id, onDelete: KeyAction.restrict)();
  TextColumn get status =>
      textEnum<ShiftStatus>().withDefault(const Constant('open'))();
  DateTimeColumn get openedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get closedAt => dateTime().nullable()();
  IntColumn get openingCashMinor => integer().withDefault(const Constant(0))();
  IntColumn get cashSalesMinor => integer().withDefault(const Constant(0))();
  IntColumn get cashRefundsMinor => integer().withDefault(const Constant(0))();
  IntColumn get cashInMinor => integer().withDefault(const Constant(0))();
  IntColumn get cashOutMinor => integer().withDefault(const Constant(0))();
  IntColumn get expectedCashMinor => integer().withDefault(const Constant(0))();
  IntColumn get countedCashMinor => integer().withDefault(const Constant(0))();
  IntColumn get differenceMinor => integer().withDefault(const Constant(0))();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class ShiftTransactions extends Table {
  TextColumn get id => text().clientDefault(newId)();
  TextColumn get shiftId =>
      text().references(Shifts, #id, onDelete: KeyAction.cascade)();
  TextColumn get type => textEnum<ShiftTxType>()();
  IntColumn get amountMinor => integer()();
  TextColumn get reason => text().nullable()();
  TextColumn get userId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
