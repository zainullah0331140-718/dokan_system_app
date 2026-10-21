import 'package:drift/drift.dart';

import '../../constants/app_constants.dart';
import '../enums.dart';
import '../../utils/uuid.dart';
import 'syncable.dart';

class BusinessSettings extends SyncableTable {
  TextColumn get id => text().clientDefault(newId)();
  TextColumn get shopName => text().withDefault(const Constant('My Shop'))();
  TextColumn get shopNameAr => text().nullable()();
  TextColumn get taxNumber => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get addressAr => text().nullable()();
  TextColumn get logoPath => text().nullable()();
  TextColumn get receiptFooter => text().nullable()();
  TextColumn get receiptFooterAr => text().nullable()();
  TextColumn get invoicePrefix => text().withDefault(const Constant('INV'))();
  TextColumn get baseCurrencyCode =>
      text().withDefault(const Constant('USD'))();
  TextColumn get defaultTaxId => text().nullable()();
  TextColumn get defaultBranchId => text().nullable()();
  IntColumn get lowStockDefaultMilli => integer()
      .withDefault(const Constant(AppConstants.lowStockThresholdMilli))();
  IntColumn get loyaltyEarnRateMicro =>
      integer().withDefault(const Constant(1000000))();
  IntColumn get loyaltyRedeemRateMicro =>
      integer().withDefault(const Constant(10000))();
  BoolColumn get taxPricesInclusive =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class AppPreferences extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {key};
}

@DataClassName('Branch')
class Branches extends SyncableTable {
  TextColumn get id => text().clientDefault(newId)();
  TextColumn get code => text().unique()();
  TextColumn get name => text()();
  TextColumn get nameAr => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get phone => text().nullable()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class Currencies extends SyncableTable {
  TextColumn get id => text().clientDefault(newId)();
  TextColumn get code => text().unique()();
  TextColumn get symbol => text()();
  TextColumn get symbolPosition =>
      textEnum<CurrencySymbolPosition>().withDefault(const Constant('before'))();
  IntColumn get decimalPlaces => integer().withDefault(const Constant(2))();
  BoolColumn get isBase => boolean().withDefault(const Constant(false))();
  IntColumn get exchangeRateMicro =>
      integer().withDefault(const Constant(1000000))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Tax')
class Taxes extends SyncableTable {
  TextColumn get id => text().clientDefault(newId)();
  TextColumn get name => text()();
  TextColumn get nameAr => text().nullable()();
  IntColumn get rateBp => integer()();
  BoolColumn get isInclusive => boolean().withDefault(const Constant(false))();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class InvoiceCounters extends Table {
  TextColumn get id => text()();
  TextColumn get branchId => text().references(Branches, #id)();
  TextColumn get series => text()();
  TextColumn get period => text()();
  IntColumn get nextValue => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [{branchId, series, period}];
}

class Printers extends SyncableTable {
  TextColumn get id => text().clientDefault(newId)();
  TextColumn get name => text()();
  TextColumn get connection => textEnum<PrinterConnection>()();
  TextColumn get address => text().nullable()();
  IntColumn get port => integer().nullable()();
  IntColumn get paperWidthMm => integer().withDefault(const Constant(80))();
  TextColumn get role =>
      textEnum<PrinterRole>().withDefault(const Constant('receipt'))();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  IntColumn get copies => integer().withDefault(const Constant(1))();
  BoolColumn get cutPaper => boolean().withDefault(const Constant(false))();
  BoolColumn get openDrawer => boolean().withDefault(const Constant(true))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class PrintJobs extends Table {
  TextColumn get id => text().clientDefault(newId)();
  TextColumn get printerId => text().nullable()();
  TextColumn get jobType => text()();
  TextColumn get payloadJson => text()();
  TextColumn get status =>
      textEnum<PrinterJobStatus>().withDefault(const Constant('queued'))();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Devices extends Table {
  TextColumn get id => text().clientDefault(newId)();
  TextColumn get deviceId => text().unique()();
  TextColumn get platform => text()();
  TextColumn get deviceName => text().withDefault(const Constant(''))();
  TextColumn get appVersion => text().withDefault(const Constant(''))();
  DateTimeColumn get lastSeenAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class AuditLogs extends SyncableTable {
  TextColumn get id => text().clientDefault(newId)();
  TextColumn get userId => text().nullable()();
  TextColumn get branchId => text().nullable()();
  TextColumn get action => text()();
  TextColumn get entity => text()();
  TextColumn get entityId => text().nullable()();
  TextColumn get beforeJson => text().nullable()();
  TextColumn get afterJson => text().nullable()();
  TextColumn get deviceId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class SyncOutbox extends Table {
  TextColumn get id => text().clientDefault(newId)();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get action => textEnum<OutboxAction>()();
  TextColumn get payload => text()();
  TextColumn get status =>
      textEnum<OutboxStatus>().withDefault(const Constant('pending'))();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextRetryAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class SyncCursors extends Table {
  TextColumn get entity => text()();
  TextColumn get cursor => text().nullable()();
  DateTimeColumn get lastPulledAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {entity};
}

class Backups extends Table {
  TextColumn get id => text().clientDefault(newId)();
  TextColumn get path => text()();
  IntColumn get sizeBytes => integer().withDefault(const Constant(0))();
  TextColumn get trigger =>
      textEnum<BackupTrigger>().withDefault(const Constant('manual'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
