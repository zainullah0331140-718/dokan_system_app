import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/dokan_database.dart';

class CartLine {
  CartLine({
    required this.product,
    required this.qtyMilli,
    required this.unitPriceMinor,
  });

  final Product product;
  int qtyMilli;
  int unitPriceMinor;

  int get lineTotalMinor => qtyMilli * unitPriceMinor ~/ 1000;
}

class CartState {
  const CartState({this.lines = const [], this.customerId});

  final List<CartLine> lines;
  final String? customerId;

  int get itemCount => lines.fold(0, (sum, l) => sum + l.qtyMilli ~/ 1000);
  int get subtotalMinor =>
      lines.fold(0, (sum, l) => sum + l.lineTotalMinor);
  bool get isEmpty => lines.isEmpty;

  CartState copyWith({List<CartLine>? lines, String? customerId, bool clearCustomer = false}) {
    return CartState(
      lines: lines ?? this.lines,
      customerId: clearCustomer ? null : customerId ?? this.customerId,
    );
  }
}

class CartController extends Notifier<CartState> {
  @override
  CartState build() => const CartState();

  void add(Product product) {
    final lines = [...state.lines];
    final index = lines.indexWhere((l) => l.product.id == product.id);
    if (index >= 0) {
      lines[index].qtyMilli += 1000;
    } else {
      lines.add(
        CartLine(
          product: product,
          qtyMilli: 1000,
          unitPriceMinor: product.salePriceMinor,
        ),
      );
    }
    state = state.copyWith(lines: lines);
  }

  void increment(String productId) {
    final lines = [...state.lines];
    final index = lines.indexWhere((l) => l.product.id == productId);
    if (index < 0) return;
    lines[index].qtyMilli += 1000;
    state = state.copyWith(lines: lines);
  }

  void decrement(String productId) {
    final lines = [...state.lines];
    final index = lines.indexWhere((l) => l.product.id == productId);
    if (index < 0) return;
    lines[index].qtyMilli -= 1000;
    if (lines[index].qtyMilli <= 0) {
      lines.removeAt(index);
    }
    state = state.copyWith(lines: lines);
  }

  void remove(String productId) {
    final lines =
        state.lines.where((l) => l.product.id != productId).toList();
    state = state.copyWith(lines: lines);
  }

  void setCustomer(String? customerId) {
    state = state.copyWith(customerId: customerId, clearCustomer: customerId == null);
  }

  void clear() => state = const CartState();
}

final cartProvider = NotifierProvider<CartController, CartState>(
  CartController.new,
);
