import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/l10n_ext.dart';
import '../../core/utils/date_ranges.dart';
import '../../core/utils/formatters.dart';
import '../../features/expenses/domain/expense.dart';
import '../providers/app_providers.dart';
import '../utils/display.dart';
import 'app_card.dart';
import 'category_avatar.dart';

/// A single transaction row used on the dashboard and the expenses list.
class ExpenseTile extends ConsumerWidget {
  final Expense expense;
  const ExpenseTile({super.key, required this.expense});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final category = ref.watch(categoriesByIdProvider)[expense.categoryId];
    final isIncome = expense.type == TransactionType.income;
    final locale = Localizations.localeOf(context).toString();

    final now = DateTime.now();
    final String dateLabel;
    if (DateRanges.sameDay(expense.date, now)) {
      dateLabel = context.l10n.today;
    } else if (DateRanges.sameDay(
        expense.date, now.subtract(const Duration(days: 1)))) {
      dateLabel = context.l10n.yesterday;
    } else {
      dateLabel = Formatters.dateShort(expense.date, locale: locale);
    }

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onTap: () => context.push('/expenses/detail', extra: expense),
      child: Row(
        children: [
          CategoryAvatar(category: category),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  category == null
                      ? dateLabel
                      : '${categoryName(context, category)} · $dateLabel',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : '-'}${Formatters.currency(expense.amount, code: expense.currency, locale: locale)}',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isIncome ? scheme.primary : scheme.onSurface,
                ),
              ),
              if (expense.receiptPaths.isNotEmpty) ...[
                const SizedBox(height: 3),
                Icon(Icons.receipt_rounded,
                    size: 14, color: scheme.onSurfaceVariant),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
