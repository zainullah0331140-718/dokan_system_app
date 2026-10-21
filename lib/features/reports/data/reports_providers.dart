import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../core/database/daos/reports_dao.dart';
import '../../../core/di/providers.dart';

enum ReportRange { today, last7Days, last30Days }

extension ReportRangeX on ReportRange {
  (DateTime, DateTime) get bounds {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (this) {
      case ReportRange.today:
        return (today, today.add(const Duration(days: 1)));
      case ReportRange.last7Days:
        return (today.subtract(const Duration(days: 6)), today.add(const Duration(days: 1)));
      case ReportRange.last30Days:
        return (today.subtract(const Duration(days: 29)), today.add(const Duration(days: 1)));
    }
  }

  String get label => switch (this) {
        ReportRange.today => 'Today',
        ReportRange.last7Days => 'Last 7 days',
        ReportRange.last30Days => 'Last 30 days',
      };
}

final reportRangeProvider =
    StateProvider<ReportRange>((ref) => ReportRange.today);

final salesSummaryProvider = FutureProvider<SalesSummary>((ref) async {
  final range = ref.watch(reportRangeProvider);
  final (from, to) = range.bounds;
  return ref.watch(reportsDaoProvider).salesSummary(from, to);
});

final paymentBreakdownProvider =
    FutureProvider<List<PaymentMethodBreakdown>>((ref) async {
  final range = ref.watch(reportRangeProvider);
  final (from, to) = range.bounds;
  return ref.watch(reportsDaoProvider).paymentBreakdown(from, to);
});

final topProductsProvider = FutureProvider<List<TopProductRow>>((ref) async {
  final range = ref.watch(reportRangeProvider);
  final (from, _) = range.bounds;
  return ref.watch(reportsDaoProvider).topProducts(from);
});

final lowStockProvider =
    StreamProvider<List<({String productId, String name, String sku, int qtyMilli, int alertMilli})>>(
        (ref) {
  return ref.watch(stockDaoProvider).watchLowStock();
});
