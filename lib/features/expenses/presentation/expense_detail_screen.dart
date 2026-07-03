import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/adaptive.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/utils/display.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/category_avatar.dart';
import '../domain/expense.dart';

class ExpenseDetailScreen extends ConsumerWidget {
  final Expense expense;
  const ExpenseDetailScreen({super.key, required this.expense});

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.deleteExpense,
      message: l10n.deleteExpenseConfirm,
      confirmLabel: l10n.delete,
      cancelLabel: l10n.cancel,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    await ref.read(expenseRepositoryProvider).delete(expense.id);
    if (context.mounted) {
      showAppSnackBar(context, l10n.expenseDeleted);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    // Watch the live expense so edits made from this screen are reflected.
    final live = (ref.watch(allExpensesProvider).value ?? const <Expense>[])
        .where((e) => e.id == expense.id)
        .firstOrNull;
    final current = live ?? expense;
    final category = ref.watch(categoriesByIdProvider)[current.categoryId];
    final locale = Localizations.localeOf(context).toString();
    final isIncome = current.type == TransactionType.income;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.expenseDetails),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            tooltip: l10n.edit,
            onPressed: () => context.push('/expense-form',
                extra: ExpenseFormArgs(expense: current)),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: scheme.error),
            tooltip: l10n.delete,
            onPressed: () => _delete(context, ref),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            AppCard(
              padding: const EdgeInsets.all(26),
              child: Column(
                children: [
                  CategoryAvatar(category: category, size: 64),
                  const SizedBox(height: 14),
                  Text(current.title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text(
                    '${isIncome ? '+' : '-'}${Formatters.currency(current.amount, code: current.currency, locale: locale)}',
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall
                        ?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isIncome ? scheme.primary : scheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer.withValues(alpha: .6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isIncome ? l10n.income : l10n.expense,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: scheme.onPrimaryContainer),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                children: [
                  _DetailRow(
                    icon: Icons.category_rounded,
                    label: l10n.category,
                    value: category == null
                        ? current.categoryId
                        : categoryName(context, category),
                  ),
                  _DetailRow(
                    icon: Icons.calendar_today_rounded,
                    label: l10n.date,
                    value: Formatters.date(current.date, locale: locale),
                  ),
                  _DetailRow(
                    icon: Icons.schedule_rounded,
                    label: l10n.time,
                    value: Formatters.time(current.date, locale: locale),
                  ),
                  _DetailRow(
                    icon: Icons.payment_rounded,
                    label: l10n.paymentMethod,
                    value: paymentMethodLabel(context, current.paymentMethod),
                  ),
                  _DetailRow(
                    icon: Icons.currency_exchange_rounded,
                    label: l10n.currency,
                    value: current.currency,
                  ),
                  if (current.location != null)
                    _DetailRow(
                      icon: Icons.place_outlined,
                      label: l10n.location,
                      value: current.location!,
                    ),
                ],
              ),
            ),
            if (current.tags.isNotEmpty) ...[
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.tags,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final tag in current.tags)
                          Chip(
                            label: Text('#$tag'),
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            if (current.notes.isNotEmpty) ...[
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.notes,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text(current.notes,
                        style: TextStyle(
                            color: scheme.onSurfaceVariant, height: 1.5)),
                  ],
                ),
              ),
            ],
            if (current.receiptPaths.isNotEmpty) ...[
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.receipts,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 110,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: current.receiptPaths.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (context, index) => GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => _ReceiptViewer(
                                paths: current.receiptPaths,
                                initialIndex: index,
                              ),
                            ),
                          ),
                          child: Hero(
                            tag: 'receipt-${current.id}-$index',
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                File(current.receiptPaths[index]),
                                width: 110,
                                height: 110,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  width: 110,
                                  height: 110,
                                  color: scheme.surfaceContainerHighest,
                                  child:
                                      const Icon(Icons.broken_image_rounded),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Icon(icon, size: 20, color: scheme.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label,
                style: TextStyle(color: scheme.onSurfaceVariant)),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

/// Full-screen, zoomable receipt gallery.
class _ReceiptViewer extends StatelessWidget {
  final List<String> paths;
  final int initialIndex;
  const _ReceiptViewer({required this.paths, required this.initialIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: PageView.builder(
        controller: PageController(initialPage: initialIndex),
        itemCount: paths.length,
        itemBuilder: (context, index) => InteractiveViewer(
          maxScale: 5,
          child: Center(
            child: Image.file(
              File(paths[index]),
              errorBuilder: (_, _, _) => const Icon(
                  Icons.broken_image_rounded,
                  color: Colors.white54,
                  size: 64),
            ),
          ),
        ),
      ),
    );
  }
}
