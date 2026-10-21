abstract final class PermissionCodes {
  static const String all = '*';

  static const String salesCreate = 'sales.create';
  static const String salesDiscount = 'sales.discount';
  static const String salesPriceOverride = 'sales.price_override';
  static const String salesVoid = 'sales.void';
  static const String salesRefund = 'sales.refund';
  static const String salesHold = 'sales.hold';
  static const String salesViewAll = 'sales.view_all';

  static const String paymentsSplit = 'payments.split';
  static const String paymentsPartial = 'payments.partial';
  static const String paymentsCredit = 'payments.credit';

  static const String productsView = 'products.view';
  static const String productsManage = 'products.manage';
  static const String productsPriceManage = 'products.price_manage';

  static const String inventoryView = 'inventory.view';
  static const String inventoryAdjust = 'inventory.adjust';
  static const String inventoryTransfer = 'inventory.transfer';

  static const String customersView = 'customers.view';
  static const String customersManage = 'customers.manage';
  static const String customersCreditManage = 'customers.credit_manage';

  static const String suppliersManage = 'suppliers.manage';
  static const String purchasesManage = 'purchases.manage';

  static const String reportsSales = 'reports.sales';
  static const String reportsProfit = 'reports.profit';
  static const String reportsInventory = 'reports.inventory';
  static const String reportsCashier = 'reports.cashier';
  static const String reportsExport = 'reports.export';

  static const String shiftsOpen = 'shifts.open';
  static const String shiftsClose = 'shifts.close';
  static const String shiftsCashMove = 'shifts.cash_move';
  static const String shiftsReport = 'shifts.report';

  static const String usersManage = 'users.manage';
  static const String rolesManage = 'roles.manage';
  static const String settingsManage = 'settings.manage';
  static const String settingsPrinter = 'settings.printer';
  static const String settingsBranch = 'settings.branch';
  static const String syncManage = 'sync.manage';
  static const String backupManage = 'backup.manage';
  static const String auditView = 'audit.view';

  static const List<({String code, String module, String en, String ar})> catalog =
      <({String code, String module, String en, String ar})>[
    (code: salesCreate, module: 'sales', en: 'Create sales', ar: 'إنشاء المبيعات'),
    (code: salesDiscount, module: 'sales', en: 'Apply discounts', ar: 'تطبيق الخصومات'),
    (code: salesPriceOverride, module: 'sales', en: 'Override prices', ar: 'تعديل الأسعار'),
    (code: salesVoid, module: 'sales', en: 'Void sales', ar: 'إلغاء المبيعات'),
    (code: salesRefund, module: 'sales', en: 'Process refunds', ar: 'معالجة المرتجعات'),
    (code: salesHold, module: 'sales', en: 'Hold / resume orders', ar: 'تعليق واستئناف الطلبات'),
    (code: salesViewAll, module: 'sales', en: "View other cashiers' sales", ar: 'عرض مبيعات الكاشيرين الآخرين'),
    (code: paymentsSplit, module: 'payments', en: 'Split payments', ar: 'تقسيم الدفعات'),
    (code: paymentsPartial, module: 'payments', en: 'Partial payments', ar: 'دفعات جزئية'),
    (code: paymentsCredit, module: 'payments', en: 'Sell on credit', ar: 'البيع بالآجل'),
    (code: productsView, module: 'products', en: 'View products', ar: 'عرض المنتجات'),
    (code: productsManage, module: 'products', en: 'Manage products', ar: 'إدارة المنتجات'),
    (code: productsPriceManage, module: 'products', en: 'Manage prices', ar: 'إدارة الأسعار'),
    (code: inventoryView, module: 'inventory', en: 'View stock', ar: 'عرض المخزون'),
    (code: inventoryAdjust, module: 'inventory', en: 'Adjust stock', ar: 'تسوية المخزون'),
    (code: inventoryTransfer, module: 'inventory', en: 'Transfer stock', ar: 'نقل المخزون'),
    (code: customersView, module: 'customers', en: 'View customers', ar: 'عرض العملاء'),
    (code: customersManage, module: 'customers', en: 'Manage customers', ar: 'إدارة العملاء'),
    (code: customersCreditManage, module: 'customers', en: 'Manage credit limits', ar: 'إدارة حدود الدين'),
    (code: suppliersManage, module: 'suppliers', en: 'Manage suppliers', ar: 'إدارة الموردين'),
    (code: purchasesManage, module: 'purchases', en: 'Manage purchases', ar: 'إدارة المشتريات'),
    (code: reportsSales, module: 'reports', en: 'Sales reports', ar: 'تقارير المبيعات'),
    (code: reportsProfit, module: 'reports', en: 'Profit reports', ar: 'تقارير الأرباح'),
    (code: reportsInventory, module: 'reports', en: 'Inventory reports', ar: 'تقارير المخزون'),
    (code: reportsCashier, module: 'reports', en: 'Cashier performance', ar: 'أداء الكاشير'),
    (code: reportsExport, module: 'reports', en: 'Export reports', ar: 'تصدير التقارير'),
    (code: shiftsOpen, module: 'shifts', en: 'Open register', ar: 'فتح الصندوق'),
    (code: shiftsClose, module: 'shifts', en: 'Close register', ar: 'إقفال الصندوق'),
    (code: shiftsCashMove, module: 'shifts', en: 'Cash in / cash out', ar: 'إدخال وإخراج النقد'),
    (code: shiftsReport, module: 'shifts', en: 'End-of-day report', ar: 'تقرير نهاية اليوم'),
    (code: usersManage, module: 'admin', en: 'Manage users', ar: 'إدارة المستخدمين'),
    (code: rolesManage, module: 'admin', en: 'Manage roles', ar: 'إدارة الأدوار'),
    (code: settingsManage, module: 'admin', en: 'Manage settings', ar: 'إدارة الإعدادات'),
    (code: settingsPrinter, module: 'admin', en: 'Manage printers', ar: 'إدارة الطابعات'),
    (code: settingsBranch, module: 'admin', en: 'Manage branches', ar: 'إدارة الفروع'),
    (code: syncManage, module: 'admin', en: 'Manage sync', ar: 'إدارة المزامنة'),
    (code: backupManage, module: 'admin', en: 'Backup and restore', ar: 'النسخ الاحتياطي والاستعادة'),
    (code: auditView, module: 'admin', en: 'View audit log', ar: 'عرض سجل التدقيق'),
  ];
}

