import 'package:expense_tracker/features/analytics/domain/analytics_math.dart';
import 'package:expense_tracker/features/expenses/domain/expense.dart';
import 'package:flutter_test/flutter_test.dart';

Expense _expense(String id, double amount, DateTime date,
        {String categoryId = 'food',
        TransactionType type = TransactionType.expense}) =>
    Expense(
        id: id,
        title: id,
        amount: amount,
        categoryId: categoryId,
        date: date,
        type: type);

void main() {
  final now = DateTime(2026, 7, 2);

  group('AnalyticsMath', () {
    test('categoryTotals sums per category, sorted descending', () {
      final totals = AnalyticsMath.categoryTotals([
        _expense('1', 100, now),
        _expense('2', 50, now),
        _expense('3', 300, now, categoryId: 'fuel'),
        _expense('4', 999, now, categoryId: 'salary', type: TransactionType.income),
      ]);
      expect(totals, {'fuel': 300, 'food': 150});
      expect(totals.keys.first, 'fuel');
    });

    test('dailySeries places amounts on the right day', () {
      final series = AnalyticsMath.dailySeries([
        _expense('1', 100, DateTime(2026, 7, 2, 8)),
        _expense('2', 40, DateTime(2026, 7, 2, 21)),
        _expense('3', 70, DateTime(2026, 6, 26)),
        _expense('4', 999, DateTime(2026, 6, 25)), // out of window
      ], now, 7);
      expect(series.length, 7);
      expect(series.last, 140); // today
      expect(series.first, 70); // 6 days ago
      expect(AnalyticsMath.sum(series), 210);
    });

    test('monthlySeries only counts the given year', () {
      final series = AnalyticsMath.monthlySeries([
        _expense('1', 100, DateTime(2026, 1, 10)),
        _expense('2', 200, DateTime(2026, 12, 31)),
        _expense('3', 999, DateTime(2025, 6, 1)),
      ], 2026);
      expect(series[0], 100);
      expect(series[11], 200);
      expect(AnalyticsMath.sum(series), 300);
    });

    test('incomeExpenseByMonth returns oldest-first pairs', () {
      final data = AnalyticsMath.incomeExpenseByMonth([
        _expense('1', 500, DateTime(2026, 7, 1)),
        _expense('2', 65000, DateTime(2026, 7, 1),
            categoryId: 'salary', type: TransactionType.income),
        _expense('3', 900, DateTime(2026, 6, 15)),
      ], now, 3);
      expect(data.length, 3);
      expect(data.last.month, DateTime(2026, 7));
      expect(data.last.income, 65000);
      expect(data.last.expense, 500);
      expect(data[1].expense, 900);
      expect(data.first.expense, 0);
    });

    test('heatmap keys are day-aligned within the window', () {
      final map = AnalyticsMath.heatmap([
        _expense('1', 100, DateTime(2026, 7, 2, 13)),
        _expense('2', 50, DateTime(2026, 7, 2, 20)),
        _expense('3', 999, DateTime(2020, 1, 1)),
      ], now, 30);
      expect(map[DateTime(2026, 7, 2)], 150);
      expect(map.length, 1);
    });

    test('max of empty is 0', () {
      expect(AnalyticsMath.max(const []), 0);
    });
  });
}
