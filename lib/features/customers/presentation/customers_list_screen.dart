import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/customers_providers.dart';
import 'customer_form_screen.dart';

class CustomersListScreen extends ConsumerWidget {
  const CustomersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customers = ref.watch(customersListProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CustomerFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: customers.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No customers yet'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: list.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final c = list[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(
                    c.name.isEmpty ? '?' : c.name.characters.first.toUpperCase(),
                  ),
                ),
                title: Text(c.name),
                subtitle: Text(
                  [
                    if (c.phone?.isNotEmpty == true) c.phone!,
                    if (c.city?.isNotEmpty == true) c.city!,
                    if (!c.isActive) 'Inactive',
                  ].join(' • '),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CustomerFormScreen(customer: c),
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
