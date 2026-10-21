import 'package:flutter/material.dart';

import '../utils/money.dart';

class MoneyText extends StatelessWidget {
  const MoneyText({
    super.key,
    required this.minor,
    required this.symbol,
    this.decimalPlaces = 2,
    this.symbolAfter = false,
    this.signed = false,
    this.style,
    this.color,
  });

  final int minor;
  final String symbol;
  final int decimalPlaces;
  final bool symbolAfter;
  final bool signed;
  final TextStyle? style;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final text = formatMoney(
      minor,
      symbol: symbol,
      decimalPlaces: decimalPlaces,
      symbolAfter: symbolAfter,
    );
    final display = signed && minor > 0 ? '+$text' : text;
    return Text(
      display,
      style: style ??
          TextStyle(
            color: color,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
    );
  }
}

class QtyText extends StatelessWidget {
  const QtyText({super.key, required this.milli, this.style, this.color});

  final int milli;
  final TextStyle? style;
  final Color? color;

  @override
  Widget build(BuildContext context) => Text(
        formatQty(milli),
        style: style?.copyWith(color: color) ??
            TextStyle(color: color, fontFeatures: const [FontFeature.tabularFigures()]),
      );
}
