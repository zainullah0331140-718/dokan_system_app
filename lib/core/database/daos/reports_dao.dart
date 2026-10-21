import 'package:drift/drift.dart';

import '../dokan_database.dart';

part 'reports_dao.g.dart';

class SalesSummary {
  const SalesSummary({
    required this.count,
    required this.revenueMinor,
    required this.costMinor,
    required this.paidMinor,
    required this.dueMinor,
  });

  final int count;
  final int revenueMinor;
  final int costMinor;
  final int paidMinor;
  final int dueMinor;

  int get profitMinor => revenueMinor - costMinor;
}

class PaymentMethodBreakdown {
  const PaymentMethodBreakdown({required this.method, required this.totalMinor});

  final PayMethod method;
  final int totalMinor;
}

class TopProductRow {
  const TopProductRow({
    required this.productId,
    required this.name,
    required this.qtyMilli,
    required this.totalMinor,
  });

  final String productId;
  final String name;
  final int qtyMilli;
  final int totalMinor;
}

@DriftAccessor(tables: [Sales, SaleItems, Payments, Products])
class ReportsDao extends DatabaseAccessor<DokanDatabase>
    with _$ReportsDaoMixin {
  ReportsDao(super.db);

  Future<SalesSummary> salesSummary(DateTime from, DateTime to) async {
    final count = sales.id.count();
    final revenue = sales.totalMinor.sum();
    final cost = sales.costTotalMinor.sum();
    final paid = sales.paidMinor.sum();
    final due = sales.dueMinor.sum();
    final query = selectOnly(sales)
      ..addColumns([count, revenue, cost, paid, due])
      ..where(
        sales.isDeleted.equals(false) &
            sales.status.equals(SaleStatus.completed.name) &
            sales.soldAt.isBiggerOrEqualValue(from) &
            sales.soldAt.isSmallerThanValue(to),
      );
    final row = await query.getSingle();
    return SalesSummary(
      count: row.read(count) ?? 0,
      revenueMinor: row.read(revenue) ?? 0,
      costMinor: row.read(cost) ?? 0,
      paidMinor: row.read(paid) ?? 0,
      dueMinor: row.read(due) ?? 0,
    );
  }

  Future<List<PaymentMethodBreakdown>> paymentBreakdown(
    DateTime from,
    DateTime to,
  ) async {
    final rows = await (select(payments)
          ..where(
            (p) =>
                p.refType.equals(PaymentRefType.sale.name) &
                p.createdAt.isBiggerOrEqualValue(from) &
                p.createdAt.isSmallerThanValue(to),
          ))
        .get();
    final totals = <PayMethod, int>{};
    for (final row in rows) {
      totals[row.method] = (totals[row.method] ?? 0) + row.amountMinor;
    }
    return [
      for (final entry in totals.entries)
        PaymentMethodBreakdown(method: entry.key, totalMinor: entry.value),
    ];
  }

  Future<List<TopProductRow>> topProducts(
    DateTime from, {
    int limit = 10,
  }) async {
    final qty = saleItems.qtyMilli.sum();
    final total = saleItems.totalMinor.sum();
    final query = selectOnly(saleItems)
      ..addColumns([saleItems.productId, saleItems.nameSnapshot, qty, total])
      ..join([
        innerJoin(
          sales,
          sales.id.equalsExp(saleItems.saleId),
        ),
      ])
      ..where(
        sales.isDeleted.equals(false) &
            sales.status.equals(SaleStatus.completed.name) &
            sales.soldAt.isBiggerOrEqualValue(from),
      )
      ..groupBy([saleItems.productId, saleItems.nameSnapshot])
      ..orderBy([
        OrderingTerm.desc(total, nulls: NullsOrder.last),
      ])
      ..limit(limit);
    final rows = await query.get();
    return [
      for (final row in rows)
        TopProductRow(
          productId: row.read(saleItems.productId)!,
          name: row.read(saleItems.nameSnapshot)!,
          qtyMilli: row.read(qty) ?? 0,
          totalMinor: row.read(total) ?? 0,
        ),
    ];
  }
}
