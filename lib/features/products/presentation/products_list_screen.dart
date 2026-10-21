import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/widgets/money_text.dart';
import '../../../core/widgets/product_image.dart';
import '../data/products_providers.dart';
import 'product_form_screen.dart';

class ProductsListScreen extends ConsumerWidget {
  const ProductsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsListProvider);
    final currency = ref.watch(baseCurrencyProvider).value ?? kDefaultCurrency;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ProductFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: products.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No products yet'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: list.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final p = list[index];
              return ListTile(
                leading: ProductImage(imageUrl: p.imageUrl, size: 44),
                title: Text(p.name),
                subtitle: Text('SKU: ${p.sku}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MoneyText(
                      minor: p.salePriceMinor,
                      symbol: currency.symbol,
                      symbolAfter: currency.symbolAfter,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ProductFormScreen(product: p),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
