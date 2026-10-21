import 'package:drift/drift.dart';

import '../../utils/uuid.dart';
import '../dokan_database.dart';

part 'purchases_dao.g.dart';

typedef PurchaseLineInput = ({
  String productId,
  int qtyMilli,
  int unitCostMinor,
});

@DriftAccessor(tables: [Purchases, PurchaseItems, Suppliers, Products])
class PurchasesDao extends DatabaseAccessor<DokanDatabase>
    with _$PurchasesDaoMixin {
  PurchasesDao(super.db);

  Stream<List<Purchase>> watchAll({int limit = 100}) {
    return (select(purchases)
          ..where((p) => p.isDeleted.equals(false))
          ..orderBy([(p) => OrderingTerm.desc(p.createdAt)])
          ..limit(limit))
        .watch();
  }

  Stream<List<PurchaseItem>> watchItems(String purchaseId) {
    return (select(purchaseItems)
          ..where((i) => i.purchaseId.equals(purchaseId))
          ..orderBy([(i) => OrderingTerm.asc(i.id)]))
        .watch();
  }

  Future<Purchase?> findById(String id) =>
      (select(purchases)..where((p) => p.id.equals(id))).getSingleOrNull();

  Future<Purchase> createPurchase({
    required String userId,
    required String branchId,
    required String supplierId,
    required List<PurchaseLineInput> items,
    int paidMinor = 0,
    String? notes,
  }) async {
    if (items.isEmpty) {
      throw ArgumentError('Purchase has no items');
    }
    return transaction(() async {
      var subtotal = 0;
      for (final line in items) {
        subtotal += line.qtyMilli * line.unitCostMinor ~/ 1000;
      }
      final due = (subtotal - paidMinor).clamp(0, 1 << 31);

      final now = DateTime.now();
      final period = '${now.year}${now.month.toString().padLeft(2, '0')}';
      final seq = await db.settingsDao.nextSequence(
        branchId: branchId,
        series: 'PO',
        period: period,
      );
      final invoiceNo = 'PO-${seq.toString().padLeft(6, '0')}';

      final purchaseId = newId();
      await into(purchases).insert(
        PurchasesCompanion.insert(
          id: Value(purchaseId),
          invoiceNo: invoiceNo,
          supplierId: supplierId,
          branchId: branchId,
          status: Value(PurchaseStatus.ordered),
          subtotalMinor: Value(subtotal),
          totalMinor: Value(subtotal),
          paidMinor: Value(paidMinor),
          dueMinor: Value(due),
          createdBy: Value(userId),
          notes: Value(notes),
        ),
      );

      for (final line in items) {
        await into(purchaseItems).insert(
          PurchaseItemsCompanion.insert(
            purchaseId: purchaseId,
            productId: line.productId,
            qtyMilli: line.qtyMilli,
            unitCostMinor: Value(line.unitCostMinor),
          ),
        );
      }

      await db.outboxDao.enqueue(
        entityType: 'purchase',
        entityId: purchaseId,
        action: OutboxAction.create,
        payload: {'invoiceNo': invoiceNo, 'totalMinor': subtotal},
      );

      return (select(purchases)..where((p) => p.id.equals(purchaseId)))
          .getSingle();
    });
  }

  Future<Purchase> markReceived({
    required String purchaseId,
    required String userId,
  }) async {
    return transaction(() async {
      final purchase = await (select(purchases)
            ..where((p) => p.id.equals(purchaseId)))
          .getSingle();
      if (purchase.status == PurchaseStatus.received) return purchase;

      final items = await (select(purchaseItems)
            ..where((i) => i.purchaseId.equals(purchaseId)))
          .get();
      for (final item in items) {
        await db.stockDao.adjustStock(
          productId: item.productId,
          branchId: purchase.branchId,
          deltaMilli: item.qtyMilli,
          type: StockMovementType.purchase,
          refType: 'purchase',
          refId: purchaseId,
          unitCostMinor: item.unitCostMinor,
          userId: userId,
        );
        await (update(purchaseItems)..where((i) => i.id.equals(item.id)))
            .write(PurchaseItemsCompanion(receivedQtyMilli: Value(item.qtyMilli)));
      }

      if (purchase.dueMinor > 0) {
        final supplier = await (select(suppliers)
              ..where((s) => s.id.equals(purchase.supplierId)))
            .getSingleOrNull();
        if (supplier != null) {
          await (update(suppliers)
                ..where((s) => s.id.equals(supplier.id)))
              .write(
            SuppliersCompanion(
              balanceMinor: Value(supplier.balanceMinor + purchase.dueMinor),
            ),
          );
        }
      }

      await (update(purchases)..where((p) => p.id.equals(purchaseId))).write(
        PurchasesCompanion(
          status: Value(PurchaseStatus.received),
          receivedAt: Value(DateTime.now()),
        ),
      );

      await db.outboxDao.enqueue(
        entityType: 'purchase',
        entityId: purchaseId,
        action: OutboxAction.update,
        payload: {'status': PurchaseStatus.received.name},
      );

      return (select(purchases)..where((p) => p.id.equals(purchaseId)))
          .getSingle();
    });
  }
}
