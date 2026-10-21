import 'package:drift/drift.dart';

import '../dokan_database.dart';
import '../seed_ids.dart';

part 'stock_dao.g.dart';

@DriftAccessor(tables: [StockBalances, StockMovements, Products])
class StockDao extends DatabaseAccessor<DokanDatabase> with _$StockDaoMixin {
  StockDao(super.db);

  Future<int> getQty(String productId, {String branchId = SeedIds.mainBranchId, String variantId = ''}) async {
    final row = await (select(stockBalances)
          ..where(
            (s) =>
                s.productId.equals(productId) &
                s.variantId.equals(variantId) &
                s.branchId.equals(branchId),
          ))
        .getSingleOrNull();
    return row?.qtyMilli ?? 0;
  }

  Stream<int> watchQty(String productId, {String branchId = SeedIds.mainBranchId, String variantId = ''}) {
    return (select(stockBalances)
          ..where(
            (s) =>
                s.productId.equals(productId) &
                s.variantId.equals(variantId) &
                s.branchId.equals(branchId),
          ))
        .watch()
        .map((rows) => rows.isEmpty ? 0 : rows.first.qtyMilli);
  }

  Future<void> adjustStock({
    required String productId,
    required int deltaMilli,
    required StockMovementType type,
    String branchId = SeedIds.mainBranchId,
    String variantId = '',
    String? refType,
    String? refId,
    int? unitCostMinor,
    String? userId,
  }) async {
    final existing = await (select(stockBalances)
          ..where(
            (s) =>
                s.productId.equals(productId) &
                s.variantId.equals(variantId) &
                s.branchId.equals(branchId),
          ))
        .getSingleOrNull();
    final newQty = (existing?.qtyMilli ?? 0) + deltaMilli;
    if (existing == null) {
      await into(stockBalances).insert(
        StockBalancesCompanion.insert(
          productId: productId,
          variantId: Value(variantId),
          branchId: branchId,
          qtyMilli: Value(newQty),
        ),
      );
    } else {
      await (update(stockBalances)
            ..where(
              (s) =>
                  s.productId.equals(productId) &
                  s.variantId.equals(variantId) &
                  s.branchId.equals(branchId),
            ))
          .write(StockBalancesCompanion(qtyMilli: Value(newQty)));
    }
    await into(stockMovements).insert(
      StockMovementsCompanion.insert(
        productId: productId,
        variantId: Value(variantId),
        branchId: branchId,
        deltaMilli: deltaMilli,
        balanceAfterMilli: Value(newQty),
        type: type,
        refType: Value(refType),
        refId: Value(refId),
        unitCostMinor: Value(unitCostMinor),
        userId: Value(userId),
      ),
    );
  }

  Stream<List<({String productId, String name, String sku, int qtyMilli, int alertMilli})>>
      watchLowStock({String branchId = SeedIds.mainBranchId}) {
    final qty = stockBalances.qtyMilli.sum();
    final query = selectOnly(products)
      ..addColumns([
        products.id,
        products.name,
        products.sku,
        qty,
        products.stockAlertMilli,
      ])
      ..where(
        products.isDeleted.equals(false) &
            products.isActive.equals(true) &
            products.trackStock.equals(true),
      )
      ..join([
        leftOuterJoin(
          stockBalances,
          stockBalances.productId.equalsExp(products.id) &
              stockBalances.branchId.equals(branchId) &
              stockBalances.variantId.equals(''),
        ),
      ])
      ..groupBy([products.id]);
    return query.watch().map((rows) {
      final result = <({
        String productId,
        String name,
        String sku,
        int qtyMilli,
        int alertMilli
      })>[];
      for (final row in rows) {
        final q = row.read(qty) ?? 0;
        final alert = row.read(products.stockAlertMilli) ?? 0;
        final threshold = alert > 0 ? alert : 1000;
        if (q < threshold) {
          result.add((
            productId: row.read(products.id)!,
            name: row.read(products.name)!,
            sku: row.read(products.sku)!,
            qtyMilli: q,
            alertMilli: alert,
          ));
        }
      }
      return result;
    });
  }
}
