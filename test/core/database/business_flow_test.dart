import 'package:dokan_system/core/database/dokan_database.dart';
import 'package:dokan_system/core/database/seed_ids.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

DokanDatabase buildDatabase() => DokanDatabase.forTesting(NativeDatabase.memory());

void main() {
  late DokanDatabase db;

  setUp(() => db = buildDatabase());
  tearDown(() => db.close());

  test('customers and suppliers CRUD', () async {
    await db.customersDao.insertCustomer(
      CustomersCompanion.insert(
        id: Value('c1'),
        name: 'Ali',
        phone: const Value('123'),
      ),
    );
    var list = await db.customersDao.getAll(includeInactive: true);
    expect(list.length, isNonZero);
    await db.customersDao.updateCustomer('c1', const CustomersCompanion(name: Value('Ali Khan')));
    final c = await db.customersDao.findById('c1');
    expect(c!.name, 'Ali Khan');
    await db.customersDao.softDelete('c1');
    expect(await db.customersDao.getAll(includeInactive: true).then((v) => v.length), 1);
    expect(await db.customersDao.getAll(), isEmpty);

    await db.suppliersDao.insertSupplier(
      SuppliersCompanion.insert(id: Value('s1'), name: 'Vendor A'),
    );
    expect(await db.suppliersDao.getAll().then((v) => v.length), 1);
  });

  test('shift open/close and cash moves', () async {
    final open = await db.shiftsDao.openShift(
      userId: SeedIds.cashierUser,
      branchId: SeedIds.mainBranchId,
      openingCashMinor: 100000,
    );
    expect(open.status, ShiftStatus.open);
    await db.shiftsDao.addCashTransaction(
      shiftId: open.id,
      type: ShiftTxType.cashIn,
      amountMinor: 20000,
      reason: 'change',
    );
    await db.shiftsDao.addCashTransaction(
      shiftId: open.id,
      type: ShiftTxType.cashOut,
      amountMinor: 5000,
      reason: 'petty',
    );
    await db.shiftsDao.applySaleCash(shiftId: open.id, cashAmountMinor: 15000);
    final closed = await db.shiftsDao.closeShift(shiftId: open.id, countedCashMinor: 130000);
    expect(closed.status, ShiftStatus.closed);
    expect(closed.differenceMinor, 130000 - closed.expectedCashMinor);
  });

  test('purchase create and receive updates stock', () async {
    await db.suppliersDao.insertSupplier(
      SuppliersCompanion.insert(id: Value('s1'), name: 'Vendor'),
    );
    final cat = await db.select(db.categories).getSingle();
    await db.productsDao.insertProduct(
      ProductsCompanion.insert(
        id: Value('p1'),
        sku: 'P1',
        name: 'Test Item',
        categoryId: Value(cat.id),
        unitId: SeedIds.unitPiece,
        salePriceMinor: const Value(1000),
        costPriceMinor: const Value(500),
      ),
    );
    final purchase = await db.purchasesDao.createPurchase(
      userId: SeedIds.adminUser,
      branchId: SeedIds.mainBranchId,
      supplierId: 's1',
      items: const [(productId: 'p1', qtyMilli: 2000, unitCostMinor: 500)],
      paidMinor: 0,
    );
    expect(purchase.status, PurchaseStatus.ordered);
    expect(await db.stockDao.getQty('p1'), 0);
    await db.purchasesDao.markReceived(purchaseId: purchase.id, userId: SeedIds.adminUser);
    expect(await db.stockDao.getQty('p1'), 2000);
    final after = await db.purchasesDao.findById(purchase.id);
    expect(after!.status, PurchaseStatus.received);
  });

  test('sale checkout deducts stock and records payment', () async {
    final cat = await db.select(db.categories).getSingle();
    await db.productsDao.insertProduct(
      ProductsCompanion.insert(
        id: Value('p2'),
        sku: 'P2',
        name: 'Widget',
        categoryId: Value(cat.id),
        unitId: SeedIds.unitPiece,
        salePriceMinor: const Value(2000),
        costPriceMinor: const Value(800),
        trackStock: const Value(true),
      ),
    );
    await db.stockDao.adjustStock(
      productId: 'p2',
      branchId: SeedIds.mainBranchId,
      deltaMilli: 5000,
      type: StockMovementType.initial,
    );
    expect(await db.stockDao.getQty('p2'), 5000);

    final shift = await db.shiftsDao.openShift(
      userId: SeedIds.cashierUser,
      branchId: SeedIds.mainBranchId,
      openingCashMinor: 0,
    );

    final sale = await db.salesDao.checkout(
      userId: SeedIds.cashierUser,
      branchId: SeedIds.mainBranchId,
      items: const [
        (
          productId: 'p2',
          nameSnapshot: 'Widget',
          nameArSnapshot: null,
          skuSnapshot: 'P2',
          barcodeSnapshot: null,
          qtyMilli: 2000,
          unitPriceMinor: 2000,
          unitCostMinor: 800,
        ),
      ],
      method: PayMethod.cash,
      shiftId: shift.id,
      tenderedMinor: 4000,
    );
    expect(sale.status, SaleStatus.completed);
    expect(sale.invoiceNo.startsWith('INV-'), isTrue);
    expect(await db.stockDao.getQty('p2'), 3000);

    final payments = await db.select(db.payments).get();
    expect(payments.length, 1);
    expect(payments.first.method, PayMethod.cash);
    expect(payments.first.amountMinor, 4000);

    final reloadedShift = (await db.select(db.shifts).get()).first;
    expect(reloadedShift.cashSalesMinor, 4000);
  });

  test('reports summary and top products', () async {
    final from = DateTime.now().subtract(const Duration(hours: 1));
    final summary = await db.reportsDao.salesSummary(from, DateTime.now().add(const Duration(hours: 1)));
    expect(summary.count, greaterThanOrEqualTo(0));
    expect(summary.revenueMinor, greaterThanOrEqualTo(0));

    final top = await db.reportsDao.topProducts(from);
    expect(top, isA<List>());
    final breakdown = await db.reportsDao.paymentBreakdown(from, DateTime.now().add(const Duration(hours: 1)));
    expect(breakdown, isA<List>());
  });
}
