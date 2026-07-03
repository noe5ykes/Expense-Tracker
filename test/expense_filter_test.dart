import 'package:expense_tracker/features/expenses/domain/expense.dart';
import 'package:expense_tracker/features/expenses/domain/expense_filter.dart';
import 'package:flutter_test/flutter_test.dart';

Expense _expense(
  String id, {
  String title = 'Item',
  double amount = 100,
  String categoryId = 'food',
  DateTime? date,
  List<String> tags = const [],
  TransactionType type = TransactionType.expense,
  String notes = '',
}) =>
    Expense(
      id: id,
      title: title,
      amount: amount,
      categoryId: categoryId,
      date: date ?? DateTime(2026, 7, 1),
      tags: tags,
      type: type,
      notes: notes,
    );

void main() {
  final now = DateTime(2026, 7, 2, 12); // Thursday
  final all = [
    _expense('1', title: 'Coffee', amount: 120, date: DateTime(2026, 7, 2, 9)),
    _expense('2',
        title: 'Groceries',
        categoryId: 'grocery',
        amount: 900,
        date: DateTime(2026, 7, 1),
        tags: ['family']),
    _expense('3',
        title: 'Old dinner', amount: 450, date: DateTime(2026, 5, 20)),
    _expense('4',
        title: 'Salary',
        categoryId: 'salary',
        amount: 65000,
        type: TransactionType.income,
        date: DateTime(2026, 7, 1, 9)),
    _expense('5',
        title: 'Movie',
        categoryId: 'entertainment',
        amount: 600,
        date: DateTime(2026, 6, 29),
        notes: 'weekend plan'),
  ];

  group('applyExpenseFilter', () {
    test('no filter returns everything sorted latest first', () {
      final result = applyExpenseFilter(all, const ExpenseFilter(), now: now);
      expect(result.length, 5);
      expect(result.first.id, '1');
    });

    test('query matches title, notes and amount', () {
      expect(
          applyExpenseFilter(all, const ExpenseFilter(query: 'coffee'),
                  now: now)
              .single
              .id,
          '1');
      expect(
          applyExpenseFilter(all, const ExpenseFilter(query: 'weekend'),
                  now: now)
              .single
              .id,
          '5');
      expect(
          applyExpenseFilter(all, const ExpenseFilter(query: '900'), now: now)
              .single
              .id,
          '2');
    });

    test('#tag query searches tags only', () {
      final result = applyExpenseFilter(
          all, const ExpenseFilter(query: '#family'),
          now: now);
      expect(result.single.id, '2');
    });

    test('today filter', () {
      final result = applyExpenseFilter(
          all, const ExpenseFilter(timeFilter: TimeFilter.today),
          now: now);
      expect(result.single.id, '1');
    });

    test('week filter starts Monday', () {
      final result = applyExpenseFilter(
          all, const ExpenseFilter(timeFilter: TimeFilter.week),
          now: now);
      // Week of Mon 29 Jun – includes 29/6, 1/7, 2/7 entries.
      expect(result.map((e) => e.id).toSet(), {'1', '2', '4', '5'});
    });

    test('month filter excludes other months', () {
      final result = applyExpenseFilter(
          all, const ExpenseFilter(timeFilter: TimeFilter.month),
          now: now);
      expect(result.any((e) => e.id == '3'), isFalse);
      expect(result.any((e) => e.id == '5'), isFalse);
    });

    test('custom range is inclusive', () {
      final result = applyExpenseFilter(
        all,
        ExpenseFilter(
          timeFilter: TimeFilter.custom,
          customStart: DateTime(2026, 6, 29),
          customEnd: DateTime(2026, 7, 1),
        ),
        now: now,
      );
      expect(result.map((e) => e.id).toSet(), {'2', '4', '5'});
    });

    test('category and amount filters combine', () {
      final result = applyExpenseFilter(
        all,
        const ExpenseFilter(
          categoryIds: {'food', 'grocery'},
          minAmount: 200,
          maxAmount: 1000,
        ),
        now: now,
      );
      expect(result.map((e) => e.id).toSet(), {'2', '3'});
    });

    test('type filter isolates income', () {
      final result = applyExpenseFilter(
          all, const ExpenseFilter(type: TransactionType.income),
          now: now);
      expect(result.single.id, '4');
    });

    test('sorting by amount', () {
      final highest = applyExpenseFilter(
          all, const ExpenseFilter(sort: SortOrder.highestAmount),
          now: now);
      expect(highest.first.id, '4');
      final lowest = applyExpenseFilter(
          all, const ExpenseFilter(sort: SortOrder.lowestAmount),
          now: now);
      expect(lowest.first.id, '1');
    });

    test('isActive reflects non-default criteria', () {
      expect(const ExpenseFilter().isActive, isFalse);
      expect(const ExpenseFilter(query: 'x').isActive, isFalse);
      expect(const ExpenseFilter(minAmount: 1).isActive, isTrue);
      expect(
          const ExpenseFilter(timeFilter: TimeFilter.week).isActive, isTrue);
    });
  });
}
