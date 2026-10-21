// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_dao.dart';

// ignore_for_file: type=lint
mixin _$SettingsDaoMixin on DatabaseAccessor<DokanDatabase> {
  $AppPreferencesTable get appPreferences => attachedDatabase.appPreferences;
  $BranchesTable get branches => attachedDatabase.branches;
  $BusinessSettingsTable get businessSettings =>
      attachedDatabase.businessSettings;
  $CurrenciesTable get currencies => attachedDatabase.currencies;
  $InvoiceCountersTable get invoiceCounters => attachedDatabase.invoiceCounters;
  $TaxesTable get taxes => attachedDatabase.taxes;
  $UnitsTable get units => attachedDatabase.units;
  SettingsDaoManager get managers => SettingsDaoManager(this);
}

class SettingsDaoManager {
  final _$SettingsDaoMixin _db;
  SettingsDaoManager(this._db);
  $$AppPreferencesTableTableManager get appPreferences =>
      $$AppPreferencesTableTableManager(
        _db.attachedDatabase,
        _db.appPreferences,
      );
  $$BranchesTableTableManager get branches =>
      $$BranchesTableTableManager(_db.attachedDatabase, _db.branches);
  $$BusinessSettingsTableTableManager get businessSettings =>
      $$BusinessSettingsTableTableManager(
        _db.attachedDatabase,
        _db.businessSettings,
      );
  $$CurrenciesTableTableManager get currencies =>
      $$CurrenciesTableTableManager(_db.attachedDatabase, _db.currencies);
  $$InvoiceCountersTableTableManager get invoiceCounters =>
      $$InvoiceCountersTableTableManager(
        _db.attachedDatabase,
        _db.invoiceCounters,
      );
  $$TaxesTableTableManager get taxes =>
      $$TaxesTableTableManager(_db.attachedDatabase, _db.taxes);
  $$UnitsTableTableManager get units =>
      $$UnitsTableTableManager(_db.attachedDatabase, _db.units);
}
