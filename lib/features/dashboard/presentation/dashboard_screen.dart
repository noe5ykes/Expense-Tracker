import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/utils/display.dart';
import '../../../shared/widgets/animated_counter.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/category_avatar.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/expense_tile.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/shimmer.dart';
import '../../analytics/domain/analytics_math.dart';
import '../../authentication/presentation/auth_controller.dart';
import '../../expenses/domain/expense.dart';
import '../../settings/presentation/settings_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final expensesAsync = ref.watch(allExpensesProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'dashboard-fab',
        onPressed: () => context.push('/expense-form'),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.addExpense),
      ),
      body: SafeArea(
        child: expensesAsync.when(
          loading: () => const ListShimmer(),
          error: (e, _) => EmptyState(
              icon: Icons.error_outline_rounded,
              title: l10n.somethingWentWrong),
          data: (_) => const _DashboardBody(),
        ),
      ),
    );
  }
}

class _DashboardBody extends ConsumerWidget {
  const _DashboardBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth >= 760;
      final children = [
        const _Header(),
        const SizedBox(height: 20),
        if (isWide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(children: const [
                  _BalanceCard(),
                  SizedBox(height: 16),
                  _QuickStatsRow(),
                  SizedBox(height: 16),
                  _BudgetCard(),
                  SizedBox(height: 16),
                  _SavingsCard(),
                ]),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(children: const [
                  _WeekPreviewCard(),
                  SizedBox(height: 16),
                  _QuickAddSection(),
                  SizedBox(height: 16),
                  _UpcomingBillsSection(),
                ]),
              ),
            ],
          )
        else ...const [
          _BalanceCard(),
          SizedBox(height: 16),
          _QuickStatsRow(),
          SizedBox(height: 16),
          _BudgetCard(),
          SizedBox(height: 16),
          _QuickAddSection(),
          SizedBox(height: 16),
          _WeekPreviewCard(),
          SizedBox(height: 16),
          _SavingsCard(),
          SizedBox(height: 16),
          _UpcomingBillsSection(),
        ],
        const SizedBox(height: 20),
        const _RecentExpensesSection(),
        const SizedBox(height: 90),
      ];

      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        children: children,
      );
    });
  }
}

class _Header extends ConsumerWidget {
  const _Header();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final scheme = Theme.of(context).colorScheme;
    final name = auth.name.isEmpty ? context.l10n.appName : auth.name;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greeting(context, DateTime.now()),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: scheme.onSurfaceVariant)),
              Text(name,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
        ),
        PressableScale(
          onTap: () => context.push('/profile'),
          child: CircleAvatar(
            radius: 24,
            backgroundColor: scheme.primaryContainer,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w800,
                  fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }
}

class _BalanceCard extends ConsumerWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final stats = ref.watch(dashboardStatsProvider);
    final currency = ref.watch(settingsProvider).currencyCode;
    final locale = Localizations.localeOf(context).toString();

    return AppCard(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF16A34A), Color(0xFF0D9466), Color(0xFF065F46)],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.totalBalance,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: .85),
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          AnimatedAmount(
            value: stats.totalBalance,
            format: (v) => Formatters.currency(v, code: currency, locale: locale),
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Colors.white, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: GlassCard(
                  child: _BalanceStat(
                    icon: Icons.arrow_downward_rounded,
                    label: l10n.incomeThisMonth,
                    value: Formatters.currency(stats.monthIncome,
                        code: currency, locale: locale),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GlassCard(
                  child: _BalanceStat(
                    icon: Icons.arrow_upward_rounded,
                    label: l10n.spentThisMonth,
                    value: Formatters.currency(stats.monthSpend,
                        code: currency, locale: locale),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _BalanceStat(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: Colors.white),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: .8))),
              Text(value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15)),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickStatsRow extends ConsumerWidget {
  const _QuickStatsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final stats = ref.watch(dashboardStatsProvider);
    final currency = ref.watch(settingsProvider).currencyCode;
    final locale = Localizations.localeOf(context).toString();
    final scheme = Theme.of(context).colorScheme;

    Widget stat(String label, double value, IconData icon, Color color) =>
        Expanded(
          child: AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(height: 10),
                AnimatedAmount(
                  value: value,
                  format: (v) =>
                      Formatters.currency(v, code: currency, locale: locale),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                Text(label,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant)),
              ],
            ),
          ),
        );

    return Row(
      children: [
        stat(l10n.todaysSpending, stats.todaySpend, Icons.today_rounded,
            scheme.primary),
        const SizedBox(width: 12),
        stat(l10n.monthlySpending, stats.monthSpend,
            Icons.calendar_month_rounded, scheme.tertiary),
      ],
    );
  }
}

class _BudgetCard extends ConsumerWidget {
  const _BudgetCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final progress = ref.watch(overallBudgetProgressProvider);
    final currency = ref.watch(settingsProvider).currencyCode;
    final locale = Localizations.localeOf(context).toString();
    final scheme = Theme.of(context).colorScheme;

