import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/dokan_database.dart';
import '../../../core/di/providers.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/uuid.dart';
import '../../../core/widgets/product_image.dart';
import '../data/products_providers.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({super.key, this.product});

  final Product? product;

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _skuCtrl;
  late final TextEditingController _barcodeCtrl;
  late final TextEditingController _costCtrl;
  late final TextEditingController _saleCtrl;
  late final TextEditingController _imageCtrl;
  String? _categoryId;
  String? _unitId;
  bool _trackStock = true;
  bool _isActive = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _skuCtrl = TextEditingController(text: p?.sku ?? '');
    _barcodeCtrl = TextEditingController(text: p?.barcode ?? '');
    _costCtrl = TextEditingController(
      text: p == null ? '0' : (p.costPriceMinor / 100).toStringAsFixed(2),
    );
    _saleCtrl = TextEditingController(
      text: p == null ? '0' : (p.salePriceMinor / 100).toStringAsFixed(2),
    );
    _imageCtrl = TextEditingController(text: p?.imageUrl ?? '');
    _categoryId = p?.categoryId;
    _unitId = p?.unitId;
    _trackStock = p?.trackStock ?? true;
    _isActive = p?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _skuCtrl.dispose();
    _barcodeCtrl.dispose();
    _costCtrl.dispose();
    _saleCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final dao = ref.read(productsDaoProvider);
    try {
      final imageUrl = _imageCtrl.text.trim();
      if (widget.product == null) {
        final companion = ProductsCompanion.insert(
          id: Value(newId()),
          sku: _skuCtrl.text.trim(),
          barcode: Value(_barcodeCtrl.text.trim().isEmpty
              ? null
              : _barcodeCtrl.text.trim()),
          name: _nameCtrl.text.trim(),
          categoryId: Value(_categoryId),
          unitId: _unitId ?? 'unit-piece',
          costPriceMinor: Value(toMinor(_costCtrl.text)),
          salePriceMinor: Value(toMinor(_saleCtrl.text)),
          trackStock: Value(_trackStock),
          isActive: Value(_isActive),
          imageUrl: Value(imageUrl.isEmpty ? null : imageUrl),
        );
        await dao.insertProduct(companion);
      } else {
        final companion = ProductsCompanion(
          name: Value(_nameCtrl.text.trim()),
          sku: Value(_skuCtrl.text.trim()),
          barcode: Value(_barcodeCtrl.text.trim().isEmpty
              ? null
              : _barcodeCtrl.text.trim()),
          categoryId: Value(_categoryId),
          unitId: Value(_unitId ?? widget.product!.unitId),
          costPriceMinor: Value(toMinor(_costCtrl.text)),
          salePriceMinor: Value(toMinor(_saleCtrl.text)),
          trackStock: Value(_trackStock),
          isActive: Value(_isActive),
          imageUrl: Value(imageUrl.isEmpty ? null : imageUrl),
        );
        await dao.updateProduct(widget.product!.id, companion);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save product: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final units = ref.watch(unitsProvider);
    final isEdit = widget.product != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Product' : 'Add Product')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Product Name',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _skuCtrl,
              decoration: const InputDecoration(
                labelText: 'SKU',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _barcodeCtrl,
              decoration: const InputDecoration(
                labelText: 'Barcode (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _costCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Cost Price',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _saleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Sale Price',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _imageCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Image URL (optional)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                ProductImage(
                  imageUrl: _imageCtrl.text.trim().isEmpty
                      ? null
                      : _imageCtrl.text.trim(),
                  size: 56,
                ),
              ],
            ),
            const SizedBox(height: 12),
            categories.when(
              data: (list) => DropdownButtonFormField<String>(
                initialValue: _categoryId,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('None'),
                  ),
                  for (final c in list)
                    DropdownMenuItem<String>(
                      value: c.id,
                      child: Text(c.name),
                    ),
                ],
                onChanged: (v) => setState(() => _categoryId = v),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
            ),
            const SizedBox(height: 12),
            units.when(
              data: (list) => DropdownButtonFormField<String>(
                initialValue: _unitId ?? list.firstOrNull?.id,
                decoration: const InputDecoration(
                  labelText: 'Unit',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final u in list)
                    DropdownMenuItem<String>(
                      value: u.id,
                      child: Text(u.name),
                    ),
                ],
                onChanged: (v) => setState(() => _unitId = v),
                validator: (v) => v == null ? 'Required' : null,
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Track Stock'),
              value: _trackStock,
              onChanged: (v) => setState(() => _trackStock = v),
            ),
            SwitchListTile(
              title: const Text('Active'),
              value: _isActive,
              onChanged: (v) => setState(() => _isActive = v),
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
