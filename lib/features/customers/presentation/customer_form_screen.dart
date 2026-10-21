import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/dokan_database.dart';
import '../../../core/di/providers.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/uuid.dart';

class CustomerFormScreen extends ConsumerStatefulWidget {
  const CustomerFormScreen({super.key, this.customer});

  final Customer? customer;

  @override
  ConsumerState<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends ConsumerState<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _creditLimitCtrl;
  bool _isActive = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final c = widget.customer;
    _nameCtrl = TextEditingController(text: c?.name ?? '');
    _phoneCtrl = TextEditingController(text: c?.phone ?? '');
    _emailCtrl = TextEditingController(text: c?.email ?? '');
    _addressCtrl = TextEditingController(text: c?.address ?? '');
    _cityCtrl = TextEditingController(text: c?.city ?? '');
    _creditLimitCtrl = TextEditingController(
      text: c == null || c.creditLimitMinor == 0
          ? '0'
          : (c.creditLimitMinor / 100).toStringAsFixed(2),
    );
    _isActive = c?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _creditLimitCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final dao = ref.read(customersDaoProvider);
    try {
      if (widget.customer == null) {
        await dao.insertCustomer(
          CustomersCompanion.insert(
            id: Value(newId()),
            name: _nameCtrl.text.trim(),
            phone: Value(_phoneCtrl.text.trim().isEmpty
                ? null
                : _phoneCtrl.text.trim()),
            email: Value(_emailCtrl.text.trim().isEmpty
                ? null
                : _emailCtrl.text.trim()),
            address: Value(_addressCtrl.text.trim().isEmpty
                ? null
                : _addressCtrl.text.trim()),
            city:
                Value(_cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim()),
            creditLimitMinor: Value(toMinor(_creditLimitCtrl.text)),
            isActive: Value(_isActive),
          ),
        );
      } else {
        await dao.updateCustomer(
          widget.customer!.id,
          CustomersCompanion(
            name: Value(_nameCtrl.text.trim()),
            phone: Value(_phoneCtrl.text.trim().isEmpty
                ? null
                : _phoneCtrl.text.trim()),
            email: Value(_emailCtrl.text.trim().isEmpty
                ? null
                : _emailCtrl.text.trim()),
            address: Value(_addressCtrl.text.trim().isEmpty
                ? null
                : _addressCtrl.text.trim()),
            city:
                Value(_cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim()),
            creditLimitMinor: Value(toMinor(_creditLimitCtrl.text)),
            isActive: Value(_isActive),
          ),
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save customer: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.customer != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Customer' : 'Add Customer')),
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
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressCtrl,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cityCtrl,
              decoration: const InputDecoration(
                labelText: 'City',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _creditLimitCtrl,
              decoration: const InputDecoration(
                labelText: 'Credit Limit',
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
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
