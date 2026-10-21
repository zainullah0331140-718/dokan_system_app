// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_dao.dart';

// ignore_for_file: type=lint
mixin _$AuthDaoMixin on DatabaseAccessor<DokanDatabase> {
  $PermissionsTable get permissions => attachedDatabase.permissions;
  $RolesTable get roles => attachedDatabase.roles;
  $RolePermissionsTable get rolePermissions => attachedDatabase.rolePermissions;
  $BranchesTable get branches => attachedDatabase.branches;
  $UsersTable get users => attachedDatabase.users;
  $UserRolesTable get userRoles => attachedDatabase.userRoles;
  AuthDaoManager get managers => AuthDaoManager(this);
}

class AuthDaoManager {
  final _$AuthDaoMixin _db;
  AuthDaoManager(this._db);
  $$PermissionsTableTableManager get permissions =>
      $$PermissionsTableTableManager(_db.attachedDatabase, _db.permissions);
  $$RolesTableTableManager get roles =>
      $$RolesTableTableManager(_db.attachedDatabase, _db.roles);
  $$RolePermissionsTableTableManager get rolePermissions =>
      $$RolePermissionsTableTableManager(
        _db.attachedDatabase,
        _db.rolePermissions,
      );
  $$BranchesTableTableManager get branches =>
      $$BranchesTableTableManager(_db.attachedDatabase, _db.branches);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db.attachedDatabase, _db.users);
  $$UserRolesTableTableManager get userRoles =>
      $$UserRolesTableTableManager(_db.attachedDatabase, _db.userRoles);
}
