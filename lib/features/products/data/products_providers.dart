import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/dokan_database.dart';
import '../../../core/di/providers.dart';

final productsListProvider =
    StreamProvider<List<Product>>((ref) {
  final dao = ref.watch(productsDaoProvider);
  return dao.watchAll();
});

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final dao = ref.watch(productsDaoProvider);
  return dao.getCategories();
});

final unitsProvider = FutureProvider<List<Unit>>((ref) async {
  final dao = ref.watch(productsDaoProvider);
  return dao.getUnits();
});
