import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../di/providers.dart';

class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ref.watch(bootstrapThemeModeProvider);

  Future<void> set(ThemeMode mode) async {
    if (state == mode) return;
    state = mode;
    await ref.read(settingsDaoProvider).setPreference('themeMode', mode.name);
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);

class LocaleController extends Notifier<Locale?> {
  @override
  Locale? build() => ref.watch(bootstrapLocaleProvider);

  Future<void> set(Locale locale) async {
    if (state == locale) return;
    state = locale;
    await ref
        .read(settingsDaoProvider)
        .setPreference('locale', locale.languageCode);
  }
}

final localeProvider =
    NotifierProvider<LocaleController, Locale?>(LocaleController.new);
