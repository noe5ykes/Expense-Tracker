import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/utils/date_ranges.dart';
import '../../../shared/providers/app_providers.dart';
import '../../settings/presentation/settings_providers.dart';
import '../domain/expense.dart';
import '../domain/expense_filter.dart';

class ExpenseFilterNotifier extends Notifier<ExpenseFilter> {
  @override
  ExpenseFilter build() => const ExpenseFilter();

  void setQuery(String query) => state = state.copyWith(query: query);

  void setTimeFilter(TimeFilter filter, {DateTime? start, DateTime? end}) =>
      state = state.copyWith(
          timeFilter: filter, customStart: start, customEnd: end);

  void setSort(SortOrder sort) => state = state.copyWith(sort: sort);

  void toggleCategory(String categoryId) {
    final ids = {...state.categoryIds};
    ids.contains(categoryId) ? ids.remove(categoryId) : ids.add(categoryId);
    state = state.copyWith(categoryIds: ids);
  }

  void setAmountRange(double? min, double? max) =>
      state = state.copyWith(minAmount: min, maxAmount: max);

  void setType(TransactionType? type) => state = state.copyWith(type: type);

  void reset() => state = ExpenseFilter(query: state.query);
}

final expenseFilterProvider =
    NotifierProvider<ExpenseFilterNotifier, ExpenseFilter>(
        ExpenseFilterNotifier.new);

final filteredExpensesProvider = Provider<List<Expense>>((ref) {
  final all = ref.watch(allExpensesProvider).value ?? const <Expense>[];
  final filter = ref.watch(expenseFilterProvider);
  return applyExpenseFilter(all, filter);
});

/// Persists [expense] and fires budget notifications when the save pushes a
/// category (or the overall) budget past 80% / 100%.
Future<void> saveExpense(
  WidgetRef ref,
  Expense expense, {
  Expense? previous,
  required AppLocalizations l10n,
  required String Function(String categoryId) categoryLabel,
}) async {
  final repo = ref.read(expenseRepositoryProvider);
  final settings = ref.read(settingsProvider);

  // Snapshot spend before the mutation to detect threshold crossings.
  final before = await repo.getAll();
  if (previous == null) {
    await repo.add(expense);
  } else {
    await repo.update(expense);
  }

  if (!settings.budgetAlerts || expense.type != TransactionType.expense) {
    return;
  }

  final now = DateTime.now();
  double spentBefore(String? categoryId) => before
      .where((e) =>
          e.type == TransactionType.expense &&
          DateRanges.sameMonth(e.date, now) &&
          (categoryId == null || e.categoryId == categoryId) &&
          e.id != expense.id)
      .fold(0.0, (sum, e) => sum + e.amount);

  final budgets = await ref.read(budgetRepositoryProvider).getAll();
  for (final budget in budgets) {
    if (budget.categoryId != null && budget.categoryId != expense.categoryId) {
      continue;
    }
    if (budget.amount <= 0) continue;
    final wasSpent = spentBefore(budget.categoryId);
    final nowSpent = wasSpent + expense.amount;
    final label = budget.categoryId == null
        ? l10n.monthlyBudget
        : categoryLabel(budget.categoryId!);
    if (wasSpent <= budget.amount && nowSpent > budget.amount) {
      await NotificationService.instance.showBudgetAlert(
        title: l10n.budgetExceededTitle,
        body: l10n.budgetExceededBody(label),
      );
    } else if (wasSpent < budget.amount * 0.8 &&
        nowSpent >= budget.amount * 0.8 &&
        nowSpent <= budget.amount) {
      await NotificationService.instance.showBudgetAlert(
        title: l10n.budgetAlertTitle,
        body: l10n.budgetNearLimitBody(
            ((nowSpent / budget.amount) * 100).toStringAsFixed(0), label),
      );
    }
  }
}
