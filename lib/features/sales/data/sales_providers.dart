import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../core/database/dokan_database.dart';
import '../../../core/di/providers.dart';

final recentSalesProvider = StreamProvider<List<Sale>>((ref) {
  return ref.watch(salesDaoProvider).watchRecent(limit: 100);
});

final saleItemsProvider =
    StreamProvider.family<List<SaleItem>, String>((ref, saleId) {
  return ref.watch(salesDaoProvider).watchItems(saleId);
});

final posProductsProvider = StreamProvider<List<Product>>((ref) {
  return ref.watch(productsDaoProvider).watchAll();
});

final productSearchQueryProvider = StateProvider<String>((ref) => '');
