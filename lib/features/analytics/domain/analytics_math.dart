import '../../../core/utils/date_ranges.dart';
import '../../expenses/domain/expense.dart';

/// Pure aggregation functions behind every chart — unit tested.
abstract final class AnalyticsMath {
  /// Total spent per category id (expenses only) within [start]..[end].
  static Map<String, double> categoryTotals(
    List<Expense> expenses, {
    DateTime? start,
    DateTime? end,
  }) {
    final totals = <String, double>{};
    for (final e in expenses) {
      if (e.type != TransactionType.expense) continue;
      if (start != null && e.date.isBefore(start)) continue;
      if (end != null && e.date.isAfter(end)) continue;
      totals[e.categoryId] = (totals[e.categoryId] ?? 0) + e.amount;
    }
    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return {for (final e in sorted) e.key: e.value};
  }

  /// Spending per day for [days] days ending at [end] (inclusive).
  /// Index 0 is the oldest day.
  static List<double> dailySeries(
      List<Expense> expenses, DateTime end, int days) {
    final endDay = DateRanges.startOfDay(end);
    final start = endDay.subtract(Duration(days: days - 1));
    final series = List<double>.filled(days, 0);
    for (final e in expenses) {
      if (e.type != TransactionType.expense) continue;
      final day = DateRanges.startOfDay(e.date);
      final index = day.difference(start).inDays;
      if (index >= 0 && index < days) series[index] += e.amount;
    }
    return series;
  }

  /// Spending per month for the 12 months of [year]. Index 0 = January.
  static List<double> monthlySeries(List<Expense> expenses, int year) {
    final series = List<double>.filled(12, 0);
    for (final e in expenses) {
      if (e.type != TransactionType.expense) continue;
      if (e.date.year != year) continue;
      series[e.date.month - 1] += e.amount;
    }
    return series;
  }

  /// (income, expense) pairs for the last [months] months ending at the month
  /// of [now]. Index 0 is the oldest month; the month key is returned too.
  static List<({DateTime month, double income, double expense})>
      incomeExpenseByMonth(List<Expense> expenses, DateTime now, int months) {
    final result = <({DateTime month, double income, double expense})>[];
    for (var i = months - 1; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i);
      var income = 0.0, spent = 0.0;
      for (final e in expenses) {
        if (!DateRanges.sameMonth(e.date, month)) continue;
        if (e.type == TransactionType.income) {
          income += e.amount;
        } else {
          spent += e.amount;
        }
      }
      result.add((month: month, income: income, expense: spent));
    }
    return result;
  }

  /// Map of day → spend for the last [days] days, for the heatmap.
  static Map<DateTime, double> heatmap(
      List<Expense> expenses, DateTime end, int days) {
    final endDay = DateRanges.startOfDay(end);
    final start = endDay.subtract(Duration(days: days - 1));
    final map = <DateTime, double>{};
    for (final e in expenses) {
      if (e.type != TransactionType.expense) continue;
      final day = DateRanges.startOfDay(e.date);
      if (day.isBefore(start) || day.isAfter(endDay)) continue;
      map[day] = (map[day] ?? 0) + e.amount;
    }
    return map;
  }

  static double sum(Iterable<double> values) =>
      values.fold(0.0, (a, b) => a + b);

  static double max(Iterable<double> values) =>
      values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b);
}
