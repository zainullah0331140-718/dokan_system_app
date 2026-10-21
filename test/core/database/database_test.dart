import 'package:dokan_system/core/constants/permissions.dart';
import 'package:dokan_system/core/database/dokan_database.dart';
import 'package:dokan_system/core/database/seed_ids.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

DokanDatabase buildDatabase() => DokanDatabase.forTesting(NativeDatabase.memory());

void main() {
  late DokanDatabase db;

  setUp(() => db = buildDatabase());
  tearDown(() => db.close());

  test('seeds create base data', () async {
    final users = await db.select(db.users).get();
    expect(users, hasLength(3));

    final roles = await db.select(db.roles).get();
    expect(
      roles.map((r) => r.name),
      containsAll(['admin', 'manager', 'cashier']),
    );

    final branches = await db.select(db.branches).get();
    expect(branches.single.code, 'MAIN');
    expect(branches.single.isDefault, isTrue);

    final currencies = await db.select(db.currencies).get();
    expect(currencies.firstWhere((c) => c.isBase).code, 'USD');
    expect(currencies.length, 5);

    final units = await db.select(db.units).get();
    expect(units.length, 6);
    expect(units.where((u) => u.isBase), hasLength(3));

    final taxes = await db.select(db.taxes).get();
    expect(taxes.singleWhere((t) => t.isDefault).rateBp, 0);

    final settings = await db.settingsDao.getSettings();
    expect(settings, isNotNull);
    expect(settings!.defaultBranchId, SeedIds.mainBranchId);
  });

  test('admin login works with seeded pin', () async {
    final admin = await db.authDao.findByUsername('admin');
    expect(admin, isNotNull);
    expect(admin!.mustChangePin, isTrue);

    expect(await db.authDao.verifyPin(user: admin, pin: '1234'), isTrue);
    expect(await db.authDao.verifyPin(user: admin, pin: '9999'), isFalse);

    final roles = await db.authDao.roleNamesFor(admin.id);
    expect(roles, contains('admin'));

    final permissions = await db.authDao.permissionCodesFor(admin.id);
    expect(permissions, contains(PermissionCodes.all));
    expect(permissions, contains(PermissionCodes.salesCreate));
    expect(permissions.length, PermissionCodes.catalog.length + 1);
  });

  test('cashier permissions are restricted', () async {
    final cashier = await db.authDao.findByUsername('cashier');
    expect(cashier, isNotNull);
    final permissions = await db.authDao.permissionCodesFor(cashier!.id);
    expect(permissions, contains(PermissionCodes.salesCreate));
    expect(permissions, isNot(contains(PermissionCodes.settingsManage)));
    expect(permissions, isNot(contains(PermissionCodes.usersManage)));
  });

  test('failed logins lock the account', () async {
    final cashier = await db.authDao.findByUsername('cashier');
    expect(cashier, isNotNull);
    for (var attempt = 1; attempt < 5; attempt++) {
      await db.authDao.recordLoginFailure(
        userId: cashier!.id,
        failedAttempts: attempt,
        lockedUntil: null,
      );
    }
    await db.authDao.recordLoginFailure(
      userId: cashier!.id,
      failedAttempts: 5,
      lockedUntil: DateTime.now().toUtc().add(const Duration(minutes: 15)),
    );
    final reloaded = await db.authDao.findByUsername('cashier');
    expect(reloaded!.failedAttempts, 5);
    expect(reloaded.lockedUntil, isNotNull);
    expect(reloaded.lockedUntil!.isAfter(DateTime.now().toUtc()), isTrue);
  });

  test('login success clears failed attempts', () async {
    final cashier = await db.authDao.findByUsername('cashier');
    await db.authDao.recordLoginFailure(
      userId: cashier!.id,
      failedAttempts: 3,
      lockedUntil: null,
    );
    await db.authDao.recordLoginSuccess(cashier.id);
    final reloaded = await db.authDao.findByUsername('cashier');
    expect(reloaded!.failedAttempts, 0);
    expect(reloaded.lockedUntil, isNull);
    expect(reloaded.lastLoginAt, isNotNull);
  });

  test('invoice sequence increments atomically', () async {
    final first = await db.settingsDao.nextSequence(
      branchId: SeedIds.mainBranchId,
      series: 'INV',
      period: '2026-10',
    );
    final second = await db.settingsDao.nextSequence(
      branchId: SeedIds.mainBranchId,
      series: 'INV',
      period: '2026-10',
    );
    expect(first, 1);
    expect(second, 2);

    final otherSeries = await db.settingsDao.nextSequence(
      branchId: SeedIds.mainBranchId,
      series: 'SAL',
      period: '2026-10',
    );
    expect(otherSeries, 1);
  });

  test('preferences read and write', () async {
    expect(await db.settingsDao.getPreference('locale'), isNull);
    await db.settingsDao.setPreference('locale', 'ar');
    expect(await db.settingsDao.getPreference('locale'), 'ar');
    await db.settingsDao.setPreference('locale', 'en');
    expect(await db.settingsDao.getPreference('locale'), 'en');
  });

  test('outbox enqueue and pending count', () async {
    expect(await db.outboxDao.pendingCount(), 0);
    await db.outboxDao.enqueue(
      entityType: 'product',
      entityId: 'p1',
      action: OutboxAction.create,
      payload: {'id': 'p1'},
    );
    await db.outboxDao.enqueue(
      entityType: 'product',
      entityId: 'p2',
      action: OutboxAction.update,
      payload: {'id': 'p2'},
    );
    expect(await db.outboxDao.pendingCount(), 2);

    final pending = await db.outboxDao.pendingBatch();
    expect(pending, hasLength(2));
    await db.outboxDao.markSent(pending.first.id);
    expect(await db.outboxDao.pendingCount(), 1);
  });

  test('audit log records entries', () async {
    await db.auditDao.log(action: 'login_success', entity: 'user', entityId: 'u1');
    await db.auditDao.log(action: 'login_success', entity: 'user', entityId: 'u2');
    expect(await db.auditDao.countFor('user'), 2);
    expect(await db.auditDao.countFor('sale'), 0);
  });

  test('watched queries emit settings', () async {
    await expectLater(db.settingsDao.watchSettings(), emits(isNotNull));
    await expectLater(db.settingsDao.watchBranches(), emits(hasLength(1)));
  });
}
