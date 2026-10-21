import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/database/connection.dart';
import 'core/database/dokan_database.dart';
import 'core/di/providers.dart';
import 'core/security/database_key_store.dart';
import 'core/security/secure_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final secureStorage = SecureStorageService.platform();
  final keyStore = DatabaseKeyStore(secureStorage);
  final passphrase = await keyStore.getOrCreateKey();
  final file = await resolveDatabaseFile();
  final database = DokanDatabase(
    openEncryptedExecutor(file: file, passphrase: passphrase),
  );

  final localeCode = await database.settingsDao.getPreference('locale');
  final themeName = await database.settingsDao.getPreference('themeMode');

  runApp(
    ProviderScope(
      overrides: [
        secureStorageProvider.overrideWithValue(secureStorage),
        databaseProvider.overrideWithValue(database),
        bootstrapLocaleProvider.overrideWithValue(
          localeCode == null ? null : Locale(localeCode),
        ),
        bootstrapThemeModeProvider.overrideWithValue(
          themeName == null
              ? ThemeMode.system
              : ThemeMode.values.firstWhere(
                  (mode) => mode.name == themeName,
                  orElse: () => ThemeMode.system,
                ),
        ),
      ],
      child: const DokanApp(),
    ),
  );
}
