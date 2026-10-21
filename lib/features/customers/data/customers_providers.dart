import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/dokan_database.dart';
import '../../../core/di/providers.dart';

final customersListProvider = StreamProvider<List<Customer>>((ref) {
  final dao = ref.watch(customersDaoProvider);
  return dao.watchAll(includeInactive: true);
});

final suppliersListProvider = StreamProvider<List<Supplier>>((ref) {
  final dao = ref.watch(suppliersDaoProvider);
  return dao.watchAll(includeInactive: true);
});
