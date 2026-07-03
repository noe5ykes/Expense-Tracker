import 'package:expense_tracker/features/bills/domain/bill.dart';
import 'package:expense_tracker/features/budgets/domain/budget.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BudgetProgress', () {
    const budget = Budget(id: 'b1', categoryId: 'food', amount: 1000);

    test('fraction / remaining', () {
      const progress = BudgetProgress(budget: budget, spent: 250);
      expect(progress.fraction, 0.25);
      expect(progress.remaining, 750);
      expect(progress.isExceeded, isFalse);
      expect(progress.isNearLimit, isFalse);
    });

    test('near-limit at 80%', () {
      const progress = BudgetProgress(budget: budget, spent: 800);
      expect(progress.isNearLimit, isTrue);
      expect(progress.isExceeded, isFalse);
    });

    test('exceeded past 100%', () {
      const progress = BudgetProgress(budget: budget, spent: 1200);
      expect(progress.isExceeded, isTrue);
      expect(progress.isNearLimit, isFalse);
      expect(progress.remaining, -200);
    });

    test('zero budget never divides by zero', () {
      const zero = Budget(id: 'b2', categoryId: null, amount: 0);
      expect(const BudgetProgress(budget: zero, spent: 10).fraction, 0);
    });
  });

  group('Bill.nextDueDate', () {
    final due = DateTime(2026, 7, 5);

    test('one-time bills have no next date', () {
      expect(
          Bill(id: '1', title: 'x', amount: 1, dueDate: due, recurrence: BillRecurrence.oneTime)
              .nextDueDate,
          isNull);
    });

    test('weekly adds 7 days', () {
      expect(
          Bill(id: '1', title: 'x', amount: 1, dueDate: due, recurrence: BillRecurrence.weekly)
              .nextDueDate,
          DateTime(2026, 7, 12));
    });

    test('monthly rolls the month (with year rollover)', () {
      expect(
          Bill(id: '1', title: 'x', amount: 1, dueDate: DateTime(2026, 12, 5))
              .nextDueDate,
          DateTime(2027, 1, 5));
    });

    test('yearly adds a year', () {
      expect(
          Bill(id: '1', title: 'x', amount: 1, dueDate: due, recurrence: BillRecurrence.yearly)
              .nextDueDate,
          DateTime(2027, 7, 5));
    });
  });
}
