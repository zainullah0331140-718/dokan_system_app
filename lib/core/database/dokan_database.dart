import 'package:drift/drift.dart';

import '../constants/app_constants.dart';
import '../utils/uuid.dart';
import 'daos/audit_dao.dart';
import 'daos/auth_dao.dart';
import 'daos/customers_dao.dart';
import 'daos/outbox_dao.dart';
import 'daos/products_dao.dart';
import 'daos/purchases_dao.dart';
import 'daos/reports_dao.dart';
import 'daos/sales_dao.dart';
import 'daos/settings_dao.dart';
import 'daos/shifts_dao.dart';
import 'daos/stock_dao.dart';
import 'enums.dart';
import 'seeds.dart';
import 'tables/catalog_tables.dart';
import 'tables/identity_tables.dart';
import 'tables/inventory_tables.dart';
import 'tables/party_tables.dart';
import 'tables/purchasing_tables.dart';
import 'tables/sales_tables.dart';
import 'tables/shift_tables.dart';
import 'tables/system_tables.dart';

export 'enums.dart';
export 'tables/catalog_tables.dart';
export 'tables/identity_tables.dart';
export 'tables/inventory_tables.dart';
export 'tables/party_tables.dart';
export 'tables/purchasing_tables.dart';
export 'tables/sales_tables.dart';
export 'tables/shift_tables.dart';
export 'tables/system_tables.dart';

part 'dokan_database.g.dart';

@DriftDatabase(
  tables: [
    AppPreferences,
    AuditLogs,
    Backups,
    Branches,
    BusinessSettings,
    Categories,
    Currencies,
    Customers,
    Devices,
    Discounts,
    InvoiceCounters,
    LoyaltyTransactions,
    Payments,
    Permissions,
    PrintJobs,
    Printers,
    ProductBranchOverrides,
    ProductVariants,
    Products,
    PurchaseItems,
    Purchases,
    RefundItems,
    Refunds,
    RolePermissions,
    Roles,
    SaleItems,
    Sales,
    ShiftTransactions,
    Shifts,
    StockAdjustmentItems,
    StockAdjustments,
    StockBalances,
    StockMovements,
    StockTransferItems,
    StockTransfers,
    Suppliers,
    SyncCursors,
    SyncOutbox,
    Taxes,
    Units,
    UserBranches,
    UserRoles,
    Users,
  ],
)
class DokanDatabase extends _$DokanDatabase {
  DokanDatabase(super.executor);

  DokanDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await seedInitialData(this);
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement('PRAGMA journal_mode = WAL');
      await customStatement('PRAGMA busy_timeout = 5000');
    },
  );

  late final settingsDao = SettingsDao(this);
  late final authDao = AuthDao(this);
  late final outboxDao = OutboxDao(this);
  late final auditDao = AuditDao(this);
  late final productsDao = ProductsDao(this);
  late final customersDao = CustomersDao(this);
  late final suppliersDao = SuppliersDao(this);
  late final stockDao = StockDao(this);
  late final shiftsDao = ShiftsDao(this);
  late final salesDao = SalesDao(this);
  late final purchasesDao = PurchasesDao(this);
  late final reportsDao = ReportsDao(this);
}
