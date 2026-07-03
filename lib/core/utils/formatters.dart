import 'package:intl/intl.dart';

import '../constants/app_constants.dart';

/// Currency / date formatting helpers. Pure functions — unit tested.
abstract final class Formatters {
  static String currency(
    double amount, {
    String code = 'INR',
    String? locale,
    int decimalDigits = 0,
  }) {
    final format = NumberFormat.currency(
      locale: locale,
      symbol: AppConstants.currencySymbol(code),
      decimalDigits: amount == amount.roundToDouble() ? decimalDigits : 2,
    );
    return format.format(amount);
  }

  /// Compact form used on charts: ₹1.2K, ₹3.4L is avoided for simplicity.
  static String compactCurrency(double amount,
      {String code = 'INR', String? locale}) {
    final format = NumberFormat.compactCurrency(
      locale: locale,
      symbol: AppConstants.currencySymbol(code),
    );
    return format.format(amount);
  }

  static String date(DateTime date, {String? locale}) =>
      DateFormat.yMMMd(locale).format(date);

  static String dateShort(DateTime date, {String? locale}) =>
      DateFormat.MMMd(locale).format(date);

  static String time(DateTime date, {String? locale}) =>
      DateFormat.jm(locale).format(date);

  static String monthYear(DateTime date, {String? locale}) =>
      DateFormat.yMMMM(locale).format(date);

  static String weekdayShort(DateTime date, {String? locale}) =>
      DateFormat.E(locale).format(date);

  static String monthShort(DateTime date, {String? locale}) =>
      DateFormat.MMM(locale).format(date);

  static String percent(double fraction) =>
      '${(fraction * 100).clamp(0, 999).toStringAsFixed(0)}%';
}
