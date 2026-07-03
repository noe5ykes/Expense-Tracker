import 'dart:convert';

import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/services/backup_service.dart';
import 'package:expense_tracker/features/bills/data/drift_bill_repository.dart';
import 'package:expense_tracker/features/bills/domain/bill.dart';
import 'package:expense_tracker/features/budgets/data/drift_budget_repository.dart';
import 'package:expense_tracker/features/budgets/domain/budget.dart';
import 'package:expense_tracker/features/expenses/data/drift_category_repository.dart';
import 'package:expense_tracker/features/expenses/data/drift_expense_repository.dart';
import 'package:expense_tracker/features/expenses/domain/category.dart';
import 'package:expense_tracker/features/expenses/domain/expense.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DriftExpenseRepository expenses;
  late DriftCategoryRepository categories;
  late DriftBudgetRepository budgets;
  late DriftBillRepository bills;

  setUp(() {
    db = AppDatabase(DatabaseConnection(NativeDatabase.memory()));
    expenses = DriftExpenseRepository(db);
    categories = DriftCategoryRepository(db);
    budgets = DriftBudgetRepository(db);
    bills = DriftBillRepository(db);
  });

  tearDown(() => db.close());

  Expense expense(String id, {String categoryId = 'food'}) => Expense(
        id: id,
        title: 'Lunch',
        amount: 250,
        categoryId: categoryId,
        date: DateTime(2026, 7, 2, 13),
        tags: const ['office', 'lunch'],
        receiptPaths: const ['/tmp/receipt.jpg'],
        notes: 'Team lunch',
        location: 'MG Road',
      );

  group('seeding', () {
    test('default categories exist on create', () async {
      final all = await categories.getAll();
      expect(all.length, 13);
      expect(all.any((c) => c.id == 'other'), isTrue);
      expect(all.where((c) => c.isIncome).length, 2);
    });
  });

  group('ExpenseRepository', () {
    test('add / getAll roundtrips every field', () async {
      await expenses.add(expense('e1'));
      final loaded = (await expenses.getAll()).single;
      expect(loaded, expense('e1'));
    });

    test('update replaces the row', () async {
      await expenses.add(expense('e1'));
      await expenses.update(expense('e1').copyWith(amount: 999));
      expect((await expenses.getAll()).single.amount, 999);
    });

    test('delete removes only the target', () async {
      await expenses.add(expense('e1'));
      await expenses.add(expense('e2'));
      await expenses.delete('e1');
      expect((await expenses.getAll()).single.id, 'e2');
    });

    test('watchAll emits on change', () async {
      final emissions = expenses.watchAll().take(2).toList();
      await expenses.add(expense('e1'));
      final lists = await emissions;
      expect(lists.last.length, 1);
    });

    test('restoreAll wipes and reloads', () async {
      await expenses.add(expense('old'));
      await expenses.restoreAll([expense('new1'), expense('new2')]);
      final all = await expenses.getAll();
      expect(all.map((e) => e.id).toSet(), {'new1', 'new2'});
    });
  });

  group('CategoryRepository', () {
    test('deleting a category reassigns expenses to "other"', () async {
      await expenses.add(expense('e1', categoryId: 'food'));
      await categories.delete('food');
      expect((await expenses.getAll()).single.categoryId, 'other');
      expect((await categories.getAll()).any((c) => c.id == 'food'), isFalse);
    });

    test('add and update custom category', () async {
      const custom = Category(
          id: 'custom1', name: 'Pets', icon: 'pets', color: 0xFF112233);
      await categories.add(custom);
      await categories.update(custom.copyWith(name: 'Pet care'));
      final loaded =
          (await categories.getAll()).firstWhere((c) => c.id == 'custom1');
      expect(loaded.name, 'Pet care');
      expect(loaded.isDefault, isFalse);
    });
  });

  group('BudgetRepository', () {
    test('upsert inserts then updates by id', () async {
      const budget = Budget(id: 'b1', categoryId: 'food', amount: 5000);
      await budgets.upsert(budget);
      await budgets.upsert(budget.copyWith(amount: 8000));
      expect((await budgets.getAll()).single.amount, 8000);
    });

    test('overall budget stores null category', () async {
      await budgets.upsert(const Budget(id: 'b1', amount: 40000));
      expect((await budgets.getAll()).single.categoryId, isNull);
    });
  });

  group('BillRepository', () {
    test('markPaid rolls recurring bills forward, unpaid', () async {
      final bill = Bill(
          id: 'bill1',
          title: 'Rent',
          amount: 18000,
          dueDate: DateTime(2026, 7, 5));
      await bills.add(bill);
      await bills.markPaid(bill);
      final rolled = (await bills.getAll()).single;
      expect(rolled.dueDate, DateTime(2026, 8, 5));
      expect(rolled.paid, isFalse);
    });

    test('markPaid finishes one-time bills', () async {
      final bill = Bill(
          id: 'bill1',
          title: 'Deposit',
          amount: 100,
          dueDate: DateTime(2026, 7, 5),
          recurrence: BillRecurrence.oneTime);
      await bills.add(bill);
      await bills.markPaid(bill);
      expect((await bills.getAll()).single.paid, isTrue);
    });
  });

  group('BackupService', () {
    test('backup → restore roundtrip preserves all entities', () async {
      await expenses.add(expense('e1'));
      await budgets.upsert(const Budget(id: 'b1', amount: 40000));
      await bills.add(Bill(
          id: 'bill1',
          title: 'Rent',
          amount: 18000,
          dueDate: DateTime(2026, 7, 5)));

      final service = BackupService(
        expenses: expenses,
        categories: categories,
        budgets: budgets,
        bills: bills,
      );
      final backup = await service.buildBackup();

      // Restore into a fresh database.
      final db2 = AppDatabase(DatabaseConnection(NativeDatabase.memory()));
      addTearDown(db2.close);
      final service2 = BackupService(
        expenses: DriftExpenseRepository(db2),
        categories: DriftCategoryRepository(db2),
        budgets: DriftBudgetRepository(db2),
        bills: DriftBillRepository(db2),
      );
      // Re-encode via JSON string to exercise the full path.
      await service2.restoreFromJson(jsonEncode(backup));

      expect((await DriftExpenseRepository(db2).getAll()).single.id, 'e1');
      expect((await DriftBudgetRepository(db2).getAll()).single.amount, 40000);
      expect((await DriftBillRepository(db2).getAll()).single.title, 'Rent');
      expect((await DriftCategoryRepository(db2).getAll()).length, 13);
    });

    test('restore rejects invalid payloads', () async {
      final service = BackupService(
        expenses: expenses,
        categories: categories,
        budgets: budgets,
        bills: bills,
      );
      expect(() => service.restoreFromJson('{"foo": 1}'),
          throwsFormatException);
    });
  });
}
