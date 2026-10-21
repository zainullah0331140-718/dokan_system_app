import '../../../core/constants/app_constants.dart';
import '../../../core/database/dokan_database.dart';
import '../../../core/security/pin_hasher.dart';
import '../domain/auth_state.dart';

class AuthRepository {
  AuthRepository(this._db);

  final DokanDatabase _db;

  Future<LoginResult> login({
    required String username,
    required String pin,
  }) async {
    final normalized = username.trim().toLowerCase();
    final user = await _db.authDao.findByUsername(normalized);
    if (user == null) {
      return const LoginFailure(LoginError.invalidCredentials);
    }

    final now = DateTime.now().toUtc();
    final lockedUntil = user.lockedUntil;
    if (lockedUntil != null && lockedUntil.isAfter(now)) {
      return LoginFailure(
        LoginError.locked,
        retryAfter: lockedUntil.difference(now),
      );
    }

    if (!user.isActive) {
      return const LoginFailure(LoginError.inactive);
    }

    final valid = await _db.authDao.verifyPin(user: user, pin: pin);
    if (!valid) {
      final attempts = user.failedAttempts + 1;
      final shouldLock = attempts >= AppConstants.maxLoginAttempts;
      await _db.authDao.recordLoginFailure(
        userId: user.id,
        failedAttempts: attempts,
        lockedUntil:
            shouldLock ? now.add(AppConstants.loginLockoutDuration) : null,
      );
      await _db.auditDao.log(
        action: 'login_failed',
        entity: 'user',
        entityId: user.id,
        after: {'failedAttempts': attempts, 'locked': shouldLock},
      );
      return shouldLock
          ? LoginFailure(
              LoginError.locked,
              retryAfter: AppConstants.loginLockoutDuration,
            )
          : const LoginFailure(LoginError.invalidCredentials);
    }

    await _db.authDao.recordLoginSuccess(user.id);

    final roleNames = await _db.authDao.roleNamesFor(user.id);
    final permissions = await _db.authDao.permissionCodesFor(user.id);

    final appUser = AppUser(
      id: user.id,
      username: user.username,
      fullName: user.fullName,
      fullNameAr: user.fullNameAr,
      branchId: user.branchId,
      roleNames: roleNames,
      permissions: permissions,
      mustChangePin: user.mustChangePin,
    );

    await _db.auditDao.log(
      action: 'login_success',
      entity: 'user',
      entityId: user.id,
    );

    return LoginSuccess(user: appUser, mustChangePin: user.mustChangePin);
  }

  Future<void> changePin({
    required String userId,
    required String currentPin,
    required String newPin,
  }) async {
    final query = _db.select(_db.users)..where((u) => u.id.equals(userId));
    final user = await query.getSingleOrNull();
    if (user == null) {
      throw StateError('User not found');
    }
    final valid = await _db.authDao.verifyPin(user: user, pin: currentPin);
    if (!valid) {
      throw ArgumentError('Current PIN is incorrect');
    }
    final hashed = await PinHasher.hash(newPin);
    await _db.authDao.changePin(
      userId,
      newHash: hashed.hash,
      newSalt: hashed.salt,
    );
    await _db.auditDao.log(
      action: 'pin_changed',
      entity: 'user',
      entityId: userId,
    );
  }
}
