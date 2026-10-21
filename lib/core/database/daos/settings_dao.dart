import 'package:drift/drift.dart';

import '../dokan_database.dart';
import '../seed_ids.dart';

part 'settings_dao.g.dart';

@DriftAccessor(tables: [
  AppPreferences,
  Branches,
  BusinessSettings,
  Currencies,
  InvoiceCounters,
  Taxes,
  Units,
])
class SettingsDao extends DatabaseAccessor<DokanDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.db);

  Stream<BusinessSetting?> watchSettings() =>
      (select(businessSettings)..where((t) => t.id.equals(SeedIds.settingsId)))
          .watch()
          .map((rows) => rows.isEmpty ? null : rows.first);

  Future<BusinessSetting?> getSettings() async {
    final rows = await (select(businessSettings)
          ..where((t) => t.id.equals(SeedIds.settingsId)))
        .get();
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> updateSettings(BusinessSettingsCompanion data) =>
      into(businessSettings).insertOnConflictUpdate(
        data.copyWith(id: const Value(SeedIds.settingsId)),
      );

  Stream<List<Branch>> watchBranches() =>
      (select(branches)
            ..where((b) => b.isActive)
            ..orderBy([(b) => OrderingTerm.asc(b.name)]))
          .watch();

  Future<List<Branch>> getBranches() =>
      (select(branches)
            ..where((b) => b.isActive)
            ..orderBy([(b) => OrderingTerm.asc(b.name)]))
          .get();

  Future<Branch?> getDefaultBranch() async {
    final rows =
        await (select(branches)..where((b) => b.isDefault & b.isActive)).get();
    if (rows.isNotEmpty) return rows.first;
    final all = await getBranches();
    return all.isEmpty ? null : all.first;
  }

  Stream<List<Currency>> watchCurrencies() =>
      (select(currencies)
            ..where((c) => c.isActive)
            ..orderBy([(c) => OrderingTerm.asc(c.code)]))
          .watch();

  Future<Currency?> getBaseCurrency() async {
    final rows =
        await (select(currencies)..where((c) => c.isBase & c.isActive)).get();
    return rows.isEmpty ? null : rows.first;
  }

  Stream<List<Tax>> watchTaxes() =>
      (select(taxes)
            ..where((t) => t.isActive)
            ..orderBy([
              (t) => OrderingTerm.desc(t.isDefault),
              (t) => OrderingTerm.asc(t.name),
            ]))
          .watch();

  Future<Tax?> getDefaultTax() async {
    final rows =
        await (select(taxes)..where((t) => t.isDefault & t.isActive)).get();
    if (rows.isNotEmpty) return rows.first;
    final active = await (select(taxes)..where((t) => t.isActive)).get();
    return active.isEmpty ? null : active.first;
  }

  Stream<List<Unit>> watchUnits() =>
      (select(units)
            ..where((u) => u.isActive)
            ..orderBy([(u) => OrderingTerm.asc(u.name)]))
          .watch();

  Future<String?> getPreference(String key) async {
    final row = await (select(appPreferences)
          ..where((p) => p.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> setPreference(String key, String value) =>
      into(appPreferences).insertOnConflictUpdate(
        AppPreferencesCompanion.insert(key: key, value: value),
      );

  Future<int> nextSequence({
    required String branchId,
    required String series,
    required String period,
  }) {
    return transaction(() async {
      final counterId = '$branchId|$series|$period';
      final row = await (select(invoiceCounters)
            ..where((t) => t.id.equals(counterId)))
          .getSingleOrNull();
      if (row == null) {
        await into(invoiceCounters).insert(
          InvoiceCountersCompanion.insert(
            id: counterId,
            branchId: branchId,
            series: series,
            period: period,
            nextValue: const Value(2),
          ),
        );
        return 1;
      }
      await (update(invoiceCounters)..where((t) => t.id.equals(counterId)))
          .write(InvoiceCountersCompanion(nextValue: Value(row.nextValue + 1)));
      return row.nextValue;
    });
  }
}
