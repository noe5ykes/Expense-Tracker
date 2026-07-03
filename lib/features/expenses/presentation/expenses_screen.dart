import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/utils/adaptive.dart';
import '../../../core/utils/date_ranges.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/utils/display.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/expense_tile.dart';
import '../../../shared/widgets/shimmer.dart';
import '../domain/expense.dart';
import '../domain/expense_filter.dart';
import 'expense_providers.dart';
import 'filter_sheet.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _delete(Expense expense) async {
    final l10n = context.l10n;
    await ref.read(expenseRepositoryProvider).delete(expense.id);
    if (mounted) showAppSnackBar(context, l10n.expenseDeleted);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final asyncExpenses = ref.watch(allExpensesProvider);
    final filter = ref.watch(expenseFilterProvider);
    final filtered = ref.watch(filteredExpensesProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'expenses-fab',
        onPressed: () => context.push('/expense-form'),
        child: const Icon(Icons.add_rounded),
      ),
      appBar: AppBar(title: Text(l10n.expenses)),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
              child: TextField(
                controller: _searchController,
                onChanged:
                    ref.read(expenseFilterProvider.notifier).setQuery,
                decoration: InputDecoration(
                  hintText: l10n.searchExpenses,
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: filter.query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            _searchController.clear();
                            ref
                                .read(expenseFilterProvider.notifier)
                                .setQuery('');
                          },
                        ),
                ),
              ),
            ),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _FilterButton(active: filter.isActive),
                  const SizedBox(width: 8),
                  for (final time in const [
                    TimeFilter.all,
                    TimeFilter.today,
                    TimeFilter.week,
                    TimeFilter.month,
                    TimeFilter.year,
                  ]) ...[
                    ChoiceChip(
                      label: Text(timeFilterLabel(context, time)),
                      selected: filter.timeFilter == time,
                      onSelected: (_) {
                        selectionHaptic();
                        ref
                            .read(expenseFilterProvider.notifier)
                            .setTimeFilter(time);
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                  _SortMenu(current: filter.sort),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: asyncExpenses.when(
                loading: () => const ListShimmer(),
                error: (e, _) => EmptyState(
                    icon: Icons.error_outline_rounded,
                    title: l10n.somethingWentWrong),
                data: (_) {
                  if (filtered.isEmpty) {
                    return EmptyState(
                      icon: Icons.search_off_rounded,
                      title: l10n.noExpensesFound,
                    );
                  }
                  final items = _groupByDay(context, filtered);
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 96),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      if (item is String) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
                          child: Text(
                            item,
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w700),
                          ),
                        );
                      }
                      final expense = item as Expense;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Dismissible(
                          key: ValueKey(expense.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: AlignmentDirectional.centerEnd,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            decoration: BoxDecoration(
                              color: scheme.errorContainer,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Icon(Icons.delete_rounded,
                                color: scheme.onErrorContainer),
                          ),
                          confirmDismiss: (_) => showConfirmDialog(
                            context,
                            title: l10n.deleteExpense,
                            message: l10n.deleteExpenseConfirm,
                            confirmLabel: l10n.delete,
                            cancelLabel: l10n.cancel,
                            destructive: true,
                          ),
                          onDismissed: (_) => _delete(expense),
                          child: ExpenseTile(expense: expense),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Flattens expenses into [String] date headers followed by their rows.
  List<Object> _groupByDay(BuildContext context, List<Expense> expenses) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final now = DateTime.now();
    final items = <Object>[];
    DateTime? currentDay;
    for (final expense in expenses) {
      final day = DateRanges.startOfDay(expense.date);
      if (currentDay == null || day != currentDay) {
        currentDay = day;
        final String label;
        if (DateRanges.sameDay(day, now)) {
          label = l10n.today;
        } else if (DateRanges.sameDay(
            day, now.subtract(const Duration(days: 1)))) {
          label = l10n.yesterday;
        } else {
          label = Formatters.date(day, locale: locale);
        }
        items.add(label);
      }
      items.add(expense);
    }
    return items;
  }
}

class _FilterButton extends ConsumerWidget {
  final bool active;
  const _FilterButton({required this.active});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return Badge(
      isLabelVisible: active,
      backgroundColor: scheme.primary,
      child: ActionChip(
        avatar: Icon(Icons.tune_rounded, size: 18, color: scheme.primary),
        label: Text(context.l10n.filters),
        onPressed: () => showFilterSheet(context),
      ),
    );
  }
}

class _SortMenu extends ConsumerWidget {
  final SortOrder current;
  const _SortMenu({required this.current});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return PopupMenuButton<SortOrder>(
      initialValue: current,
      onSelected: ref.read(expenseFilterProvider.notifier).setSort,
      itemBuilder: (context) => [
        for (final sort in SortOrder.values)
          PopupMenuItem(
            value: sort,
            child: Text(sortOrderLabel(context, sort)),
          ),
      ],
      child: Chip(
        avatar: Icon(Icons.swap_vert_rounded, size: 18, color: scheme.primary),
        label: Text(sortOrderLabel(context, current)),
      ),
    );
  }
}
