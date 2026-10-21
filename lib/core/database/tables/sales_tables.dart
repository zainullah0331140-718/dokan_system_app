import 'package:drift/drift.dart';

import '../enums.dart';
import '../../utils/uuid.dart';
import 'catalog_tables.dart';
import 'identity_tables.dart';
import 'party_tables.dart';
import 'shift_tables.dart';
import 'syncable.dart';
import 'system_tables.dart';

class Sales extends SyncableTable {
  TextColumn get id => text().clientDefault(newId)();
  TextColumn get invoiceNo => text()();
  TextColumn get branchId =>
      text().references(Branches, #id, onDelete: KeyAction.cascade)();
  TextColumn get cashierId =>
      text().references(Users, #id, onDelete: KeyAction.restrict)();
  TextColumn get customerId =>
      text().nullable().references(Customers, #id, onDelete: KeyAction.setNull)();
  TextColumn get shiftId =>
      text().nullable().references(Shifts, #id, onDelete: KeyAction.setNull)();
  DateTimeColumn get soldAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get status =>
      textEnum<SaleStatus>().withDefault(const Constant('held'))();
  TextColumn get holdLabel => text().nullable()();
  TextColumn get source =>
      textEnum<SaleSource>().withDefault(const Constant('pos'))();

  IntColumn get subtotalMinor => integer()();
  TextColumn get orderDiscountId => text().nullable()();
  IntColumn get orderDiscountMinor => integer().withDefault(const Constant(0))();
  IntColumn get taxMinor => integer().withDefault(const Constant(0))();
  IntColumn get totalMinor => integer()();
  IntColumn get paidMinor => integer().withDefault(const Constant(0))();
  IntColumn get dueMinor => integer().withDefault(const Constant(0))();
  IntColumn get changeMinor => integer().withDefault(const Constant(0))();

  TextColumn get currencyCode => text().withDefault(const Constant('USD'))();
  IntColumn get exchangeRateMicro =>
      integer().withDefault(const Constant(1000000))();

  IntColumn get loyaltyEarned => integer().withDefault(const Constant(0))();
  IntColumn get loyaltyRedeemed => integer().withDefault(const Constant(0))();
  IntColumn get loyaltyDiscountMinor =>
      integer().withDefault(const Constant(0))();
  IntColumn get itemsCount => integer().withDefault(const Constant(0))();
  IntColumn get costTotalMinor => integer().withDefault(const Constant(0))();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class SaleItems extends Table {
  TextColumn get id => text().clientDefault(newId)();
  TextColumn get saleId =>
      text().references(Sales, #id, onDelete: KeyAction.cascade)();
  IntColumn get lineNo => integer()();
  TextColumn get productId =>
      text().references(Products, #id, onDelete: KeyAction.restrict)();
  TextColumn get variantId => text().nullable()();
  TextColumn get nameSnapshot => text()();
  TextColumn get nameArSnapshot => text().nullable()();
  TextColumn get skuSnapshot => text()();
  TextColumn get barcodeSnapshot => text().nullable()();
  IntColumn get qtyMilli => integer()();
  IntColumn get unitPriceMinor => integer()();
  IntColumn get unitCostMinor => integer().withDefault(const Constant(0))();
  TextColumn get lineDiscountType =>
      textEnum<DiscountType>().withDefault(const Constant('percent'))();
  IntColumn get lineDiscountPercentBp =>
      integer().withDefault(const Constant(0))();
  IntColumn get lineDiscountMinor => integer().withDefault(const Constant(0))();
  IntColumn get taxRateBp => integer().withDefault(const Constant(0))();
  BoolColumn get taxInclusive => boolean().withDefault(const Constant(false))();
  IntColumn get taxMinor => integer().withDefault(const Constant(0))();
  IntColumn get totalMinor => integer()();
  IntColumn get loyaltyPoints => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class Payments extends SyncableTable {
  TextColumn get id => text().clientDefault(newId)();
  TextColumn get refType => textEnum<PaymentRefType>()();
  TextColumn get refId => text()();
  TextColumn get branchId =>
      text().references(Branches, #id, onDelete: KeyAction.cascade)();
  TextColumn get shiftId =>
      text().nullable().references(Shifts, #id, onDelete: KeyAction.setNull)();
  TextColumn get method => textEnum<PayMethod>()();
  IntColumn get amountMinor => integer()();
  IntColumn get tenderedMinor => integer().nullable()();
  IntColumn get changeMinor => integer().withDefault(const Constant(0))();
  TextColumn get currencyCode => text().withDefault(const Constant('USD'))();
  IntColumn get exchangeRateMicro =>
      integer().withDefault(const Constant(1000000))();
  TextColumn get reference => text().nullable()();
  TextColumn get status =>
      textEnum<PaymentStatus>().withDefault(const Constant('completed'))();
  TextColumn get userId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Refunds extends SyncableTable {
  TextColumn get id => text().clientDefault(newId)();
  TextColumn get refundNo => text()();
  TextColumn get saleId =>
      text().references(Sales, #id, onDelete: KeyAction.restrict)();
  TextColumn get branchId =>
      text().references(Branches, #id, onDelete: KeyAction.cascade)();
  TextColumn get userId => text().nullable()();
  TextColumn get reason => text().nullable()();
  IntColumn get subtotalMinor => integer().withDefault(const Constant(0))();
  IntColumn get taxMinor => integer().withDefault(const Constant(0))();
  IntColumn get totalMinor => integer()();
  BoolColumn get restock => boolean().withDefault(const Constant(true))();
  TextColumn get currencyCode => text().withDefault(const Constant('USD'))();
  IntColumn get exchangeRateMicro =>
      integer().withDefault(const Constant(1000000))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class RefundItems extends Table {
  TextColumn get id => text().clientDefault(newId)();
  TextColumn get refundId =>
      text().references(Refunds, #id, onDelete: KeyAction.cascade)();
  TextColumn get saleItemId =>
      text().references(SaleItems, #id, onDelete: KeyAction.restrict)();
  TextColumn get productId =>
      text().references(Products, #id, onDelete: KeyAction.restrict)();
  TextColumn get variantId => text().nullable()();
  IntColumn get qtyMilli => integer()();
  IntColumn get amountMinor => integer()();
  IntColumn get restockedQtyMilli => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
