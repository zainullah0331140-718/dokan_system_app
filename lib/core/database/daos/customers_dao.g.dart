// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customers_dao.dart';

// ignore_for_file: type=lint
mixin _$CustomersDaoMixin on DatabaseAccessor<DokanDatabase> {
  $DiscountsTable get discounts => attachedDatabase.discounts;
  $CustomersTable get customers => attachedDatabase.customers;
  CustomersDaoManager get managers => CustomersDaoManager(this);
}

class CustomersDaoManager {
  final _$CustomersDaoMixin _db;
  CustomersDaoManager(this._db);
  $$DiscountsTableTableManager get discounts =>
      $$DiscountsTableTableManager(_db.attachedDatabase, _db.discounts);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db.attachedDatabase, _db.customers);
}

mixin _$SuppliersDaoMixin on DatabaseAccessor<DokanDatabase> {
  $SuppliersTable get suppliers => attachedDatabase.suppliers;
  SuppliersDaoManager get managers => SuppliersDaoManager(this);
}

class SuppliersDaoManager {
  final _$SuppliersDaoMixin _db;
  SuppliersDaoManager(this._db);
  $$SuppliersTableTableManager get suppliers =>
      $$SuppliersTableTableManager(_db.attachedDatabase, _db.suppliers);
}