    if (progress == null) {
      return AppCard(
        onTap: () => context.go('/budgets'),
        child: Row(
          children: [
            Icon(Icons.account_balance_wallet_rounded, color: scheme.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.monthlyBudget,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(l10n.setBudgetHint,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      );
    }

    final fraction = progress.fraction.clamp(0.0, 1.0);
    final barColor = progress.isExceeded
        ? scheme.error
        : progress.isNearLimit
            ? const Color(0xFFF59E0B)
            : scheme.primary;

    return AppCard(
      onTap: () => context.go('/budgets'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.monthlyBudget,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: barColor.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  progress.isExceeded ? l10n.overBudget : l10n.onTrack,
                  style: TextStyle(
                      color: barColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TweenAnimationBuilder<double>(
            tween: Tween(end: fraction),
            duration: const Duration(milliseconds: 800),
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
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.budgetUsedPercent(
                    (progress.fraction * 100).toStringAsFixed(0)),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
              Text(
                '${l10n.budgetRemaining}: ${Formatters.currency(progress.remaining, code: currency, locale: locale)}',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: progress.remaining < 0
                        ? scheme.error
                        : scheme.onSurface),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAddSection extends ConsumerWidget {
  const _QuickAddSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = (ref.watch(categoriesProvider).value ?? [])
        .where((c) => !c.isIncome)
        .take(8)
        .toList();
    if (categories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: context.l10n.quickAdd,
          onSeeAll: () => context.push('/categories'),
        ),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final category = categories[index];
              return PressableScale(
                onTap: () => context.push('/expense-form',
                    extra: ExpenseFormArgs(presetCategoryId: category.id)),
                child: SizedBox(
                  width: 68,
                  child: Column(
                    children: [
                      CategoryAvatar(category: category, size: 56),
                      const SizedBox(height: 6),
                      Text(
                        categoryName(context, category),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _WeekPreviewCard extends ConsumerWidget {
  const _WeekPreviewCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final expenses = ref.watch(allExpensesProvider).value ?? const <Expense>[];
    final scheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final series = AnalyticsMath.dailySeries(expenses, now, 7);
    final maxY = AnalyticsMath.max(series);
    final locale = Localizations.localeOf(context).toString();

    return AppCard(
      onTap: () => context.go('/analytics'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.analyticsPreview,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              Icon(Icons.insights_rounded, color: scheme.primary, size: 20),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 110,
            child: maxY <= 0
                ? Center(
                    child: Text(l10n.noDataForPeriod,
                        style: TextStyle(color: scheme.onSurfaceVariant)))
                : BarChart(
                    BarChartData(
                      maxY: maxY * 1.2,
                      barTouchData: const BarTouchData(enabled: false),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(),
                        topTitles: const AxisTitles(),
                        rightTitles: const AxisTitles(),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 26,
                            getTitlesWidget: (value, meta) {
                              final day = now.subtract(
                                  Duration(days: 6 - value.toInt()));
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  Formatters.weekdayShort(day, locale: locale)
                                      .substring(0, 1),
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: scheme.onSurfaceVariant),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      barGroups: [
                        for (var i = 0; i < series.length; i++)
                          BarChartGroupData(x: i, barRods: [
                            BarChartRodData(
                              toY: series[i],
                              width: 14,
                              borderRadius: BorderRadius.circular(5),
                              color: i == series.length - 1
                                  ? scheme.primary
                                  : scheme.primary.withValues(alpha: .35),
                            ),
                          ]),
                      ],
                    ),
                    duration: const Duration(milliseconds: 500),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SavingsCard extends ConsumerWidget {
  const _SavingsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final stats = ref.watch(dashboardStatsProvider);
    final currency = ref.watch(settingsProvider).currencyCode;
    final locale = Localizations.localeOf(context).toString();
    final scheme = Theme.of(context).colorScheme;
    final rate = stats.savingsRate;

    return AppCard(
      child: Row(
        children: [
          SizedBox(
            height: 64,
            width: 64,
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: rate),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: value,
                    strokeWidth: 7,
                    backgroundColor: scheme.surfaceContainerHighest,
                    color: scheme.primary,
                    strokeCap: StrokeCap.round,
                  ),
                  Center(
                    child: Text(
                      Formatters.percent(value),
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.savingsOverview,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  '${l10n.savingsThisMonth}: ${Formatters.currency(stats.monthSavings, code: currency, locale: locale)}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
                Text(
                  '${l10n.savingsRate}: ${Formatters.percent(rate)}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingBillsSection extends ConsumerWidget {
  const _UpcomingBillsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final bills = ref.watch(upcomingBillsProvider).take(3).toList();
    final currency = ref.watch(settingsProvider).currencyCode;
    final locale = Localizations.localeOf(context).toString();
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: l10n.upcomingBills,
          onSeeAll: () => context.push('/bills'),
        ),
        if (bills.isEmpty)
          AppCard(
            child: Row(
              children: [
                Icon(Icons.event_available_rounded, color: scheme.primary),
                const SizedBox(width: 12),
                Text(l10n.noBills),
              ],
            ),
          )
        else
          Column(
            children: [
              for (final bill in bills)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    onTap: () => context.push('/bills'),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: scheme.tertiaryContainer,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(Icons.receipt_long_rounded,
                              color: scheme.onTertiaryContainer, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(bill.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                              Text(
                                _dueLabel(context, bill.dueDate),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: scheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          Formatters.currency(bill.amount,
                              code: currency, locale: locale),
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

String _dueLabel(BuildContext context, DateTime dueDate) {
  final l10n = context.l10n;
  final today = DateTime.now();
  final days = DateTime(dueDate.year, dueDate.month, dueDate.day)
      .difference(DateTime(today.year, today.month, today.day))
      .inDays;
  if (days < 0) return l10n.overdue;
  if (days == 0) return l10n.dueToday;
  return l10n.dueInDays(days);
}

class _RecentExpensesSection extends ConsumerWidget {
  const _RecentExpensesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final expenses =
        (ref.watch(allExpensesProvider).value ?? const <Expense>[])
            .take(5)
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: l10n.recentExpenses,
          onSeeAll: () => context.go('/expenses'),
        ),
        if (expenses.isEmpty)
          EmptyState(
            icon: Icons.receipt_long_rounded,
            title: l10n.noExpensesYet,
            subtitle: l10n.addFirstExpense,
          )
        else
          Column(
            children: [
              for (final expense in expenses)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ExpenseTile(expense: expense),
                ),
            ],
          ),
      ],
    );
  }
}
