import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/daos/audit_dao.dart';
import '../database/daos/auth_dao.dart';
import '../database/daos/customers_dao.dart';
import '../database/daos/outbox_dao.dart';
import '../database/daos/products_dao.dart';
import '../database/daos/purchases_dao.dart';
import '../database/daos/reports_dao.dart';
import '../database/daos/sales_dao.dart';
import '../database/daos/settings_dao.dart';
import '../database/daos/shifts_dao.dart';
import '../database/daos/stock_dao.dart';
import '../database/dokan_database.dart';
import '../security/database_key_store.dart';
import '../security/secure_storage_service.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  throw UnimplementedError(
    'secureStorageProvider must be overridden at app startup',
  );
});

final databaseKeyStoreProvider = Provider<DatabaseKeyStore>(
  (ref) => DatabaseKeyStore(ref.watch(secureStorageProvider)),
);

final databaseProvider = Provider<DokanDatabase>((ref) {
  throw UnimplementedError('databaseProvider must be overridden at app startup');
});

final settingsDaoProvider = Provider<SettingsDao>(
  (ref) => ref.watch(databaseProvider).settingsDao,
);

final authDaoProvider = Provider<AuthDao>(
  (ref) => ref.watch(databaseProvider).authDao,
);

final outboxDaoProvider = Provider<OutboxDao>(
  (ref) => ref.watch(databaseProvider).outboxDao,
);

final auditDaoProvider = Provider<AuditDao>(
  (ref) => ref.watch(databaseProvider).auditDao,
);

final productsDaoProvider = Provider<ProductsDao>(
  (ref) => ref.watch(databaseProvider).productsDao,
);

final customersDaoProvider = Provider<CustomersDao>(
  (ref) => ref.watch(databaseProvider).customersDao,
);

final suppliersDaoProvider = Provider<SuppliersDao>(
  (ref) => ref.watch(databaseProvider).suppliersDao,
);

final stockDaoProvider = Provider<StockDao>(
  (ref) => ref.watch(databaseProvider).stockDao,
);

final shiftsDaoProvider = Provider<ShiftsDao>(
  (ref) => ref.watch(databaseProvider).shiftsDao,
);

final salesDaoProvider = Provider<SalesDao>(
  (ref) => ref.watch(databaseProvider).salesDao,
);

final purchasesDaoProvider = Provider<PurchasesDao>(
  (ref) => ref.watch(databaseProvider).purchasesDao,
);

final reportsDaoProvider = Provider<ReportsDao>(
  (ref) => ref.watch(databaseProvider).reportsDao,
);

class CurrencyInfo {
  const CurrencyInfo({
    required this.code,
    required this.symbol,
    required this.symbolAfter,
  });

  final String code;
  final String symbol;
  final bool symbolAfter;
}

const CurrencyInfo kDefaultCurrency = CurrencyInfo(
  code: 'USD',
  symbol: r'$',
  symbolAfter: false,
);

final baseCurrencyProvider = FutureProvider<CurrencyInfo>((ref) async {
  final currency = await ref.watch(settingsDaoProvider).getBaseCurrency();
  if (currency == null) return kDefaultCurrency;
  return CurrencyInfo(
    code: currency.code,
    symbol: currency.symbol,
    symbolAfter:
        currency.symbolPosition == CurrencySymbolPosition.after,
  );
});

final defaultBranchIdProvider = FutureProvider<String>((ref) async {
  final branch =
      await ref.watch(settingsDaoProvider).getDefaultBranch();
  return branch?.id ?? 'branch-main';
});

final bootstrapLocaleProvider = Provider<Locale?>((ref) => null);

final bootstrapThemeModeProvider = Provider<ThemeMode>((ref) => ThemeMode.system);
