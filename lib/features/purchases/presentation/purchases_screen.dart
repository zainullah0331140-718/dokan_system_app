import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/dokan_database.dart';
import '../../../core/di/providers.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/uuid.dart';
import '../../../core/widgets/money_text.dart';
import '../../../core/widgets/product_image.dart';
import '../../../features/auth/domain/auth_state.dart';
import '../../../features/auth/presentation/session_controller.dart';
import '../../customers/data/customers_providers.dart';
import '../../sales/data/sales_providers.dart';
import '../data/purchases_providers.dart';

class PurchasesScreen extends StatelessWidget {
  const PurchasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(tabs: [Tab(text: 'Purchases'), Tab(text: 'Suppliers')]),
          Expanded(
            child: TabBarView(
              children: const [_PurchasesTab(), _SuppliersTab()],
            ),
          ),
        ],
      ),
    );
  }
}

class _PurchasesTab extends ConsumerWidget {
  const _PurchasesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchases = ref.watch(purchasesListProvider);
    final currency = ref.watch(baseCurrencyProvider).value ?? kDefaultCurrency;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PurchaseFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: purchases.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No purchases yet'));
          }
          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final p = list[index];
              return ListTile(
                title: Text(p.invoiceNo),
                subtitle: Text(_statusLabel(p.status)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MoneyText(
                      minor: p.totalMinor,
                      symbol: currency.symbol,
                      symbolAfter: currency.symbolAfter,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    if (p.status != PurchaseStatus.received &&
                        p.status != PurchaseStatus.cancelled)
                      IconButton(
                        icon: const Icon(Icons.inventory_2_outlined),
                        tooltip: 'Receive stock',
                        onPressed: () => _receive(context, ref, p),
                      ),
                  ],
                ),
                onTap: () => _showDetail(context, ref, p),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _receive(BuildContext context, WidgetRef ref, Purchase p) async {
    final session = ref.read(sessionControllerProvider);
    if (session is! AuthStateAuthenticated) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Receive stock?'),
        content: Text('This will add ${p.invoiceNo} items into stock.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Receive'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(purchasesDaoProvider).markReceived(
            purchaseId: p.id,
            userId: session.user.id,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${p.invoiceNo} received into stock')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Receive failed: $e')),
        );
      }
    }
  }

  void _showDetail(BuildContext context, WidgetRef ref, Purchase p) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(p.invoiceNo, style: Theme.of(context).textTheme.titleLarge),
            Text(_statusLabel(p.status)),
            const SizedBox(height: 12),
            Consumer(
              builder: (context, innerRef, _) {
                final items = innerRef.watch(purchaseItemsProvider(p.id));
                return items.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text('Error: $e'),
                  data: (list) => Column(
                    children: [
                      for (final item in list)
                        ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text('Product ${item.productId}'),
                          subtitle: Text(
                            'Qty: ${formatQty(item.qtyMilli)} × '
                            '${formatMoney(item.unitCostMinor, symbol: r'$')}',
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

String _statusLabel(PurchaseStatus status) => switch (status) {
      PurchaseStatus.draft => 'Draft',
      PurchaseStatus.ordered => 'Ordered',
      PurchaseStatus.partiallyReceived => 'Partially received',
      PurchaseStatus.received => 'Received',
      PurchaseStatus.returned => 'Returned',
      PurchaseStatus.cancelled => 'Cancelled',
    };

class _SuppliersTab extends ConsumerWidget {
  const _SuppliersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suppliers = ref.watch(suppliersListProvider);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SupplierFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: suppliers.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No suppliers yet'));
          }
          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final s = list[index];
              return ListTile(
                title: Text(s.name),
                subtitle: Text(s.phone ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SupplierFormScreen(supplier: s),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class PurchaseFormScreen extends ConsumerStatefulWidget {
  const PurchaseFormScreen({super.key});

  @override
  ConsumerState<PurchaseFormScreen> createState() => _PurchaseFormScreenState();
}

class _PurchaseLine {
  Product? product;
  final qtyCtrl = TextEditingController(text: '1');
  final costCtrl = TextEditingController(text: '0');

  void dispose() {
    qtyCtrl.dispose();
    costCtrl.dispose();
  }
}

class _PurchaseFormScreenState extends ConsumerState<PurchaseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _supplierId;
  final List<_PurchaseLine> _lines = [_PurchaseLine()];
  final _paidCtrl = TextEditingController(text: '0');
  bool _isSaving = false;

  @override
  void dispose() {
    for (final line in _lines) {
      line.dispose();
    }
    _paidCtrl.dispose();
    super.dispose();
  }

  int get _subtotalMinor => _lines.fold(0, (sum, l) {
        final qty = qtyStringToMilli(l.qtyCtrl.text);
        final cost = toMinor(l.costCtrl.text);
        return sum + qty * cost ~/ 1000;
      });

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final session = ref.read(sessionControllerProvider);
    if (session is! AuthStateAuthenticated) return;
    final supplierId = _supplierId;
    if (supplierId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a supplier')),
      );
      return;
    }
    final items = _lines
        .where((l) => l.product != null)
        .map(
          (l) => (
            productId: l.product!.id,
            qtyMilli: qtyStringToMilli(l.qtyCtrl.text),
            unitCostMinor: toMinor(l.costCtrl.text),
          ),
        )
        .toList();
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one product')),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      final purchase = await ref.read(purchasesDaoProvider).createPurchase(
            userId: session.user.id,
            branchId: session.user.branchId ?? 'branch-main',
            supplierId: supplierId,
            items: items,
            paidMinor: toMinor(_paidCtrl.text),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Purchase ${purchase.invoiceNo} created')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save purchase: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final suppliers = ref.watch(suppliersListProvider);
    final products = ref.watch(posProductsProvider);
    final currency = ref.watch(baseCurrencyProvider).value ?? kDefaultCurrency;

    return Scaffold(
      appBar: AppBar(title: const Text('New Purchase')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            suppliers.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
              data: (list) => DropdownButtonFormField<String>(
                initialValue: _supplierId,
                decoration: const InputDecoration(
                  labelText: 'Supplier',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final s in list)
                    DropdownMenuItem(value: s.id, child: Text(s.name)),
                ],
                onChanged: (v) => setState(() => _supplierId = v),
                validator: (v) => v == null ? 'Required' : null,
              ),
            ),
            const SizedBox(height: 16),
            Text('Items', style: Theme.of(context).textTheme.titleMedium),
            for (var i = 0; i < _lines.length; i++)
              _buildLine(context, ref, products, _lines[i], i, currency),
            TextButton.icon(
              onPressed: () => setState(() => _lines.add(_PurchaseLine())),
              icon: const Icon(Icons.add),
              label: const Text('Add product'),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _paidCtrl,
              decoration: const InputDecoration(
                labelText: 'Paid now',
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal', style: Theme.of(context).textTheme.titleMedium),
                MoneyText(
                  minor: _subtotalMinor,
                  symbol: currency.symbol,
                  symbolAfter: currency.symbolAfter,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _isSaving ? null : _save,
              child: Text(_isSaving ? 'Saving...' : 'Save Purchase'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLine(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Product>> products,
    _PurchaseLine line,
    int index,
    CurrencyInfo currency,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: products.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
              data: (list) => DropdownButtonFormField<Product>(
                initialValue: line.product,
                decoration: const InputDecoration(
                  labelText: 'Product',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: [
                  for (final p in list)
                    DropdownMenuItem(
                      value: p,
                      child: Row(
                        children: [
                          ProductImage(imageUrl: p.imageUrl, size: 24, borderRadius: 4),
                          const SizedBox(width: 8),
                          Flexible(child: Text(p.name, overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                    ),
                ],
                onChanged: (p) => setState(() => line.product = p),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: line.qtyCtrl,
              decoration: const InputDecoration(
                labelText: 'Qty',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: line.costCtrl,
              decoration: const InputDecoration(
                labelText: 'Cost',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: _lines.length > 1
                ? () => setState(() {
                      line.dispose();
                      _lines.removeAt(index);
                    })
                : null,
          ),
        ],
      ),
    );
  }
}

class SupplierFormScreen extends ConsumerStatefulWidget {
  const SupplierFormScreen({super.key, this.supplier});

  final Supplier? supplier;

  @override
  ConsumerState<SupplierFormScreen> createState() => _SupplierFormScreenState();
}

class _SupplierFormScreenState extends ConsumerState<SupplierFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.supplier?.name ?? '');
    _phoneCtrl = TextEditingController(text: widget.supplier?.phone ?? '');
    _emailCtrl = TextEditingController(text: widget.supplier?.email ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final dao = ref.read(suppliersDaoProvider);
    try {
      if (widget.supplier == null) {
        await dao.insertSupplier(
          SuppliersCompanion.insert(
            id: Value(newId()),
            name: _nameCtrl.text.trim(),
            phone: Value(_phoneCtrl.text.trim().isEmpty
                ? null
                : _phoneCtrl.text.trim()),
            email: Value(_emailCtrl.text.trim().isEmpty
                ? null
                : _emailCtrl.text.trim()),
          ),
        );
      } else {
        await dao.updateSupplier(
          widget.supplier!.id,
          SuppliersCompanion(
            name: Value(_nameCtrl.text.trim()),
            phone: Value(_phoneCtrl.text.trim().isEmpty
                ? null
                : _phoneCtrl.text.trim()),
            email: Value(_emailCtrl.text.trim().isEmpty
                ? null
                : _emailCtrl.text.trim()),
          ),
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save supplier: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.supplier != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Supplier' : 'Add Supplier')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailCtrl,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _isSaving ? null : _save,
              child: Text(_isSaving ? 'Saving...' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}
