// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_dao.dart';

// ignore_for_file: type=lint
mixin _$StockDaoMixin on DatabaseAccessor<DokanDatabase> {
  $CategoriesTable get categories => attachedDatabase.categories;
  $ProductsTable get products => attachedDatabase.products;
  $BranchesTable get branches => attachedDatabase.branches;
  $StockBalancesTable get stockBalances => attachedDatabase.stockBalances;
  $StockMovementsTable get stockMovements => attachedDatabase.stockMovements;
  StockDaoManager get managers => StockDaoManager(this);
}

class StockDaoManager {
  final _$StockDaoMixin _db;
  StockDaoManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db.attachedDatabase, _db.products);
  $$BranchesTableTableManager get branches =>
      $$BranchesTableTableManager(_db.attachedDatabase, _db.branches);
  $$StockBalancesTableTableManager get stockBalances =>
      $$StockBalancesTableTableManager(_db.attachedDatabase, _db.stockBalances);
  $$StockMovementsTableTableManager get stockMovements =>
      $$StockMovementsTableTableManager(
        _db.attachedDatabase,
        _db.stockMovements,
      );
}
