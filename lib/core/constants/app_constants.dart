import 'package:flutter/material.dart';

abstract final class AppConstants {
  static const String appName = 'Dokan POS';
  static const String databaseFileName = 'dokan_system.db';

  static const int pinLength = 4;
  static const int pinMaxLength = 8;
  static const int pbkdf2Iterations = 100000;
  static const int pinSaltBytes = 16;
  static const int maxLoginAttempts = 5;
  static const Duration loginLockoutDuration = Duration(minutes: 15);

  static const int outboxMaxAttempts = 8;
  static const int outboxRetryBaseSeconds = 15;
  static const int syncBatchSize = 50;
  static const int printMaxAttempts = 3;

  static const int defaultCurrencyDecimalPlaces = 2;
  static const int lowStockThresholdMilli = 1000;

  static const Duration loginTimeout = Duration(seconds: 15);
  static const Duration snackBarShort = Duration(milliseconds: 1800);
  static const Duration snackBarLong = Duration(seconds: 4);

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ar'),
    Locale('ur'),
  ];
  static const Locale fallbackLocale = Locale('en');
}
