import 'package:drift/drift.dart';

import '../../utils/uuid.dart';
import 'syncable.dart';
import 'system_tables.dart';

class Roles extends SyncableTable {
  TextColumn get id => text().clientDefault(newId)();
  TextColumn get name => text().unique()();
  TextColumn get nameAr => text().nullable()();
  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class Permissions extends SyncableTable {
  TextColumn get id => text().clientDefault(newId)();
  TextColumn get code => text().unique()();
  TextColumn get module => text()();
  TextColumn get name => text()();
  TextColumn get nameAr => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class RolePermissions extends Table {
  TextColumn get roleId =>
      text().references(Roles, #id, onDelete: KeyAction.cascade)();
  TextColumn get permissionId =>
      text().references(Permissions, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {roleId, permissionId};
}

class Users extends SyncableTable {
  TextColumn get id => text().clientDefault(newId)();
  TextColumn get username => text().unique()();
  TextColumn get fullName => text()();
  TextColumn get fullNameAr => text().nullable()();
  TextColumn get pinHash => text()();
  TextColumn get pinSalt => text()();
  TextColumn get passwordHash => text().nullable()();
  TextColumn get branchId => text().nullable().references(Branches, #id)();
  TextColumn get avatarPath => text().nullable()();
  TextColumn get defaultRoleId =>
      text().nullable().references(Roles, #id, onDelete: KeyAction.setNull)();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get mustChangePin => boolean().withDefault(const Constant(false))();
  IntColumn get failedAttempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get lockedUntil => dateTime().nullable()();
  DateTimeColumn get lastLoginAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class UserRoles extends Table {
  TextColumn get userId =>
      text().references(Users, #id, onDelete: KeyAction.cascade)();
  TextColumn get roleId =>
      text().references(Roles, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {userId, roleId};
}

@DataClassName('UserBranch')
class UserBranches extends Table {
  TextColumn get userId =>
      text().references(Users, #id, onDelete: KeyAction.cascade)();
  TextColumn get branchId =>
      text().references(Branches, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {userId, branchId};
}
