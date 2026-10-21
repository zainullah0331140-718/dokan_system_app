import 'package:drift/drift.dart';

import '../enums.dart';
import '../../utils/uuid.dart';
import 'catalog_tables.dart';
import 'party_tables.dart';
import 'syncable.dart';
import 'system_tables.dart';

class Purchases extends SyncableTable {
  TextColumn get id => text().clientDefault(newId)();
  TextColumn get invoiceNo => text()();
  TextColumn get supplierId => text().references(Suppliers, #id)();
  TextColumn get branchId =>
      text().references(Branches, #id, onDelete: KeyAction.cascade)();
  TextColumn get status =>
      textEnum<PurchaseStatus>().withDefault(const Constant('ordered'))();
  IntColumn get subtotalMinor => integer().withDefault(const Constant(0))();
  IntColumn get discountMinor => integer().withDefault(const Constant(0))();
  IntColumn get taxMinor => integer().withDefault(const Constant(0))();
  IntColumn get totalMinor => integer().withDefault(const Constant(0))();
  IntColumn get paidMinor => integer().withDefault(const Constant(0))();
  IntColumn get dueMinor => integer().withDefault(const Constant(0))();
  DateTimeColumn get expectedAt => dateTime().nullable()();
  DateTimeColumn get receivedAt => dateTime().nullable()();
  TextColumn get createdBy => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class PurchaseItems extends Table {
  TextColumn get id => text().clientDefault(newId)();
  TextColumn get purchaseId =>
      text().references(Purchases, #id, onDelete: KeyAction.cascade)();
  TextColumn get productId =>
      text().references(Products, #id, onDelete: KeyAction.cascade)();
  TextColumn get variantId => text().withDefault(const Constant(''))();
  IntColumn get qtyMilli => integer()();
  IntColumn get receivedQtyMilli => integer().withDefault(const Constant(0))();
  IntColumn get unitCostMinor => integer().withDefault(const Constant(0))();
  IntColumn get taxRateBp => integer().withDefault(const Constant(0))();
  IntColumn get discountMinor => integer().withDefault(const Constant(0))();
  TextColumn get batchNo => text().nullable()();
  DateTimeColumn get expiryAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
