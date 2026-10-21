import 'package:drift/drift.dart';

import '../../utils/uuid.dart';
import '../dokan_database.dart';

part 'sales_dao.g.dart';

typedef SaleLineInput = ({
  String productId,
  String nameSnapshot,
  String? nameArSnapshot,
  String skuSnapshot,
  String? barcodeSnapshot,
  int qtyMilli,
  int unitPriceMinor,
  int unitCostMinor,
});

@DriftAccessor(tables: [Sales, SaleItems, Payments, Products, StockBalances])
class SalesDao extends DatabaseAccessor<DokanDatabase> with _$SalesDaoMixin {
  SalesDao(super.db);

  Stream<List<Sale>> watchRecent({int limit = 50}) {
    return (select(sales)
          ..where((s) => s.isDeleted.equals(false))
          ..orderBy([(s) => OrderingTerm.desc(s.soldAt)])
          ..limit(limit))
        .watch();
  }

  Stream<List<Sale>> watchBetween(DateTime from, DateTime to) {
    return (select(sales)
          ..where(
            (s) =>
                s.isDeleted.equals(false) &
                s.soldAt.isBiggerOrEqualValue(from) &
                s.soldAt.isSmallerThanValue(to),
          )
          ..orderBy([(s) => OrderingTerm.desc(s.soldAt)]))
        .watch();
  }

  Future<Sale?> findById(String id) =>
      (select(sales)..where((s) => s.id.equals(id))).getSingleOrNull();

  Stream<List<SaleItem>> watchItems(String saleId) {
    return (select(saleItems)
          ..where((i) => i.saleId.equals(saleId))
          ..orderBy([(i) => OrderingTerm.asc(i.lineNo)]))
        .watch();
  }

  Future<Sale> checkout({
    required String userId,
    required String branchId,
    required List<SaleLineInput> items,
    required PayMethod method,
    String? customerId,
    String? shiftId,
    String currencyCode = 'USD',
    int orderDiscountMinor = 0,
    int? tenderedMinor,
    String? notes,
  }) async {
    if (items.isEmpty) {
      throw ArgumentError('Cart is empty');
    }
    return transaction(() async {
      var subtotal = 0;
      var costTotal = 0;
      var units = 0;
      for (final line in items) {
        subtotal += line.qtyMilli * line.unitPriceMinor ~/ 1000;
        costTotal += line.qtyMilli * line.unitCostMinor ~/ 1000;
        units += line.qtyMilli ~/ 1000;
      }
      final total = (subtotal - orderDiscountMinor).clamp(0, 1 << 31);
      final isCash = method == PayMethod.cash;
      final tendered = isCash ? (tenderedMinor ?? total) : total;
      final change = isCash && tendered > total ? tendered - total : 0;
      final paid = method == PayMethod.credit ? 0 : total;
      final due = total - paid;

      final now = DateTime.now();
      final period = '${now.year}${now.month.toString().padLeft(2, '0')}';
      final seq = await db.settingsDao.nextSequence(
        branchId: branchId,
        series: 'INV',
        period: period,
      );
      final invoiceNo =
          'INV-${seq.toString().padLeft(6, '0')}';

      final saleId = newId();
      await into(sales).insert(
        SalesCompanion.insert(
          id: Value(saleId),
          invoiceNo: invoiceNo,
          branchId: branchId,
          cashierId: userId,
          customerId: Value(customerId),
          shiftId: Value(shiftId),
          status: Value(SaleStatus.completed),
          subtotalMinor: subtotal,
          orderDiscountMinor: Value(orderDiscountMinor),
          taxMinor: Value(0),
          totalMinor: total,
          paidMinor: Value(paid),
          dueMinor: Value(due),
          changeMinor: Value(change),
          currencyCode: Value(currencyCode),
          itemsCount: Value(units),
          costTotalMinor: Value(costTotal),
          notes: Value(notes),
        ),
      );

      var lineNo = 1;
      for (final line in items) {
        final lineTotal = line.qtyMilli * line.unitPriceMinor ~/ 1000;
        await into(saleItems).insert(
          SaleItemsCompanion.insert(
            saleId: saleId,
            lineNo: lineNo++,
            productId: line.productId,
            nameSnapshot: line.nameSnapshot,
            nameArSnapshot: Value(line.nameArSnapshot),
            skuSnapshot: line.skuSnapshot,
            barcodeSnapshot: Value(line.barcodeSnapshot),
            qtyMilli: line.qtyMilli,
            unitPriceMinor: line.unitPriceMinor,
            unitCostMinor: Value(line.unitCostMinor),
            totalMinor: lineTotal,
          ),
        );
        final product = await (select(products)
              ..where((p) => p.id.equals(line.productId)))
            .getSingleOrNull();
        if (product != null && product.trackStock) {
          await _applyStockDelta(
            productId: line.productId,
            branchId: branchId,
            deltaMilli: -line.qtyMilli,
            refId: saleId,
            userId: userId,
          );
        }
      }

      await into(payments).insert(
        PaymentsCompanion.insert(
          refType: PaymentRefType.sale,
          refId: saleId,
          branchId: branchId,
          shiftId: Value(shiftId),
          method: method,
          amountMinor: paid,
          tenderedMinor: Value(isCash ? tendered : null),
          changeMinor: Value(change),
          currencyCode: Value(currencyCode),
          userId: Value(userId),
        ),
      );

      if (isCash && shiftId != null) {
        await db.shiftsDao.applySaleCash(
          shiftId: shiftId,
          cashAmountMinor: paid,
        );
      }

      await db.outboxDao.enqueue(
        entityType: 'sale',
        entityId: saleId,
        action: OutboxAction.create,
        payload: {'invoiceNo': invoiceNo, 'totalMinor': total},
      );

      return (select(sales)..where((s) => s.id.equals(saleId))).getSingle();
    });
  }

  Future<void> _applyStockDelta({
    required String productId,
    required String branchId,
    required int deltaMilli,
    required String refId,
    required String userId,
  }) async {
    await db.stockDao.adjustStock(
      productId: productId,
      branchId: branchId,
      deltaMilli: deltaMilli,
      type: StockMovementType.sale,
      refType: 'sale',
      refId: refId,
      userId: userId,
    );
  }
}
