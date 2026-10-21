import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/dokan_database.dart';
import '../../../core/di/providers.dart';

final purchasesListProvider = StreamProvider<List<Purchase>>((ref) {
  return ref.watch(purchasesDaoProvider).watchAll();
});

final purchaseItemsProvider =
    StreamProvider.family<List<PurchaseItem>, String>((ref, purchaseId) {
  return ref.watch(purchasesDaoProvider).watchItems(purchaseId);
});
