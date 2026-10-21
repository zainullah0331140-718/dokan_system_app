import 'package:drift/drift.dart';

import '../../utils/uuid.dart';
import 'catalog_tables.dart';
import 'syncable.dart';

class Customers extends SyncableTable {
  TextColumn get id => text().clientDefault(newId)();
  TextColumn get code => text().nullable().unique()();
  TextColumn get name => text()();
  TextColumn get nameAr => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get city => text().nullable()();
  TextColumn get taxNo => text().nullable()();
  IntColumn get loyaltyPoints => integer().withDefault(const Constant(0))();
  IntColumn get creditLimitMinor => integer().withDefault(const Constant(0))();
  IntColumn get openingBalanceMinor =>
      integer().withDefault(const Constant(0))();
  IntColumn get balanceMinor => integer().withDefault(const Constant(0))();
  TextColumn get notes => text().nullable()();
  TextColumn get discountId =>
      text().nullable().references(Discounts, #id, onDelete: KeyAction.setNull)();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class Suppliers extends SyncableTable {
  TextColumn get id => text().clientDefault(newId)();
  TextColumn get code => text().nullable().unique()();
  TextColumn get name => text()();
  TextColumn get nameAr => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get taxNo => text().nullable()();
  IntColumn get openingBalanceMinor =>
      integer().withDefault(const Constant(0))();
  IntColumn get balanceMinor => integer().withDefault(const Constant(0))();
  TextColumn get notes => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class LoyaltyTransactions extends Table {
  TextColumn get id => text().clientDefault(newId)();
  TextColumn get customerId =>
      text().references(Customers, #id, onDelete: KeyAction.cascade)();
  TextColumn get saleId => text().nullable()();
  IntColumn get pointsDelta => integer()();
  IntColumn get balanceAfter => integer().withDefault(const Constant(0))();
  TextColumn get reason => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
