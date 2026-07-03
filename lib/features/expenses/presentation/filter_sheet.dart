import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/utils/adaptive.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/utils/display.dart';
import '../domain/expense.dart';
import '../domain/expense_filter.dart';
import 'expense_providers.dart';

Future<void> showFilterSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const _FilterSheet(),
  );
}

class _FilterSheet extends ConsumerStatefulWidget {
  const _FilterSheet();

  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  late final TextEditingController _minController;
  late final TextEditingController _maxController;

  @override
  void initState() {
    super.initState();
    final filter = ref.read(expenseFilterProvider);
    _minController = TextEditingController(
        text: filter.minAmount?.toStringAsFixed(0) ?? '');
    _maxController = TextEditingController(
        text: filter.maxAmount?.toStringAsFixed(0) ?? '');
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  Future<void> _pickCustomRange() async {
    final filter = ref.read(expenseFilterProvider);
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2015),
      lastDate: now,
      initialDateRange: filter.customStart != null && filter.customEnd != null
          ? DateTimeRange(start: filter.customStart!, end: filter.customEnd!)
          : null,
    );
    if (range != null) {
      ref.read(expenseFilterProvider.notifier).setTimeFilter(
          TimeFilter.custom,
          start: range.start,
          end: range.end);
    }
  }

  void _applyAmounts() {
    ref.read(expenseFilterProvider.notifier).setAmountRange(
          double.tryParse(_minController.text),
          double.tryParse(_maxController.text),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final filter = ref.watch(expenseFilterProvider);
    final categories = ref.watch(categoriesProvider).value ?? [];
    final scheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toString();

    Widget sectionTitle(String text) => Padding(
          padding: const EdgeInsets.only(top: 18, bottom: 10),
          child: Text(text,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w800)),
        );

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      builder: (context, scrollController) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.filters,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800)),
              TextButton(
                onPressed: () {
                  ref.read(expenseFilterProvider.notifier).reset();
                  _minController.clear();
                  _maxController.clear();
                },
                child: Text(l10n.reset),
              ),
            ],
          ),
          sectionTitle(l10n.transactionType),
          SegmentedButton<TransactionType?>(
            segments: [
              ButtonSegment(value: null, label: Text(l10n.all)),
              ButtonSegment(
                  value: TransactionType.expense, label: Text(l10n.expense)),
              ButtonSegment(
                  value: TransactionType.income, label: Text(l10n.income)),
            ],
            selected: {filter.type},
            onSelectionChanged: (selection) => ref
                .read(expenseFilterProvider.notifier)
                .setType(selection.first),
          ),
          sectionTitle(l10n.date),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final time in TimeFilter.values)
                ChoiceChip(
                  label: Text(time == TimeFilter.custom &&
                          filter.timeFilter == TimeFilter.custom &&
                          filter.customStart != null
                      ? '${Formatters.dateShort(filter.customStart!, locale: locale)} – ${Formatters.dateShort(filter.customEnd ?? filter.customStart!, locale: locale)}'
                      : timeFilterLabel(context, time)),
                  selected: filter.timeFilter == time,
                  onSelected: (_) {
                    if (time == TimeFilter.custom) {
                      _pickCustomRange();
                    } else {
                      ref
                          .read(expenseFilterProvider.notifier)
                          .setTimeFilter(time);
                    }
                  },
                ),
            ],
          ),
          sectionTitle(l10n.category),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final category in categories)
                FilterChip(
                  avatar: filter.categoryIds.contains(category.id)
                      ? null
                      : Icon(Icons.circle,
                          size: 12, color: Color(category.color)),
                  label: Text(categoryName(context, category)),
                  selected: filter.categoryIds.contains(category.id),
                  onSelected: (_) => ref
                      .read(expenseFilterProvider.notifier)
                      .toggleCategory(category.id),
                ),
            ],
          ),
          sectionTitle(l10n.amountRange),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l10n.minAmount),
                  onChanged: (_) => _applyAmounts(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('–',
                    style: TextStyle(color: scheme.onSurfaceVariant)),
              ),
              Expanded(
                child: TextField(
                  controller: _maxController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l10n.maxAmount),
                  onChanged: (_) => _applyAmounts(),
                ),
              ),
            ],
          ),
          sectionTitle(l10n.sortBy),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final sort in SortOrder.values)
                ChoiceChip(
                  label: Text(sortOrderLabel(context, sort)),
                  selected: filter.sort == sort,
                  onSelected: (_) =>
                      ref.read(expenseFilterProvider.notifier).setSort(sort),
                ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              selectionHaptic();
              Navigator.of(context).pop();
            },
            child: Text(l10n.apply),
          ),
        ],
      ),
    );
  }
}
