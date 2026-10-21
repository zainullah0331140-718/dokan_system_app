import 'package:drift/drift.dart';

import '../dokan_database.dart';

part 'products_dao.g.dart';

@DriftAccessor(tables: [
  Products,
  Categories,
  Units,
  ProductVariants,
])
class ProductsDao extends DatabaseAccessor<DokanDatabase> with _$ProductsDaoMixin {
  ProductsDao(super.db);

  Future<List<Product>> getAll({bool includeInactive = false}) {
    final q = select(products)..orderBy([(t) => OrderingTerm.asc(t.name)]);
    if (!includeInactive) {
      q.where((p) => p.isActive.equals(true) & p.isDeleted.equals(false));
    } else {
      q.where((p) => p.isDeleted.equals(false));
    }
    return q.get();
  }

  Stream<List<Product>> watchAll({bool includeInactive = false}) {
    final q = select(products)..orderBy([(t) => OrderingTerm.asc(t.name)]);
    if (!includeInactive) {
      q.where((p) => p.isActive.equals(true) & p.isDeleted.equals(false));
    } else {
      q.where((p) => p.isDeleted.equals(false));
    }
    return q.watch();
  }

  Future<Product?> findById(String id) =>
      (select(products)..where((p) => p.id.equals(id))).getSingleOrNull();

  Future<Product?> findBySku(String sku) =>
      (select(products)..where((p) => p.sku.equals(sku))).getSingleOrNull();

  Future<int> insertProduct(ProductsCompanion companion) =>
      into(products).insert(companion);

  Future<bool> updateProduct(String id, ProductsCompanion companion) async {
    final count = await (update(products)..where((p) => p.id.equals(id))).write(companion);
    return count > 0;
  }

  Future<int> softDelete(String id) =>
      (update(products)..where((p) => p.id.equals(id))).write(
        const ProductsCompanion(isDeleted: Value(true)),
      );

  Future<List<Category>> getCategories() =>
      (select(categories)..where((c) => c.isDeleted.equals(false)))
          .get();

  Future<List<Unit>> getUnits() =>
      (select(units)..where((u) => u.isDeleted.equals(false))).get();
}
