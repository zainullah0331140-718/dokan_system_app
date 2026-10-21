// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Dokan POS';

  @override
  String get appTagline => 'Offline-first point of sale';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navSales => 'Sales';

  @override
  String get navProducts => 'Products';

  @override
  String get navCustomers => 'Customers';

  @override
  String get navInventory => 'Inventory';

  @override
  String get navPurchases => 'Purchases';

  @override
  String get navReports => 'Reports';

  @override
  String get navShifts => 'Shifts';

  @override
  String get navSettings => 'Settings';

  @override
  String get navMore => 'More';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get retry => 'Retry';

  @override
  String get search => 'Search';

  @override
  String get close => 'Close';

  @override
  String get back => 'Back';

  @override
  String get done => 'Done';

  @override
  String get loading => 'Loading…';

  @override
  String get error => 'Something went wrong';

  @override
  String get confirm => 'Confirm';

  @override
  String get signOut => 'Sign out';

  @override
  String get underConstruction =>
      'This section is being built and will be available soon.';

  @override
  String get noResults => 'No results found';

  @override
  String get tryAgain => 'Try again';

  @override
  String get permissionDenied =>
      'You don\'t have permission to open this section.';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginSubtitle => 'Open the register to start selling';

  @override
  String get username => 'Username';

  @override
  String get pin => 'PIN';

  @override
  String get pinRequired => 'Enter your PIN';

  @override
  String get usernameRequired => 'Enter your username';

  @override
  String get signIn => 'Sign in';

  @override
  String get signingIn => 'Verifying…';

  @override
  String get invalidCredentials => 'Incorrect username or PIN';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get langEnglish => 'English';

  @override
  String get langArabic => 'العربية';

  @override
  String get langUrdu => 'اردو';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get currentUser => 'Signed in as';

  @override
  String get currentBranch => 'Branch';

  @override
  String get statProducts => 'Products';

  @override
  String get statCustomers => 'Customers';

  @override
  String get statTotalSales => 'Sales records';

  @override
  String get statPendingSync => 'Pending sync';

  @override
  String get databaseReady => 'Database ready (encrypted)';

  @override
  String get logoutConfirmTitle => 'Sign out?';

  @override
  String get logoutConfirmMessage =>
      'You will need your username and PIN to sign in again.';

  @override
  String get errorDatabase => 'Local database error';

  @override
  String get errorNetwork => 'Network unavailable. Your data is saved locally.';

  @override
  String get errorValidation => 'Please check the entered values';

  @override
  String get errorPermission => 'This action is not allowed for your role';

  @override
  String get errorAuth => 'Sign-in failed';

  @override
  String get errorNotFound => 'The requested item was not found';

  @override
  String get errorConflict => 'The record changed on another device';

  @override
  String get errorUnknown => 'Unexpected error';

  @override
  String get mustChangePin => 'Your PIN will need to be changed soon.';

  @override
  String get accountDisabled => 'This account has been disabled.';
}
