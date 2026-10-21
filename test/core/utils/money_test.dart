import 'package:dokan_system/core/utils/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('toMinor', () {
    test('parses plain decimal', () {
      expect(toMinor('12.34'), 1234);
    });

    test('parses grouped number', () {
      expect(toMinor('1,234.56'), 123456);
    });

    test('parses integer', () {
      expect(toMinor('7'), 700);
    });

    test('parses negative', () {
      expect(toMinor('-3.50'), -350);
    });

    test('falls back to 0 for garbage', () {
      expect(toMinor('abc'), 0);
      expect(toMinor(''), 0);
    });
  });

  group('formatMoney', () {
    test('formats with symbol before', () {
      expect(formatMoney(1234, symbol: r'$'), r'$12.34');
      expect(formatMoney(0, symbol: r'$'), r'$0.00');
      expect(formatMoney(5, symbol: r'$'), r'$0.05');
    });

    test('formats with symbol after', () {
      expect(
        formatMoney(123456, symbol: 'PKR', symbolAfter: true),
        '1,234.56 PKR',
      );
    });

    test('respects decimal places', () {
      expect(formatMoney(1234, symbol: '', decimalPlaces: 3), '1.234');
    });
  });

  group('formatQty', () {
    test('whole numbers without decimals', () {
      expect(formatQty(3000), '3');
      expect(formatQty(0), '0');
    });

    test('fractional quantities', () {
      expect(formatQty(1500), '1.5');
      expect(formatQty(1234), '1.234');
      expect(formatQty(1), '0.001');
    });
  });

  group('conversion helpers', () {
    test('qtyToMilli', () {
      expect(qtyToMilli(2.5), 2500);
      expect(qtyToMilli(0.001), 1);
    });

    test('roundToStep', () {
      expect(roundToStep(1234, 5), 1235);
      expect(roundToStep(1234, 100), 1200);
      expect(roundToStep(1234, 1), 1234);
    });

    test('minorToDouble roundtrips with toMinor', () {
      expect(minorToDouble(toMinor('99.99')), closeTo(99.99, 0.0001));
    });
  });
}
