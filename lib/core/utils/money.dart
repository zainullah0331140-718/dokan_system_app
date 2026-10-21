import 'package:intl/intl.dart';

enum SymbolPosition { before, after }

int moneyScale(int decimalPlaces) {
  var scale = 1;
  for (var i = 0; i < decimalPlaces; i++) {
    scale *= 10;
  }
  return scale;
}

int toMinor(String input, {int decimalPlaces = 2}) {
  final cleaned = input.trim().replaceAll(RegExp(r'[^\d.,-]'), '');
  if (cleaned.isEmpty) return 0;
  final normalized = cleaned.replaceAll(',', '');
  final value = double.tryParse(normalized);
  if (value == null) return 0;
  return (value * moneyScale(decimalPlaces)).round();
}

double minorToDouble(int minor, {int decimalPlaces = 2}) =>
    minor / moneyScale(decimalPlaces);

int roundMinor(double value, {int decimalPlaces = 2}) =>
    (value * moneyScale(decimalPlaces)).round();

int roundToStep(int minor, int stepMinor) {
  if (stepMinor <= 1) return minor;
  return ((minor / stepMinor).round()) * stepMinor;
}

String formatMoney(
  int minor, {
  required String symbol,
  int decimalPlaces = 2,
  bool symbolAfter = false,
  String? locale,
}) {
  final scale = moneyScale(decimalPlaces);
  final value = minor / scale;
  final formatter = NumberFormat.decimalPattern(locale ?? 'en')
    ..minimumFractionDigits = decimalPlaces
    ..maximumFractionDigits = decimalPlaces;
  final number = formatter.format(value);
  return symbolAfter ? '$number $symbol' : '$symbol$number';
}

String formatQty(int milli) {
  if (milli % 1000 == 0) return '${milli ~/ 1000}';
  var text = (milli / 1000).toStringAsFixed(3);
  if (text.contains('.')) {
    text = text.replaceFirst(RegExp(r'0+$'), '');
    text = text.replaceFirst(RegExp(r'\.$'), '');
  }
  return text;
}

int qtyToMilli(double qty) => (qty * 1000).round();

int qtyStringToMilli(String input) {
  final value = double.tryParse(input.trim().replaceAll(',', ''));
  if (value == null) return 0;
  return qtyToMilli(value);
}
