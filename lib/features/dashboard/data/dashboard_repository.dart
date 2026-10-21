import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/dokan_database.dart';
import '../../../core/di/providers.dart';

class DashboardStats {
  const DashboardStats({
    required this.productCount,
    required this.customerCount,
    required this.supplierCount,
    required this.todaySalesCount,
    required this.todayRevenueMinor,
    required this.pendingSync,
  });

  final int productCount;
  final int customerCount;
  final int supplierCount;
  final int todaySalesCount;
  final int todayRevenueMinor;
  final int pendingSync;
}

class DashboardRepository {
  DashboardRepository(this._db);

  final DokanDatabase _db;

  Future<DashboardStats> load() async {
    final now = DateTime.now();
    final dayStart = DateTime(now.year, now.month, now.day);

    final salesCountExpr = _db.sales.id.count();
    final salesSumExpr = _db.sales.totalMinor.sum();
    final salesQuery = _db.selectOnly(_db.sales)
      ..addColumns([salesCountExpr, salesSumExpr])
      ..where(
        _db.sales.isDeleted.equals(false) &
            _db.sales.status.equals('completed') &
            _db.sales.soldAt.isBiggerOrEqualValue(dayStart),
      );
    final salesRow = await salesQuery.getSingle();

    return DashboardStats(
      productCount: await _countProducts(),
      customerCount: await _countCustomers(),
      supplierCount: await _countSuppliers(),
      todaySalesCount: salesRow.read(salesCountExpr) ?? 0,
      todayRevenueMinor: salesRow.read(salesSumExpr) ?? 0,
      pendingSync: await _db.outboxDao.pendingCount(),
    );
  }

  Future<int> _countProducts() async {
    final count = _db.products.id.count();
    final query = _db.selectOnly(_db.products)
      ..addColumns([count])
      ..where(_db.products.isDeleted.equals(false));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  Future<int> _countCustomers() async {
    final count = _db.customers.id.count();
    final query = _db.selectOnly(_db.customers)
      ..addColumns([count])
      ..where(_db.customers.isDeleted.equals(false));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  Future<int> _countSuppliers() async {
    final count = _db.suppliers.id.count();
    final query = _db.selectOnly(_db.suppliers)
      ..addColumns([count])
      ..where(_db.suppliers.isDeleted.equals(false));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }
}

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) {
  final db = ref.watch(databaseProvider);
  return DashboardRepository(db).load();
});
