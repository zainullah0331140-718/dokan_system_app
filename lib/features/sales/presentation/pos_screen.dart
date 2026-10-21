import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/dokan_database.dart';
import '../../../core/di/providers.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/money_text.dart';
import '../../../core/widgets/product_image.dart';
import '../../../features/auth/domain/auth_state.dart';
import '../../../features/auth/presentation/session_controller.dart';
import '../../../features/customers/data/customers_providers.dart';
import '../../shifts/data/shifts_providers.dart';
import '../../shifts/presentation/shifts_screen.dart';
import '../data/cart_controller.dart';
import '../data/sales_providers.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(tabs: [Tab(text: 'Sell'), Tab(text: 'History')]),
          Expanded(
            child: TabBarView(
              children: const [_PosSellTab(), _SalesHistoryTab()],
            ),
          ),
        ],
      ),
    );
  }
}

class _PosSellTab extends ConsumerWidget {
  const _PosSellTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final openShift = ref.watch(currentOpenShiftProvider);
    return openShift.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (shift) {
        if (shift == null) return const _NoShiftView();
        return const _PosBody();
      },
    );
  }
}

class _NoShiftView extends ConsumerWidget {
  const _NoShiftView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);
    if (session is! AuthStateAuthenticated) {
      return const SizedBox.shrink();
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Open the register before making sales',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => showOpenRegisterDialog(
                context,
                ref,
                session.user.id,
                session.user.branchId ?? 'branch-main',
              ),
              icon: const Icon(Icons.lock_open_outlined),
              label: const Text('Open Register'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PosBody extends ConsumerWidget {
  const _PosBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final currency = ref.watch(baseCurrencyProvider).value ?? kDefaultCurrency;
    final products = ref.watch(posProductsProvider);
    final query = ref.watch(productSearchQueryProvider).toLowerCase();
    final customers = ref.watch(customersListProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search name, SKU or barcode…',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (v) =>
                ref.read(productSearchQueryProvider.notifier).state = v,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: customers.when(
            loading: () => const SizedBox.shrink(),
            error: (e, _) => const SizedBox.shrink(),
            data: (list) => DropdownButtonFormField<String?>(
              initialValue: cart.customerId,
              decoration: const InputDecoration(
                labelText: 'Customer (optional)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Walk-in'),
                ),
                for (final c in list)
                  DropdownMenuItem<String?>(value: c.id, child: Text(c.name)),
              ],
              onChanged: (v) => ref.read(cartProvider.notifier).setCustomer(v),
            ),
          ),
        ),
        Expanded(
          child: products.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (list) {
              final filtered = query.isEmpty
                  ? list
                  : list
                      .where(
                        (p) =>
                            p.name.toLowerCase().contains(query) ||
                            p.sku.toLowerCase().contains(query) ||
                            (p.barcode?.toLowerCase().contains(query) ?? false),
                      )
                      .toList();
              if (filtered.isEmpty) {
                return const Center(child: Text('No products found'));
              }
              return ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final p = filtered[index];
                  return ListTile(
                    leading: ProductImage(imageUrl: p.imageUrl, size: 40),
                    title: Text(p.name),
                    subtitle: Text(p.sku),
                    trailing: MoneyText(
                      minor: p.salePriceMinor,
                      symbol: currency.symbol,
                      symbolAfter: currency.symbolAfter,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    onTap: () => ref.read(cartProvider.notifier).add(p),
                  );
                },
              );
            },
          ),
        ),
        if (!cart.isEmpty)
          Material(
            elevation: 8,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${cart.itemCount} item(s)',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    MoneyText(
                      minor: cart.subtotalMinor,
                      symbol: currency.symbol,
                      symbolAfter: currency.symbolAfter,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () => _showCartSheet(context, ref),
                      child: const Text('Cart'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () => _showCheckoutDialog(context, ref),
                      child: const Text('Charge'),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showCartSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => const FractionallySizedBox(
        heightFactor: 0.6,
        child: _CartSheet(),
      ),
    );
  }

  Future<void> _showCheckoutDialog(BuildContext context, WidgetRef ref) =>
      runCheckout(context, ref);
}

Future<void> runCheckout(BuildContext context, WidgetRef ref) async {
  final cart = ref.read(cartProvider);
  if (cart.isEmpty) return;
  final currency = await ref.read(baseCurrencyProvider.future);
  if (!context.mounted) return;
  final result = await showDialog<_PaymentResult>(
    context: context,
    builder: (dialogContext) => _CheckoutDialog(
      totalMinor: cart.subtotalMinor,
      currency: currency,
    ),
  );
  if (result == null) return;

  final session = ref.read(sessionControllerProvider);
  final shift = ref.read(currentOpenShiftProvider).value;
  if (session is! AuthStateAuthenticated || shift == null) return;
  final userId = session.user.id;
  final branchId = session.user.branchId ?? 'branch-main';

  final lines = cart.lines
      .map(
        (l) => (
          productId: l.product.id,
          nameSnapshot: l.product.name,
          nameArSnapshot: l.product.nameAr,
          skuSnapshot: l.product.sku,
          barcodeSnapshot: l.product.barcode,
          qtyMilli: l.qtyMilli,
          unitPriceMinor: l.unitPriceMinor,
          unitCostMinor: l.product.costPriceMinor,
        ),
      )
      .toList();

  try {
    final sale = await ref.read(salesDaoProvider).checkout(
          userId: userId,
          branchId: branchId,
          items: lines,
          method: result.method,
          customerId: cart.customerId,
          shiftId: shift.id,
          currencyCode: currency.code,
          tenderedMinor: result.tenderedMinor,
        );
    ref.read(cartProvider.notifier).clear();
    ref.invalidate(recentSalesProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sale ${sale.invoiceNo} completed')),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sale failed: $e')),
      );
    }
  }
}

