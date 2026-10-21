import 'package:dokan_system/app/app.dart';
import 'package:dokan_system/core/database/dokan_database.dart';
import 'package:dokan_system/core/di/providers.dart';
import 'package:dokan_system/core/security/secure_storage_service.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DokanDatabase db;

  setUp(() {
    db = DokanDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  Widget buildApp() => ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          secureStorageProvider.overrideWithValue(InMemorySecureStorage()),
        ],
        child: const DokanApp(),
      );

  testWidgets('shows login form and validates empty inputs',
      (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Sign in'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Enter your username'), findsOneWidget);
    expect(find.text('Enter your PIN'), findsOneWidget);
  });

  testWidgets('invalid credentials show error snackbar', (tester) async {
    await tester.runAsync(
      () => db.settingsDao.getPreference('warmup'),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'admin');
    await tester.enterText(find.byType(TextFormField).at(1), '9999');
    await tester.tap(find.text('Sign in'));
    await tester.pump();

    await tester.runAsync(
      () => Future<void>.delayed(const Duration(seconds: 2)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Incorrect username or PIN'), findsOneWidget);
    expect(find.text('Dashboard'), findsNothing);
  });

  testWidgets('valid credentials navigate to dashboard', (tester) async {
    await tester.runAsync(
      () => db.settingsDao.getPreference('warmup'),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'admin');
    await tester.enterText(find.byType(TextFormField).at(1), '1234');
    await tester.tap(find.text('Sign in'));
    await tester.pump();

    await tester.runAsync(
      () => Future<void>.delayed(const Duration(seconds: 3)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsWidgets);
    expect(find.byType(NavigationRail), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('shows language and theme switchers on login',
      (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('English'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);
  });
}
