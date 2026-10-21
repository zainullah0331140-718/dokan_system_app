import 'dart:math';

import 'package:cryptography/cryptography.dart';

import '../constants/app_constants.dart';

class PinHasher {
  static final Pbkdf2 _algorithm = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: AppConstants.pbkdf2Iterations,
    bits: 256,
  );

  static Future<({String hash, String salt})> hash(String secret) async {
    final salt = _randomBytes(AppConstants.pinSaltBytes);
    final key = await _algorithm.deriveKeyFromPassword(
      password: secret,
      nonce: salt,
    );
    final bytes = await key.extractBytes();
    return (hash: toHex(bytes), salt: toHex(salt));
  }

  static Future<bool> verify({
    required String secret,
    required String saltHex,
    required String hashHex,
  }) async {
    final salt = fromHex(saltHex);
    final expected = fromHex(hashHex);
    if (salt.isEmpty || expected.isEmpty) return false;
    final key = await _algorithm.deriveKeyFromPassword(
      password: secret,
      nonce: salt,
    );
    final actual = await key.extractBytes();
    if (actual.length != expected.length) return false;
    var difference = 0;
    for (var i = 0; i < actual.length; i++) {
      difference |= actual[i] ^ expected[i];
    }
    return difference == 0;
  }

  static String toHex(List<int> bytes) => bytes
      .map((b) => b.toRadixString(16).padLeft(2, '0'))
      .join();

  static List<int> fromHex(String hex) {
    if (hex.length.isOdd || hex.isEmpty) return const [];
    final result = List<int>.filled(hex.length ~/ 2, 0);
    for (var i = 0; i < result.length; i++) {
      final pair = hex.substring(i * 2, i * 2 + 2);
      result[i] = int.tryParse(pair, radix: 16) ?? 0;
    }
    return result;
  }

  static List<int> _randomBytes(int count) {
    final random = Random.secure();
    return List<int>.generate(count, (_) => random.nextInt(256));
  }
}
