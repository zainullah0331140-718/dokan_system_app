import 'dart:ui' show Locale;

import 'package:dokan_system/core/database/dokan_database.dart';
import 'package:dokan_system/core/di/providers.dart';
import 'package:dokan_system/core/security/secure_storage_service.dart';
import 'package:dokan_system/features/auth/domain/auth_state.dart';
import 'package:dokan_system/features/auth/presentation/session_controller.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ProviderContainer container;
  late DokanDatabase db;

  setUp(() {
    db = DokanDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        secureStorageProvider.overrideWithValue(InMemorySecureStorage()),
      ],
    );
  });

  tearDown(() {
    container.dispose();
    db.close();
  });

  test('starts unauthenticated', () {
    expect(
      container.read(sessionControllerProvider),
      isA<AuthStateUnauthenticated>(),
    );
  });

  test('login with correct credentials authenticates', () async {
    final result = await container
        .read(sessionControllerProvider.notifier)
        .login(username: 'admin', pin: '1234');

    expect(result, isA<LoginSuccess>());
    final session = container.read(sessionControllerProvider);
    expect(session, isA<AuthStateAuthenticated>());
    final user = (session as AuthStateAuthenticated).user;
    expect(user.username, 'admin');
    expect(user.isAdmin, isTrue);
    expect(user.hasPermission('*'), isTrue);
    expect(
      user.displayName(const Locale('en')),
      'Administrator',
    );
  });

  test('login with wrong pin fails and keeps session closed', () async {
    final result = await container
        .read(sessionControllerProvider.notifier)
        .login(username: 'admin', pin: '0000');

    expect(result, isA<LoginFailure>());
    expect((result as LoginFailure).error, LoginError.invalidCredentials);
    expect(
      container.read(sessionControllerProvider),
      isA<AuthStateUnauthenticated>(),
    );
  });

  test('login with unknown username fails', () async {
    final result = await container
        .read(sessionControllerProvider.notifier)
        .login(username: 'ghost', pin: '1234');

    expect(result, isA<LoginFailure>());
    expect((result as LoginFailure).error, LoginError.invalidCredentials);
  });

  test('username is normalized before lookup', () async {
    final result = await container
        .read(sessionControllerProvider.notifier)
        .login(username: '  ADMIN ', pin: '1234');
    expect(result, isA<LoginSuccess>());
  });

  test('logout clears the session', () async {
    final controller = container.read(sessionControllerProvider.notifier);
    await controller.login(username: 'cashier', pin: '1234');
    expect(
      container.read(sessionControllerProvider),
      isA<AuthStateAuthenticated>(),
    );

    controller.logout();
    expect(
      container.read(sessionControllerProvider),
      isA<AuthStateUnauthenticated>(),
    );
  });

  test('lockout after max failed attempts', () async {
    final controller = container.read(sessionControllerProvider.notifier);
    LoginResult? last;
    for (var i = 0; i < 5; i++) {
      last = await controller.login(username: 'manager', pin: '9999');
    }
    expect(last, isA<LoginFailure>());
    expect((last as LoginFailure).error, LoginError.locked);
    expect(last.retryAfter, isNotNull);

    final afterLock = await controller.login(username: 'manager', pin: '1234');
    expect(afterLock, isA<LoginFailure>());
    expect((afterLock as LoginFailure).error, LoginError.locked);
  });

  test('permissions gate access', () async {
    await container
        .read(sessionControllerProvider.notifier)
        .login(username: 'cashier', pin: '1234');
    final session = container.read(sessionControllerProvider);
    final user = (session as AuthStateAuthenticated).user;

    expect(user.hasPermission('sales.create'), isTrue);
    expect(user.hasPermission('settings.manage'), isFalse);
    expect(user.isAdmin, isFalse);
  });
}