abstract final class RoleDefaults {
  static const String admin = 'admin';
  static const String manager = 'manager';
  static const String cashier = 'cashier';

  static const List<String> adminPermissions = <String>[PermissionCodes.all];

  static const List<String> managerPermissions = <String>[
    PermissionCodes.salesCreate,
    PermissionCodes.salesDiscount,
    PermissionCodes.salesPriceOverride,
    PermissionCodes.salesVoid,
    PermissionCodes.salesRefund,
    PermissionCodes.salesHold,
    PermissionCodes.salesViewAll,
    PermissionCodes.paymentsSplit,
    PermissionCodes.paymentsPartial,
    PermissionCodes.paymentsCredit,
    PermissionCodes.productsView,
    PermissionCodes.productsManage,
    PermissionCodes.productsPriceManage,
    PermissionCodes.inventoryView,
    PermissionCodes.inventoryAdjust,
    PermissionCodes.inventoryTransfer,
    PermissionCodes.customersView,
    PermissionCodes.customersManage,
    PermissionCodes.customersCreditManage,
    PermissionCodes.suppliersManage,
    PermissionCodes.purchasesManage,
    PermissionCodes.reportsSales,
    PermissionCodes.reportsProfit,
    PermissionCodes.reportsInventory,
    PermissionCodes.reportsCashier,
    PermissionCodes.reportsExport,
    PermissionCodes.shiftsOpen,
    PermissionCodes.shiftsClose,
    PermissionCodes.shiftsCashMove,
    PermissionCodes.shiftsReport,
    PermissionCodes.settingsPrinter,
    PermissionCodes.syncManage,
    PermissionCodes.auditView,
  ];

  static const List<String> cashierPermissions = <String>[
    PermissionCodes.salesCreate,
    PermissionCodes.salesDiscount,
    PermissionCodes.salesHold,
    PermissionCodes.paymentsSplit,
    PermissionCodes.productsView,
    PermissionCodes.inventoryView,
    PermissionCodes.customersView,
    PermissionCodes.shiftsOpen,
    PermissionCodes.shiftsClose,
    PermissionCodes.shiftsReport,
  ];
}
