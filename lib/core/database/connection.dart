import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

import '../constants/app_constants.dart';
import '../logging/app_logger.dart';

Future<File> resolveDatabaseFile() async {
  final directory = await getApplicationSupportDirectory();
  final file = File(
    '${directory.path}${Platform.pathSeparator}${AppConstants.databaseFileName}',
  );
  if (!await file.parent.exists()) {
    await file.parent.create(recursive: true);
  }
  return file;
}

QueryExecutor openEncryptedExecutor({
  required File file,
  required String passphrase,
}) {
  final escaped = passphrase.replaceAll("'", "''");
  return NativeDatabase.createInBackground(
    file,
    setup: (rawDb) {
      rawDb.execute("PRAGMA key = '$escaped';");
      var hasCipher = false;
      try {
        hasCipher = rawDb.select('PRAGMA cipher;').isNotEmpty;
      } catch (_) {
        hasCipher = false;
      }
      if (!hasCipher) {
        AppLogger.error(
          'SQLite cipher is unavailable: database file is stored without encryption on this device',
        );
      }
    },
  );
}

QueryExecutor openMemoryExecutor() => NativeDatabase.memory();
