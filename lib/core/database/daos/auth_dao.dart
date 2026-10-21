import 'package:drift/drift.dart';

import '../../security/pin_hasher.dart';
import '../dokan_database.dart';

part 'auth_dao.g.dart';

@DriftAccessor(tables: [
  Permissions,
  RolePermissions,
  Roles,
  UserRoles,
  Users,
])
class AuthDao extends DatabaseAccessor<DokanDatabase> with _$AuthDaoMixin {
  AuthDao(super.db);

  Future<User?> findByUsername(String username) => (select(users)
        ..where((u) => u.username.equals(username) & u.isActive))
      .getSingleOrNull();

  Future<List<String>> roleNamesFor(String userId) async {
    final query = selectOnly(attachedDatabase.userRoles)
      ..addColumns([attachedDatabase.roles.name])
      ..join([
        innerJoin(
          attachedDatabase.roles,
          attachedDatabase.roles.id
              .equalsExp(attachedDatabase.userRoles.roleId),
        ),
      ])
      ..where(attachedDatabase.userRoles.userId.equals(userId));
    final rows = await query.get();
    return rows
        .map((r) => r.read(attachedDatabase.roles.name))
        .nonNulls
        .toList();
  }

  Future<List<String>> permissionCodesFor(String userId) async {
    final ur = attachedDatabase.userRoles;
    final rp = attachedDatabase.rolePermissions;
    final permission = attachedDatabase.permissions;
    final query = selectOnly(ur, distinct: true)
      ..addColumns([permission.code])
      ..join([
        innerJoin(rp, rp.roleId.equalsExp(ur.roleId)),
        innerJoin(permission, permission.id.equalsExp(rp.permissionId)),
      ])
      ..where(ur.userId.equals(userId) & permission.isDeleted.equals(false));
    final rows = await query.get();
    return rows
        .map((r) => r.read(permission.code))
        .nonNulls
        .toSet()
        .toList();
  }

  Future<bool> verifyPin({required User user, required String pin}) =>
      PinHasher.verify(
        secret: pin,
        saltHex: user.pinSalt,
        hashHex: user.pinHash,
      );

  Future<void> recordLoginSuccess(String userId) =>
      (update(users)..where((u) => u.id.equals(userId))).write(
        UsersCompanion(
          lastLoginAt: Value(DateTime.now()),
          failedAttempts: const Value(0),
          lockedUntil: const Value(null),
        ),
      );

  Future<void> recordLoginFailure({
    required String userId,
    required int failedAttempts,
    required DateTime? lockedUntil,
  }) =>
      (update(users)..where((u) => u.id.equals(userId))).write(
        UsersCompanion(
          failedAttempts: Value(failedAttempts),
          lockedUntil: Value(lockedUntil),
        ),
      );

  Future<void> changePin(String userId, {required String newHash, required String newSalt}) =>
      (update(users)..where((u) => u.id.equals(userId))).write(
        UsersCompanion(
          pinHash: Value(newHash),
          pinSalt: Value(newSalt),
          mustChangePin: const Value(false),
        ),
      );

  Stream<List<User>> watchUsers() =>
      (select(users)..orderBy([(u) => OrderingTerm.asc(u.username)])).watch();

  Future<int> countUsers() async {
    final query = selectOnly(attachedDatabase.users)
      ..addColumns([attachedDatabase.users.id.count()]);
    final row = await query.getSingle();
    return row.read(attachedDatabase.users.id.count()) ?? 0;
  }
}
