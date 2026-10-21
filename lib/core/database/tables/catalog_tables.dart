import 'package:drift/drift.dart';

import '../enums.dart';
import '../../utils/uuid.dart';
import 'syncable.dart';
import 'system_tables.dart';

class Categories extends SyncableTable {
  TextColumn get id => text().clientDefault(newId)();
  TextColumn get parentId =>
      text().nullable().references(Categories, #id, onDelete: KeyAction.setNull)();
  TextColumn get name => text()();
  TextColumn get nameAr => text().nullable()();
  TextColumn get icon => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class Units extends SyncableTable {
  TextColumn get id => text().clientDefault(newId)();
  TextColumn get name => text().unique()();
  TextColumn get nameAr => text().nullable()();
  IntColumn get factorMilli => integer().withDefault(const Constant(1000))();
  TextColumn get dimension => text().withDefault(const Constant('count'))();
  BoolColumn get isBase => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class Products extends SyncableTable {
  TextColumn get id => text().clientDefault(newId)();
  TextColumn get sku => text().unique()();
  TextColumn get barcode => text().nullable().unique()();
  TextColumn get name => text()();
  TextColumn get nameAr => text().nullable()();
  TextColumn get categoryId =>
      text().nullable().references(Categories, #id, onDelete: KeyAction.setNull)();
  TextColumn get unitId => text()();
  IntColumn get costPriceMinor => integer().withDefault(const Constant(0))();
  IntColumn get salePriceMinor => integer().withDefault(const Constant(0))();
  TextColumn get taxId => text().nullable()();
  BoolColumn get trackStock => boolean().withDefault(const Constant(true))();
  IntColumn get stockAlertMilli => integer().withDefault(const Constant(0))();
  BoolColumn get hasVariants => boolean().withDefault(const Constant(false))();
  BoolColumn get isService => boolean().withDefault(const Constant(false))();
  BoolColumn get isWeighed => boolean().withDefault(const Constant(false))();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get descriptionAr => text().nullable()();
  IntColumn get reorderQtyMilli => integer().withDefault(const Constant(0))();
  IntColumn get loyaltyPointsEarn => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class ProductVariants extends SyncableTable {
  TextColumn get id => text().clientDefault(newId)();
  TextColumn get productId =>
      text().references(Products, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  TextColumn get nameAr => text().nullable()();
  TextColumn get sku => text().unique()();
  TextColumn get barcode => text().nullable().unique()();
  TextColumn get attributesJson => text().nullable()();
  IntColumn get costPriceMinor => integer().withDefault(const Constant(0))();
  IntColumn get salePriceMinor => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class ProductBranchOverrides extends SyncableTable {
  TextColumn get productId =>
      text().references(Products, #id, onDelete: KeyAction.cascade)();
  TextColumn get branchId =>
      text().references(Branches, #id, onDelete: KeyAction.cascade)();
  IntColumn get priceMinor => integer().nullable()();
  IntColumn get costMinor => integer().nullable()();
  IntColumn get stockAlertMilli => integer().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {productId, branchId};
}

class Discounts extends SyncableTable {
  TextColumn get id => text().clientDefault(newId)();
  TextColumn get name => text()();
  TextColumn get nameAr => text().nullable()();
  TextColumn get type =>
      textEnum<DiscountType>().withDefault(const Constant('percent'))();
  IntColumn get percentBp => integer().withDefault(const Constant(0))();
  IntColumn get fixedMinor => integer().withDefault(const Constant(0))();
  TextColumn get scope =>
      textEnum<DiscountScope>().withDefault(const Constant('order'))();
  IntColumn get minSubtotalMinor => integer().withDefault(const Constant(0))();
  TextColumn get couponCode => text().nullable().unique()();
  DateTimeColumn get startsAt => dateTime().nullable()();
  DateTimeColumn get endsAt => dateTime().nullable()();
  IntColumn get priority => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}