class _PaymentResult {
  const _PaymentResult(this.method, this.tenderedMinor);

  final PayMethod method;
  final int? tenderedMinor;
}

class _CheckoutDialog extends StatefulWidget {
  const _CheckoutDialog({required this.totalMinor, required this.currency});

  final int totalMinor;
  final CurrencyInfo currency;

  @override
  State<_CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends State<_CheckoutDialog> {
  PayMethod _method = PayMethod.cash;
  late final TextEditingController _tenderedCtrl;

  @override
  void initState() {
    super.initState();
    _tenderedCtrl = TextEditingController(
      text: (widget.totalMinor / 100).toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _tenderedCtrl.dispose();
    super.dispose();
  }

  int get _tendered => toMinor(_tenderedCtrl.text);
  int get _change =>
      _method == PayMethod.cash && _tendered > widget.totalMinor
          ? _tendered - widget.totalMinor
          : 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Checkout'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total'),
              MoneyText(
                minor: widget.totalMinor,
                symbol: widget.currency.symbol,
                symbolAfter: widget.currency.symbolAfter,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<PayMethod>(
            initialValue: _method,
            decoration: const InputDecoration(
              labelText: 'Payment method',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: const [
              DropdownMenuItem(value: PayMethod.cash, child: Text('Cash')),
              DropdownMenuItem(value: PayMethod.card, child: Text('Card')),
              DropdownMenuItem(value: PayMethod.credit, child: Text('Credit')),
            ],
            onChanged: (v) => setState(() => _method = v ?? PayMethod.cash),
          ),
          if (_method == PayMethod.cash) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _tenderedCtrl,
              decoration: const InputDecoration(
                labelText: 'Cash tendered',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Change'),
                MoneyText(
                  minor: _change,
                  symbol: widget.currency.symbol,
                  symbolAfter: widget.currency.symbolAfter,
                ),
              ],
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _method == PayMethod.cash && _tendered < widget.totalMinor
              ? null
              : () => Navigator.of(context).pop(
                    _PaymentResult(
                      _method,
                      _method == PayMethod.cash ? _tendered : null,
                    ),
                  ),
          child: const Text('Complete Sale'),
        ),
      ],
    );
  }
}

class _CartSheet extends ConsumerWidget {
  const _CartSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final currency = ref.watch(baseCurrencyProvider).value ?? kDefaultCurrency;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                'Cart',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: cart.lines.length,
            itemBuilder: (context, index) {
              final line = cart.lines[index];
              return ListTile(
                dense: true,
                title: Text(line.product.name),
                subtitle: MoneyText(
                  minor: line.unitPriceMinor,
                  symbol: currency.symbol,
                  symbolAfter: currency.symbolAfter,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => ref
                          .read(cartProvider.notifier)
                          .decrement(line.product.id),
                    ),
                    Text('${line.qtyMilli ~/ 1000}'),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => ref
                          .read(cartProvider.notifier)
                          .increment(line.product.id),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () =>
                          ref.read(cartProvider.notifier).remove(line.product.id),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: MoneyText(
                    minor: cart.subtotalMinor,
                    symbol: currency.symbol,
                    symbolAfter: currency.symbolAfter,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ref.read(cartProvider.notifier).clear();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Clear'),
                ),
                FilledButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await runCheckout(context, ref);
                  },
                  child: const Text('Charge'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SalesHistoryTab extends ConsumerWidget {
  const _SalesHistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sales = ref.watch(recentSalesProvider);
    final currency = ref.watch(baseCurrencyProvider).value ?? kDefaultCurrency;

    return sales.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (list) {
        if (list.isEmpty) {
          return const Center(child: Text('No sales yet'));
        }
        return ListView.separated(
          itemCount: list.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final s = list[index];
            return ListTile(
              title: Text(s.invoiceNo),
              subtitle: Text(_fmtDateTime(s.soldAt)),
              trailing: MoneyText(
                minor: s.totalMinor,
                symbol: currency.symbol,
                symbolAfter: currency.symbolAfter,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              onTap: () => _showSaleDetail(context, ref, s),
            );
          },
        );
      },
    );
  }

  void _showSaleDetail(BuildContext context, WidgetRef ref, Sale sale) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(sale.invoiceNo, style: Theme.of(context).textTheme.titleLarge),
            Text(_fmtDateTime(sale.soldAt)),
            const SizedBox(height: 12),
            Consumer(
              builder: (context, innerRef, _) {
                final items = innerRef.watch(saleItemsProvider(sale.id));
                return items.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text('Error: $e'),
                  data: (list) => Column(
                    children: [
                      for (final item in list)
                        ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(item.nameSnapshot),
                          subtitle: Text(
                            '${formatQty(item.qtyMilli)} × '
                            '${formatMoney(item.unitPriceMinor, symbol: r'$')}',
                          ),
                          trailing: MoneyText(
                            minor: item.totalMinor,
                            symbol: r'$',
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

String _fmtDateTime(DateTime dt) {
  final local = dt.toLocal();
  final d = local.day.toString().padLeft(2, '0');
  final m = local.month.toString().padLeft(2, '0');
  final h = local.hour.toString().padLeft(2, '0');
  final min = local.minute.toString().padLeft(2, '0');
  return '$d/$m $h:$min';
}
