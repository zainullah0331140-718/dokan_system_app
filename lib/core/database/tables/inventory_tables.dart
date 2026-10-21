import 'package:drift/drift.dart';

import '../enums.dart';
import '../../utils/uuid.dart';
import 'catalog_tables.dart';
import 'syncable.dart';
import 'system_tables.dart';

class StockBalances extends SyncableTable {
  TextColumn get productId =>
      text().references(Products, #id, onDelete: KeyAction.cascade)();
  TextColumn get variantId => text().withDefault(const Constant(''))();
  TextColumn get branchId =>
      text().references(Branches, #id, onDelete: KeyAction.cascade)();
  IntColumn get qtyMilli => integer().withDefault(const Constant(0))();
  IntColumn get reservedMilli => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {productId, variantId, branchId};
}

class StockMovements extends SyncableTable {
  TextColumn get id => text().clientDefault(newId)();
  TextColumn get productId =>
      text().references(Products, #id, onDelete: KeyAction.cascade)();
  TextColumn get variantId => text().withDefault(const Constant(''))();
  TextColumn get branchId =>
      text().references(Branches, #id, onDelete: KeyAction.cascade)();
  IntColumn get deltaMilli => integer()();
  IntColumn get balanceAfterMilli => integer().withDefault(const Constant(0))();
  TextColumn get type => textEnum<StockMovementType>()();
  TextColumn get refType => text().nullable()();
  TextColumn get refId => text().nullable()();
  IntColumn get unitCostMinor => integer().nullable()();
  TextColumn get userId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class StockAdjustments extends SyncableTable {
  TextColumn get id => text().clientDefault(newId)();
  TextColumn get adjustmentNo => text()();
  TextColumn get branchId =>
      text().references(Branches, #id, onDelete: KeyAction.cascade)();
  TextColumn get reason => text().nullable()();
  TextColumn get userId => text().nullable()();
  TextColumn get status =>
      textEnum<AdjustmentStatus>().withDefault(const Constant('draft'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class StockAdjustmentItems extends Table {
  TextColumn get id => text().clientDefault(newId)();
  TextColumn get adjustmentId =>
      text().references(StockAdjustments, #id, onDelete: KeyAction.cascade)();
  TextColumn get productId =>
      text().references(Products, #id, onDelete: KeyAction.cascade)();
  TextColumn get variantId => text().withDefault(const Constant(''))();
  IntColumn get deltaMilli => integer()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class StockTransfers extends SyncableTable {
  TextColumn get id => text().clientDefault(newId)();
  TextColumn get transferNo => text()();
  TextColumn get fromBranchId =>
      text().references(Branches, #id, onDelete: KeyAction.cascade)();
  TextColumn get toBranchId =>
      text().references(Branches, #id, onDelete: KeyAction.cascade)();
  TextColumn get userId => text().nullable()();
  TextColumn get status =>
      textEnum<TransferStatus>().withDefault(const Constant('draft'))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get shippedAt => dateTime().nullable()();
  DateTimeColumn get receivedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class StockTransferItems extends Table {
  TextColumn get id => text().clientDefault(newId)();
  TextColumn get transferId =>
      text().references(StockTransfers, #id, onDelete: KeyAction.cascade)();
  TextColumn get productId =>
      text().references(Products, #id, onDelete: KeyAction.cascade)();
  TextColumn get variantId => text().withDefault(const Constant(''))();
  IntColumn get qtyMilli => integer().withDefault(const Constant(0))();
  IntColumn get receivedQtyMilli => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
