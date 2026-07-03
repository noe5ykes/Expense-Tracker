import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/database/app_database.dart';
import '../../core/utils/date_ranges.dart';
import '../../features/bills/data/drift_bill_repository.dart';
import '../../features/bills/domain/bill.dart';
import '../../features/bills/domain/bill_repository.dart';
import '../../features/budgets/data/drift_budget_repository.dart';
import '../../features/budgets/domain/budget.dart';
import '../../features/budgets/domain/budget_repository.dart';
import '../../features/expenses/data/drift_category_repository.dart';
import '../../features/expenses/data/drift_expense_repository.dart';
import '../../features/expenses/domain/category.dart';
import '../../features/expenses/domain/category_repository.dart';
import '../../features/expenses/domain/expense.dart';
import '../../features/expenses/domain/expense_repository.dart';

/// Overridden in main() with the opened database / prefs instance.
final databaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('Overridden in main'),
);

final sharedPrefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Overridden in main'),
);

// ---------------------------------------------------------------------------
// Repositories
// ---------------------------------------------------------------------------

final expenseRepositoryProvider = Provider<ExpenseRepository>(
  (ref) => DriftExpenseRepository(ref.watch(databaseProvider)),
);

final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => DriftCategoryRepository(ref.watch(databaseProvider)),
);

final budgetRepositoryProvider = Provider<BudgetRepository>(
  (ref) => DriftBudgetRepository(ref.watch(databaseProvider)),
);

final billRepositoryProvider = Provider<BillRepository>(
  (ref) => DriftBillRepository(ref.watch(databaseProvider)),
);

// ---------------------------------------------------------------------------
// Live data streams
// ---------------------------------------------------------------------------

final allExpensesProvider = StreamProvider<List<Expense>>(
  (ref) => ref.watch(expenseRepositoryProvider).watchAll(),
);

final categoriesProvider = StreamProvider<List<Category>>(
  (ref) => ref.watch(categoryRepositoryProvider).watchAll(),
);

final categoriesByIdProvider = Provider<Map<String, Category>>((ref) {
  final categories = ref.watch(categoriesProvider).value ?? const <Category>[];
  return {for (final c in categories) c.id: c};
});

final budgetsProvider = StreamProvider<List<Budget>>(
  (ref) => ref.watch(budgetRepositoryProvider).watchAll(),
);

final billsProvider = StreamProvider<List<Bill>>(
  (ref) => ref.watch(billRepositoryProvider).watchAll(),
);

final upcomingBillsProvider = Provider<List<Bill>>((ref) {
  final bills = ref.watch(billsProvider).value ?? const <Bill>[];
  return bills.where((b) => !b.paid).toList()
    ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
});

// ---------------------------------------------------------------------------
// Derived dashboard / budget stats
// ---------------------------------------------------------------------------

class DashboardStats {
  final double totalBalance;
  final double todaySpend;
  final double monthSpend;
  final double monthIncome;
  const DashboardStats({
    required this.totalBalance,
    required this.todaySpend,
    required this.monthSpend,
    required this.monthIncome,
  });

  double get monthSavings => monthIncome - monthSpend;
  double get savingsRate =>
      monthIncome <= 0 ? 0 : (monthSavings / monthIncome).clamp(0, 1);
}

DashboardStats computeDashboardStats(List<Expense> expenses, DateTime now) {
  var balance = 0.0, today = 0.0, monthSpend = 0.0, monthIncome = 0.0;
  for (final e in expenses) {
    final signed = e.type == TransactionType.income ? e.amount : -e.amount;
    balance += signed;
    if (e.type == TransactionType.expense) {
      if (DateRanges.sameDay(e.date, now)) today += e.amount;
      if (DateRanges.sameMonth(e.date, now)) monthSpend += e.amount;
    } else if (DateRanges.sameMonth(e.date, now)) {
      monthIncome += e.amount;
    }
  }
  return DashboardStats(
    totalBalance: balance,
    todaySpend: today,
    monthSpend: monthSpend,
    monthIncome: monthIncome,
  );
}

final dashboardStatsProvider = Provider<DashboardStats>((ref) {
  final expenses = ref.watch(allExpensesProvider).value ?? const <Expense>[];
  return computeDashboardStats(expenses, DateTime.now());
});

/// Spend per category for the current month (expenses only).
final monthCategorySpendProvider = Provider<Map<String, double>>((ref) {
  final expenses = ref.watch(allExpensesProvider).value ?? const <Expense>[];
  final now = DateTime.now();
  final map = <String, double>{};
  for (final e in expenses) {
    if (e.type != TransactionType.expense) continue;
    if (!DateRanges.sameMonth(e.date, now)) continue;
    map[e.categoryId] = (map[e.categoryId] ?? 0) + e.amount;
  }
  return map;
});

/// Budget progress for every configured budget (overall budget first).
final budgetProgressProvider = Provider<List<BudgetProgress>>((ref) {
  final budgets = ref.watch(budgetsProvider).value ?? const <Budget>[];
  final categorySpend = ref.watch(monthCategorySpendProvider);
  final stats = ref.watch(dashboardStatsProvider);
  final progress = budgets
      .map((b) => BudgetProgress(
            budget: b,
            spent: b.categoryId == null
                ? stats.monthSpend
                : categorySpend[b.categoryId] ?? 0,
          ))
      .toList()
    ..sort((a, b) {
      if (a.budget.categoryId == null) return -1;
      if (b.budget.categoryId == null) return 1;
      return b.fraction.compareTo(a.fraction);
    });
  return progress;
});

final overallBudgetProgressProvider = Provider<BudgetProgress?>((ref) {
  final all = ref.watch(budgetProgressProvider);
  for (final p in all) {
    if (p.budget.categoryId == null) return p;
  }
  return null;
});
