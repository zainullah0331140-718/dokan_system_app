import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class SecureStorageService {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
  Future<void> deleteAll();

  factory SecureStorageService.platform() = _PlatformSecureStorage;

  static const String databaseKey = 'dokan_db_key';
  static const String sessionTokenKey = 'dokan_session_token';
  static const String lastUsernameKey = 'dokan_last_username';
}

class _PlatformSecureStorage implements SecureStorageService {
  const _PlatformSecureStorage();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);

  @override
  Future<void> deleteAll() => _storage.deleteAll();
}

class InMemorySecureStorage implements SecureStorageService {
  InMemorySecureStorage([Map<String, String>? initial])
      : _values = {...?initial};

  final Map<String, String> _values;

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async {
    _values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _values.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _values.clear();
  }
}
