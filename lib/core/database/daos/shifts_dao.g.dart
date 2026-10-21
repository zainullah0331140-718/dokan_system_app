// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shifts_dao.dart';

// ignore_for_file: type=lint
mixin _$ShiftsDaoMixin on DatabaseAccessor<DokanDatabase> {
  $BranchesTable get branches => attachedDatabase.branches;
  $RolesTable get roles => attachedDatabase.roles;
  $UsersTable get users => attachedDatabase.users;
  $ShiftsTable get shifts => attachedDatabase.shifts;
  $ShiftTransactionsTable get shiftTransactions =>
      attachedDatabase.shiftTransactions;
  ShiftsDaoManager get managers => ShiftsDaoManager(this);
}

class ShiftsDaoManager {
  final _$ShiftsDaoMixin _db;
  ShiftsDaoManager(this._db);
  $$BranchesTableTableManager get branches =>
      $$BranchesTableTableManager(_db.attachedDatabase, _db.branches);
  $$RolesTableTableManager get roles =>
      $$RolesTableTableManager(_db.attachedDatabase, _db.roles);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db.attachedDatabase, _db.users);
  $$ShiftsTableTableManager get shifts =>
      $$ShiftsTableTableManager(_db.attachedDatabase, _db.shifts);
  $$ShiftTransactionsTableTableManager get shiftTransactions =>
      $$ShiftTransactionsTableTableManager(
        _db.attachedDatabase,
        _db.shiftTransactions,
      );
}
