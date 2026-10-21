import 'package:dokan_system/core/security/pin_hasher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('hash produces hex salt and hash', () async {
    final result = await PinHasher.hash('1234');
    expect(result.hash.length, 64);
    expect(result.salt.length, 32);
    expect(RegExp(r'^[0-9a-f]+$').hasMatch(result.hash), isTrue);
    expect(RegExp(r'^[0-9a-f]+$').hasMatch(result.salt), isTrue);
  });

  test('hash is salted (different output each time)', () async {
    final first = await PinHasher.hash('1234');
    final second = await PinHasher.hash('1234');
    expect(first.salt, isNot(second.salt));
    expect(first.hash, isNot(second.hash));
  });

  test('verify accepts correct pin', () async {
    final result = await PinHasher.hash('1234');
    expect(
      await PinHasher.verify(
        secret: '1234',
        saltHex: result.salt,
        hashHex: result.hash,
      ),
      isTrue,
    );
  });

  test('verify rejects wrong pin', () async {
    final result = await PinHasher.hash('1234');
    expect(
      await PinHasher.verify(
        secret: '0000',
        saltHex: result.salt,
        hashHex: result.hash,
      ),
      isFalse,
    );
  });

  test('verify rejects empty inputs', () async {
    expect(
      await PinHasher.verify(secret: '1234', saltHex: '', hashHex: ''),
      isFalse,
    );
    expect(
      await PinHasher.verify(secret: '1234', saltHex: 'zz', hashHex: 'zz'),
      isFalse,
    );
  });

  test('hex roundtrip', () {
    final bytes = [0, 1, 15, 16, 255];
    expect(PinHasher.fromHex(PinHasher.toHex(bytes)), bytes);
    expect(PinHasher.fromHex(''), isEmpty);
    expect(PinHasher.fromHex('abc'), isEmpty);
  });
}
