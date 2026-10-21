import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/money_text.dart';
import '../../../core/widgets/product_image.dart';
import '../data/reports_providers.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = ref.watch(reportRangeProvider);
    final summary = ref.watch(salesSummaryProvider);
    final breakdown = ref.watch(paymentBreakdownProvider);
    final topProducts = ref.watch(topProductsProvider);
    final lowStock = ref.watch(lowStockProvider);
    final currency = ref.watch(baseCurrencyProvider).value ?? kDefaultCurrency;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SegmentedButton<ReportRange>(
          segments: [
            for (final r in ReportRange.values)
              ButtonSegment(value: r, label: Text(r.label)),
          ],
          selected: {range},
          onSelectionChanged: (selection) =>
              ref.read(reportRangeProvider.notifier).state = selection.first,
        ),
        const SizedBox(height: 16),
        summary.when(
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => Text('Error: $e'),
          data: (s) => Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Sales',
                      value: '${s.count}',
                      icon: Icons.receipt_long_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Revenue',
                      valueText: MoneyText(
                        minor: s.revenueMinor,
                        symbol: currency.symbol,
                        symbolAfter: currency.symbolAfter,
                      ),
                      icon: Icons.payments_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Profit',
                      valueText: MoneyText(
                        minor: s.profitMinor,
                        symbol: currency.symbol,
                        symbolAfter: currency.symbolAfter,
                      ),
                      icon: Icons.trending_up_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Receivable',
                      valueText: MoneyText(
                        minor: s.dueMinor,
                        symbol: currency.symbol,
                        symbolAfter: currency.symbolAfter,
                      ),
                      icon: Icons.account_balance_wallet_outlined,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text('Payments', style: Theme.of(context).textTheme.titleMedium),
        breakdown.when(
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => Text('Error: $e'),
          data: (list) => list.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('No payments in this period'),
                )
              : Column(
                  children: [
                    for (final row in list)
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(_methodLabel(row.method.name)),
                        trailing: MoneyText(
                          minor: row.totalMinor,
                          symbol: currency.symbol,
                          symbolAfter: currency.symbolAfter,
                        ),
                      ),
                  ],
                ),
        ),
        const SizedBox(height: 16),
        Text('Top products', style: Theme.of(context).textTheme.titleMedium),
        topProducts.when(
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => Text('Error: $e'),
          data: (list) => list.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('No sales in this period'),
                )
              : Column(
                  children: [
                    for (final row in list)
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(row.name),
                        subtitle: Text('${formatQty(row.qtyMilli)} sold'),
                        trailing: MoneyText(
                          minor: row.totalMinor,
                          symbol: currency.symbol,
                          symbolAfter: currency.symbolAfter,
                        ),
                      ),
                  ],
                ),
        ),
        const SizedBox(height: 16),
        Text('Low stock', style: Theme.of(context).textTheme.titleMedium),
        lowStock.when(
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => Text('Error: $e'),
          data: (list) => list.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Stock levels look good'),
                )
              : Column(
                  children: [
                    for (final row in list)
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const ProductImage(imageUrl: null, size: 32),
                        title: Text(row.name),
                        subtitle: Text(row.sku),
                        trailing: Text(
                          formatQty(row.qtyMilli),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

String _methodLabel(String method) => switch (method) {
      'cash' => 'Cash',
      'card' => 'Card',
      'wallet' => 'Wallet',
      'credit' => 'Credit',
      'cheque' => 'Cheque',
      'loyalty' => 'Loyalty',
      _ => method,
    };

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.icon,
    this.value,
    this.valueText,
  });

  final String label;
  final IconData icon;
  final String? value;
  final Widget? valueText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.labelMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            valueText ??
                Text(value ?? '', style: theme.textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}
