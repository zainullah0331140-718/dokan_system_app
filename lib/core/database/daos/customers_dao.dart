import 'package:drift/drift.dart';

import '../dokan_database.dart';

part 'customers_dao.g.dart';

@DriftAccessor(tables: [Customers])
class CustomersDao extends DatabaseAccessor<DokanDatabase>
    with _$CustomersDaoMixin {
  CustomersDao(super.db);

  Future<List<Customer>> getAll({bool includeInactive = false}) {
    final q = select(customers)..orderBy([(t) => OrderingTerm.asc(t.name)]);
    if (!includeInactive) {
      q.where((c) => c.isActive.equals(true) & c.isDeleted.equals(false));
    } else {
      q.where((c) => c.isDeleted.equals(false));
    }
    return q.get();
  }

  Stream<List<Customer>> watchAll({bool includeInactive = false}) {
    final q = select(customers)..orderBy([(t) => OrderingTerm.asc(t.name)]);
    if (!includeInactive) {
      q.where((c) => c.isActive.equals(true) & c.isDeleted.equals(false));
    } else {
      q.where((c) => c.isDeleted.equals(false));
    }
    return q.watch();
  }

  Future<Customer?> findById(String id) =>
      (select(customers)..where((c) => c.id.equals(id))).getSingleOrNull();

  Future<int> insertCustomer(CustomersCompanion companion) =>
      into(customers).insert(companion);

  Future<bool> updateCustomer(String id, CustomersCompanion companion) async {
    final count = await (update(customers)..where((c) => c.id.equals(id)))
        .write(companion);
    return count > 0;
  }

  Future<int> softDelete(String id) =>
      (update(customers)..where((c) => c.id.equals(id))).write(
        const CustomersCompanion(isDeleted: Value(true)),
      );
}

@DriftAccessor(tables: [Suppliers])
class SuppliersDao extends DatabaseAccessor<DokanDatabase>
    with _$SuppliersDaoMixin {
  SuppliersDao(super.db);

  Future<List<Supplier>> getAll({bool includeInactive = false}) {
    final q = select(suppliers)..orderBy([(t) => OrderingTerm.asc(t.name)]);
    if (!includeInactive) {
      q.where((s) => s.isActive.equals(true) & s.isDeleted.equals(false));
    } else {
      q.where((s) => s.isDeleted.equals(false));
    }
    return q.get();
  }

  Stream<List<Supplier>> watchAll({bool includeInactive = false}) {
    final q = select(suppliers)..orderBy([(t) => OrderingTerm.asc(t.name)]);
    if (!includeInactive) {
      q.where((s) => s.isActive.equals(true) & s.isDeleted.equals(false));
    } else {
      q.where((s) => s.isDeleted.equals(false));
    }
    return q.watch();
  }

  Future<int> insertSupplier(SuppliersCompanion companion) =>
      into(suppliers).insert(companion);

  Future<bool> updateSupplier(String id, SuppliersCompanion companion) async {
    final count = await (update(suppliers)..where((s) => s.id.equals(id)))
        .write(companion);
    return count > 0;
  }

  Future<int> softDelete(String id) =>
      (update(suppliers)..where((s) => s.id.equals(id))).write(
        const SuppliersCompanion(isDeleted: Value(true)),
      );
}
