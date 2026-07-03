import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/utils/adaptive.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/utils/display.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/category_avatar.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/shimmer.dart';
import '../../settings/presentation/settings_providers.dart';
import '../domain/budget.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final budgetsAsync = ref.watch(budgetsProvider);
    final progress = ref.watch(budgetProgressProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.budgets)),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'budgets-fab',
        onPressed: () => _showForm(context, ref, null),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.addBudget),
      ),
      body: SafeArea(
        child: budgetsAsync.when(
          loading: () => const ListShimmer(),
          error: (e, _) => EmptyState(
              icon: Icons.error_outline_rounded,
              title: l10n.somethingWentWrong),
          data: (budgets) {
            if (budgets.isEmpty) {
              return EmptyState(
                icon: Icons.account_balance_wallet_rounded,
                title: l10n.noBudgets,
                subtitle: l10n.setBudgetHint,
                action: FilledButton.icon(
                  onPressed: () => _showForm(context, ref, null),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l10n.addBudget),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
              itemCount: progress.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _BudgetCard(progress: progress[index]),
            );
          },
        ),
      ),
    );
  }

  static void _showForm(BuildContext context, WidgetRef ref, Budget? budget) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _BudgetFormSheet(budget: budget),
    );
  }
}

class _BudgetCard extends ConsumerWidget {
  final BudgetProgress progress;
  const _BudgetCard({required this.progress});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final categories = ref.watch(categoriesByIdProvider);
    final currency = ref.watch(settingsProvider).currencyCode;
    final locale = Localizations.localeOf(context).toString();

    final budget = progress.budget;
    final category =
        budget.categoryId == null ? null : categories[budget.categoryId];
    final isOverall = budget.categoryId == null;
    final title = isOverall
        ? l10n.overallMonthlyBudget
        : category == null
            ? budget.categoryId!
            : categoryName(context, category);
    final barColor = progress.isExceeded
        ? scheme.error
        : progress.isNearLimit
            ? const Color(0xFFF59E0B)
            : scheme.primary;

    return AppCard(
      onTap: () => BudgetsScreen._showForm(context, ref, budget),
      onLongPress: () => _confirmDelete(context, ref),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isOverall)
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.account_balance_wallet_rounded,
                      color: scheme.onPrimaryContainer),
                )
              else
                CategoryAvatar(category: category),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(
                      '${l10n.limit}: ${Formatters.currency(budget.amount, code: currency, locale: locale)}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded,
                    size: 20, color: scheme.error),
                tooltip: l10n.delete,
                onPressed: () => _confirmDelete(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TweenAnimationBuilder<double>(
            tween: Tween(end: progress.fraction.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 10,
                backgroundColor: scheme.surfaceContainerHighest,
                color: barColor,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${l10n.spent}: ${Formatters.currency(progress.spent, code: currency, locale: locale)}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
              Text(
                '${l10n.remaining}: ${Formatters.currency(progress.remaining, code: currency, locale: locale)}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: progress.remaining < 0 ? scheme.error : barColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.deleteBudget,
      message: l10n.deleteBudgetConfirm,
      confirmLabel: l10n.delete,
      cancelLabel: l10n.cancel,
      destructive: true,
    );
    if (!confirmed) return;
    await ref.read(budgetRepositoryProvider).delete(progress.budget.id);
    if (context.mounted) showAppSnackBar(context, l10n.budgetDeleted);
  }
}

class _BudgetFormSheet extends ConsumerStatefulWidget {
  final Budget? budget;
  const _BudgetFormSheet({this.budget});

  @override
  ConsumerState<_BudgetFormSheet> createState() => _BudgetFormSheetState();
}

class _BudgetFormSheetState extends ConsumerState<_BudgetFormSheet> {
  late final TextEditingController _amountController;
  String? _categoryId;
  bool _isOverall = false;

  @override
  void initState() {
    super.initState();
    final b = widget.budget;
    _amountController = TextEditingController(
        text: b == null ? '' : b.amount.toStringAsFixed(0));
    _categoryId = b?.categoryId;
    _isOverall = b != null && b.categoryId == null;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final amount =
        double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0) {
      showAppSnackBar(context, l10n.invalidAmount);
      return;
    }
    if (!_isOverall && _categoryId == null) {
      showAppSnackBar(context, l10n.selectCategory);
      return;
    }
    final budgets = ref.read(budgetsProvider).value ?? [];
    // One budget per scope: editing keeps its id, new ones replace any
    // existing budget for the same category/overall scope.
    final scopeCategory = _isOverall ? null : _categoryId;
    final existing = widget.budget ??
        budgets
            .where((b) => b.categoryId == scopeCategory)
            .firstOrNull;
    await ref.read(budgetRepositoryProvider).upsert(Budget(
          id: existing?.id ?? const Uuid().v4(),
          categoryId: scopeCategory,
          amount: amount,
        ));
    if (!mounted) return;
    successHaptic();
    showAppSnackBar(context, l10n.budgetSaved);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isEdit = widget.budget != null;
    final categories = (ref.watch(categoriesProvider).value ?? [])
        .where((c) => !c.isIncome)
        .toList();

    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 4, 24, 24 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(isEdit ? l10n.editBudget : l10n.addBudget,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          if (!isEdit)
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.overallMonthlyBudget),
              value: _isOverall,
              onChanged: (v) => setState(() => _isOverall = v),
            ),
          if (!_isOverall) ...[
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _categoryId,
              decoration: InputDecoration(labelText: l10n.category),
              items: [
                for (final category in categories)
                  DropdownMenuItem(
                    value: category.id,
                    child: Text(categoryName(context, category)),
                  ),
              ],
              onChanged: isEdit
                  ? null
                  : (v) => setState(() => _categoryId = v),
            ),
          ],
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: l10n.budgetAmount),
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: _save, child: Text(l10n.save)),
        ],
      ),
    );
  }
}
