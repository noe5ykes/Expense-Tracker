/// Date-range helpers used by filters, analytics and budgets. Pure Dart —
/// unit tested.
abstract final class DateRanges {
  static DateTime startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime endOfDay(DateTime d) =>
      DateTime(d.year, d.month, d.day, 23, 59, 59, 999);

  /// Week starts on Monday.
  static DateTime startOfWeek(DateTime d) =>
      startOfDay(d).subtract(Duration(days: d.weekday - 1));

  static DateTime startOfMonth(DateTime d) => DateTime(d.year, d.month);

  static DateTime endOfMonth(DateTime d) =>
      DateTime(d.year, d.month + 1).subtract(const Duration(milliseconds: 1));

  static DateTime startOfYear(DateTime d) => DateTime(d.year);

  static DateTime endOfYear(DateTime d) =>
      DateTime(d.year + 1).subtract(const Duration(milliseconds: 1));

  static bool sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool sameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;

  static int daysInMonth(DateTime d) => DateTime(d.year, d.month + 1, 0).day;
}
