import 'package:drift/drift.dart';

import '../constants/permissions.dart';
import '../security/pin_hasher.dart';
import 'dokan_database.dart';
import 'seed_ids.dart';

Future<void> seedInitialData(DokanDatabase db) async {
  await db.batch((batch) {
    batch.insertAll(db.roles, [
      RolesCompanion.insert(
        id: const Value(SeedIds.adminRole),
        name: RoleDefaults.admin,
        nameAr: const Value('مدير'),
        isSystem: const Value(true),
      ),
      RolesCompanion.insert(
        id: const Value(SeedIds.managerRole),
        name: RoleDefaults.manager,
        nameAr: const Value('مدير فرع'),
        isSystem: const Value(true),
      ),
      RolesCompanion.insert(
        id: const Value(SeedIds.cashierRole),
        name: RoleDefaults.cashier,
        nameAr: const Value('كاشير'),
        isSystem: const Value(true),
      ),
    ]);

    batch.insertAll(db.permissions, [
      for (final item in PermissionCodes.catalog)
        PermissionsCompanion.insert(
          id: Value(item.code),
          code: item.code,
          module: item.module,
          name: item.en,
          nameAr: Value(item.ar),
        ),
      PermissionsCompanion.insert(
        id: const Value(PermissionCodes.all),
        code: PermissionCodes.all,
        module: 'admin',
        name: 'All permissions',
        nameAr: const Value('كل الصلاحيات'),
      ),
    ]);

    batch.insertAll(db.rolePermissions, [
      for (final item in PermissionCodes.catalog)
        RolePermissionsCompanion(
          roleId: const Value(SeedIds.adminRole),
          permissionId: Value(item.code),
        ),
      const RolePermissionsCompanion(
        roleId: Value(SeedIds.adminRole),
        permissionId: Value(PermissionCodes.all),
      ),
      for (final code in RoleDefaults.managerPermissions)
        RolePermissionsCompanion(
          roleId: const Value(SeedIds.managerRole),
          permissionId: Value(code),
        ),
      for (final code in RoleDefaults.cashierPermissions)
        RolePermissionsCompanion(
          roleId: const Value(SeedIds.cashierRole),
          permissionId: Value(code),
        ),
    ]);

    batch.insertAll(db.branches, [
      BranchesCompanion.insert(
        id: const Value(SeedIds.mainBranchId),
        code: 'MAIN',
        name: 'Main Branch',
        nameAr: const Value('الفرع الرئيسي'),
        isDefault: const Value(true),
      ),
    ]);

    batch.insertAll(db.currencies, [
      CurrenciesCompanion.insert(
        id: const Value(SeedIds.currencyUsd),
        code: 'USD',
        symbol: r'$',
        isBase: const Value(true),
      ),
      CurrenciesCompanion.insert(
        id: const Value('cur-eur'),
        code: 'EUR',
        symbol: '€',
        exchangeRateMicro: const Value(1080000),
      ),
      CurrenciesCompanion.insert(
        id: const Value('cur-pkr'),
        code: 'PKR',
        symbol: '₨',
        symbolPosition: const Value(CurrencySymbolPosition.after),
        exchangeRateMicro: const Value(3600),
      ),
      CurrenciesCompanion.insert(
        id: const Value('cur-aed'),
        code: 'AED',
        symbol: 'د.إ',
        symbolPosition: const Value(CurrencySymbolPosition.after),
        exchangeRateMicro: const Value(272000),
      ),
      CurrenciesCompanion.insert(
        id: const Value('cur-sar'),
        code: 'SAR',
        symbol: 'ر.س',
        symbolPosition: const Value(CurrencySymbolPosition.after),
        exchangeRateMicro: const Value(270000),
      ),
    ]);

    batch.insertAll(db.taxes, [
      TaxesCompanion.insert(
        id: const Value(SeedIds.taxNoTax),
        name: 'No Tax',
        nameAr: const Value('بدون ضريبة'),
        rateBp: 0,
        isDefault: const Value(true),
      ),
      TaxesCompanion.insert(
        id: const Value(SeedIds.taxVat15),
        name: 'VAT 15%',
        nameAr: const Value('ضريبة ١٥٪'),
        rateBp: 1500,
      ),
    ]);

    batch.insertAll(db.units, [
      UnitsCompanion.insert(
        id: const Value(SeedIds.unitPiece),
        name: 'Piece',
        nameAr: const Value('قطعة'),
        isBase: const Value(true),
      ),
      UnitsCompanion.insert(
        id: const Value(SeedIds.unitDozen),
        name: 'Dozen',
        nameAr: const Value('دزينة'),
        factorMilli: const Value(12000),
      ),
      UnitsCompanion.insert(
        id: const Value(SeedIds.unitKg),
        name: 'Kilogram',
        nameAr: const Value('كيلوغرام'),
        dimension: const Value('weight'),
        isBase: const Value(true),
      ),
      UnitsCompanion.insert(
        id: const Value(SeedIds.unitGram),
        name: 'Gram',
        nameAr: const Value('غرام'),
        factorMilli: const Value(1),
        dimension: const Value('weight'),
      ),
      UnitsCompanion.insert(
        id: const Value(SeedIds.unitLiter),
        name: 'Liter',
        nameAr: const Value('لتر'),
        dimension: const Value('volume'),
        isBase: const Value(true),
      ),
      UnitsCompanion.insert(
        id: const Value(SeedIds.unitMl),
        name: 'Milliliter',
        nameAr: const Value('مل'),
        factorMilli: const Value(1),
        dimension: const Value('volume'),
      ),
    ]);

    batch.insertAll(db.categories, [
      CategoriesCompanion.insert(
        id: const Value(SeedIds.generalCategory),
        name: 'General',
        nameAr: const Value('عام'),
      ),
    ]);

    batch.insertAll(db.businessSettings, [
      BusinessSettingsCompanion.insert(
        id: const Value(SeedIds.settingsId),
        shopName: const Value('Dokan POS'),
        shopNameAr: const Value('نظام دكان'),
        defaultBranchId: const Value(SeedIds.mainBranchId),
      ),
    ]);
  });

  final adminHash = await PinHasher.hash(SeedIds.defaultPin);
  final managerHash = await PinHasher.hash(SeedIds.defaultPin);
  final cashierHash = await PinHasher.hash(SeedIds.defaultPin);

  await db.batch((batch) {
    batch.insertAll(db.users, [
      UsersCompanion.insert(
        id: const Value(SeedIds.adminUser),
        username: 'admin',
        fullName: 'Administrator',
        fullNameAr: const Value('المدير العام'),
        pinHash: adminHash.hash,
        pinSalt: adminHash.salt,
        branchId: const Value(SeedIds.mainBranchId),
        defaultRoleId: const Value(SeedIds.adminRole),
        mustChangePin: const Value(true),
      ),
      UsersCompanion.insert(
        id: const Value(SeedIds.managerUser),
        username: 'manager',
        fullName: 'Branch Manager',
        fullNameAr: const Value('مدير الفرع'),
        pinHash: managerHash.hash,
        pinSalt: managerHash.salt,
        branchId: const Value(SeedIds.mainBranchId),
        defaultRoleId: const Value(SeedIds.managerRole),
        mustChangePin: const Value(true),
      ),
      UsersCompanion.insert(
        id: const Value(SeedIds.cashierUser),
        username: 'cashier',
        fullName: 'Cashier',
        fullNameAr: const Value('الكاشير'),
        pinHash: cashierHash.hash,
        pinSalt: cashierHash.salt,
        branchId: const Value(SeedIds.mainBranchId),
        defaultRoleId: const Value(SeedIds.cashierRole),
        mustChangePin: const Value(true),
      ),
    ]);

    batch.insertAll(db.userRoles, [
      const UserRolesCompanion(
        userId: Value(SeedIds.adminUser),
        roleId: Value(SeedIds.adminRole),
      ),
      const UserRolesCompanion(
        userId: Value(SeedIds.managerUser),
        roleId: Value(SeedIds.managerRole),
      ),
      const UserRolesCompanion(
        userId: Value(SeedIds.cashierUser),
        roleId: Value(SeedIds.cashierRole),
      ),
    ]);

    batch.insertAll(db.userBranches, [
      const UserBranchesCompanion(
        userId: Value(SeedIds.adminUser),
        branchId: Value(SeedIds.mainBranchId),
      ),
      const UserBranchesCompanion(
        userId: Value(SeedIds.managerUser),
        branchId: Value(SeedIds.mainBranchId),
      ),
      const UserBranchesCompanion(
        userId: Value(SeedIds.cashierUser),
        branchId: Value(SeedIds.mainBranchId),
      ),
    ]);
  });
}
