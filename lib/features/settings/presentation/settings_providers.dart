import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/providers/app_providers.dart';

/// User preferences persisted in SharedPreferences. Locale/theme changes are
/// applied live — no app restart required.
@immutable
class SettingsState {
  final ThemeMode themeMode;

  /// null → follow system locale.
  final Locale? locale;
  final String currencyCode;
  final bool dailyReminder;
  final TimeOfDay reminderTime;
  final bool budgetAlerts;
  final bool billReminders;
  final bool monthlySummary;
  final bool appLock;

  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.locale,
    this.currencyCode = 'INR',
    this.dailyReminder = false,
    this.reminderTime = const TimeOfDay(hour: 21, minute: 0),
    this.budgetAlerts = true,
    this.billReminders = true,
    this.monthlySummary = true,
    this.appLock = false,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    Locale? Function()? locale,
    String? currencyCode,
    bool? dailyReminder,
    TimeOfDay? reminderTime,
    bool? budgetAlerts,
    bool? billReminders,
    bool? monthlySummary,
    bool? appLock,
  }) =>
      SettingsState(
        themeMode: themeMode ?? this.themeMode,
        locale: locale != null ? locale() : this.locale,
        currencyCode: currencyCode ?? this.currencyCode,
        dailyReminder: dailyReminder ?? this.dailyReminder,
        reminderTime: reminderTime ?? this.reminderTime,
        budgetAlerts: budgetAlerts ?? this.budgetAlerts,
        billReminders: billReminders ?? this.billReminders,
        monthlySummary: monthlySummary ?? this.monthlySummary,
        appLock: appLock ?? this.appLock,
      );
}

class SettingsNotifier extends Notifier<SettingsState> {
  static const _kTheme = 'settings.theme';
  static const _kLocale = 'settings.locale';
  static const _kCurrency = 'settings.currency';
  static const _kDailyReminder = 'settings.dailyReminder';
  static const _kReminderHour = 'settings.reminderHour';
  static const _kReminderMinute = 'settings.reminderMinute';
  static const _kBudgetAlerts = 'settings.budgetAlerts';
  static const _kBillReminders = 'settings.billReminders';
  static const _kMonthlySummary = 'settings.monthlySummary';
  static const _kAppLock = 'settings.appLock';

  @override
  SettingsState build() {
    final prefs = ref.watch(sharedPrefsProvider);
    final localeCode = prefs.getString(_kLocale);
    return SettingsState(
      themeMode: ThemeMode.values[prefs.getInt(_kTheme) ?? 0],
      locale: localeCode == null ? null : Locale(localeCode),
      currencyCode: prefs.getString(_kCurrency) ?? 'INR',
      dailyReminder: prefs.getBool(_kDailyReminder) ?? false,
      reminderTime: TimeOfDay(
        hour: prefs.getInt(_kReminderHour) ?? 21,
        minute: prefs.getInt(_kReminderMinute) ?? 0,
      ),
      budgetAlerts: prefs.getBool(_kBudgetAlerts) ?? true,
      billReminders: prefs.getBool(_kBillReminders) ?? true,
      monthlySummary: prefs.getBool(_kMonthlySummary) ?? true,
      appLock: prefs.getBool(_kAppLock) ?? false,
    );
  }

  SharedPreferences get _prefs => ref.read(sharedPrefsProvider);

  void setThemeMode(ThemeMode mode) {
    _prefs.setInt(_kTheme, mode.index);
    state = state.copyWith(themeMode: mode);
  }

  void setLocale(Locale? locale) {
    if (locale == null) {
      _prefs.remove(_kLocale);
    } else {
      _prefs.setString(_kLocale, locale.languageCode);
    }
    state = state.copyWith(locale: () => locale);
  }

  void setCurrency(String code) {
    _prefs.setString(_kCurrency, code);
    state = state.copyWith(currencyCode: code);
  }

  void setDailyReminder(bool enabled) {
    _prefs.setBool(_kDailyReminder, enabled);
    state = state.copyWith(dailyReminder: enabled);
  }

  void setReminderTime(TimeOfDay time) {
    _prefs.setInt(_kReminderHour, time.hour);
    _prefs.setInt(_kReminderMinute, time.minute);
    state = state.copyWith(reminderTime: time);
  }

  void setBudgetAlerts(bool enabled) {
    _prefs.setBool(_kBudgetAlerts, enabled);
    state = state.copyWith(budgetAlerts: enabled);
  }

  void setBillReminders(bool enabled) {
    _prefs.setBool(_kBillReminders, enabled);
    state = state.copyWith(billReminders: enabled);
  }

  void setMonthlySummary(bool enabled) {
    _prefs.setBool(_kMonthlySummary, enabled);
    state = state.copyWith(monthlySummary: enabled);
  }

  void setAppLock(bool enabled) {
    _prefs.setBool(_kAppLock, enabled);
    state = state.copyWith(appLock: enabled);
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);
