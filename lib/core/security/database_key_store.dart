import 'dart:math';

import 'secure_storage_service.dart';

class DatabaseKeyStore {
  DatabaseKeyStore(this._storage);

  final SecureStorageService _storage;

  Future<String> getOrCreateKey() async {
    final existing = await _storage.read(SecureStorageService.databaseKey);
    if (existing != null && existing.length >= 32) return existing;
    final key = _generateKey();
    await _storage.write(SecureStorageService.databaseKey, key);
    return key;
  }

  Future<void> clear() => _storage.delete(SecureStorageService.databaseKey);

  String _generateKey() {
    final random = Random.secure();
    return List<String>.generate(
      32,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
  }
}
