import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/utils/date_ranges.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/utils/display.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/shimmer.dart';
import '../../expenses/domain/expense.dart';
import '../../settings/presentation/settings_providers.dart';
import '../domain/analytics_math.dart';

enum _Period { week, month, year }

class _PeriodNotifier extends Notifier<_Period> {
  @override
  _Period build() => _Period.month;

  void set(_Period period) => state = period;
}

final _periodProvider =
    NotifierProvider<_PeriodNotifier, _Period>(_PeriodNotifier.new);

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final expensesAsync = ref.watch(allExpensesProvider);
    final period = ref.watch(_periodProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.analytics),
        actions: [
          IconButton(
            icon: const Icon(Icons.description_outlined),
            tooltip: l10n.reports,
            onPressed: () => context.push('/reports'),
          ),
        ],
      ),
      body: SafeArea(
        child: expensesAsync.when(
          loading: () => const ListShimmer(),
          error: (e, _) => EmptyState(
              icon: Icons.error_outline_rounded,
              title: l10n.somethingWentWrong),
          data: (expenses) {
            final now = DateTime.now();
            final (start, end) = switch (period) {
              _Period.week => (DateRanges.startOfWeek(now), now),
              _Period.month => (DateRanges.startOfMonth(now), now),
              _Period.year => (DateRanges.startOfYear(now), now),
            };
            final inPeriod = expenses
                .where((e) =>
                    !e.date.isBefore(start) &&
                    !e.date.isAfter(DateRanges.endOfDay(end)))
                .toList();

            return LayoutBuilder(builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 760;
              final cards = <Widget>[
                _PieCard(expenses: inPeriod),
                _TrendCard(expenses: expenses, period: period),
                _IncomeExpenseCard(expenses: expenses),
                const _BudgetComparisonCard(),
                _HeatmapCard(expenses: expenses),
              ];
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  SegmentedButton<_Period>(
                    segments: [
                      ButtonSegment(
                          value: _Period.week, label: Text(l10n.week)),
                      ButtonSegment(
                          value: _Period.month, label: Text(l10n.month)),
                      ButtonSegment(
                          value: _Period.year, label: Text(l10n.year)),
                    ],
                    selected: {period},
                    onSelectionChanged: (s) =>
                        ref.read(_periodProvider.notifier).set(s.first),
                  ),
                  const SizedBox(height: 16),
                  _StatsRow(expenses: inPeriod, start: start, end: end),
                  const SizedBox(height: 16),
                  if (isWide)
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        for (final card in cards)
                          SizedBox(
                            width: (constraints.maxWidth - 56) / 2,
                            child: card,
                          ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        for (final card in cards)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: card,
                          ),
                      ],
                    ),
                ],
              );
            });
          },
        ),
      ),
    );
  }
}

class _StatsRow extends ConsumerWidget {
  final List<Expense> expenses;
  final DateTime start;
  final DateTime end;
  const _StatsRow(
      {required this.expenses, required this.start, required this.end});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final currency = ref.watch(settingsProvider).currencyCode;
    final locale = Localizations.localeOf(context).toString();
    final scheme = Theme.of(context).colorScheme;

    final spends = expenses
        .where((e) => e.type == TransactionType.expense)
        .map((e) => e.amount)
        .toList();
    final total = AnalyticsMath.sum(spends);
    final days = end.difference(start).inDays + 1;
    final avg = days <= 0 ? 0.0 : total / days;
    final highest = AnalyticsMath.max(spends);

    Widget chip(String label, String value) => Expanded(
          child: AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Column(
              children: [
                Text(value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
        chip(l10n.totalSpent,
            Formatters.compactCurrency(total, code: currency, locale: locale)),
        const SizedBox(width: 10),
        chip(l10n.avgPerDay,
            Formatters.compactCurrency(avg, code: currency, locale: locale)),
        const SizedBox(width: 10),
        chip(
            l10n.highestSpend,
            Formatters.compactCurrency(highest,
                code: currency, locale: locale)),
        const SizedBox(width: 10),
        chip(l10n.transactionsCount(spends.length), '${spends.length}'),
      ],
    );
  }
}

class _PieCard extends ConsumerWidget {
  final List<Expense> expenses;
  const _PieCard({required this.expenses});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final categories = ref.watch(categoriesByIdProvider);
    final currency = ref.watch(settingsProvider).currencyCode;
    final locale = Localizations.localeOf(context).toString();
    final totals = AnalyticsMath.categoryTotals(expenses);
    final total = AnalyticsMath.sum(totals.values);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.categoryAnalysis,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 18),
          if (total <= 0)
            SizedBox(
              height: 140,
              child: Center(
                child: Text(l10n.noDataForPeriod,
                    style: TextStyle(color: scheme.onSurfaceVariant)),
              ),
            )
          else ...[
            SizedBox(
              height: 190,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: 46,
                  sections: [
                    for (final entry in totals.entries)
                      PieChartSectionData(
                        value: entry.value,
                        color: Color(
                            categories[entry.key]?.color ?? 0xFF8B5CF6),
                        radius: 44,
                        title:
                            '${(entry.value / total * 100).round()}%',
                        titleStyle: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                        showTitle: entry.value / total >= 0.06,
                      ),
                  ],
                ),
                duration: const Duration(milliseconds: 500),
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                for (final entry in totals.entries.take(6))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Color(
                                categories[entry.key]?.color ?? 0xFF8B5CF6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            categories[entry.key] == null
                                ? entry.key
                                : categoryName(
                                    context, categories[entry.key]!),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        Text(
                          Formatters.currency(entry.value,
                              code: currency, locale: locale),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TrendCard extends ConsumerWidget {
  final List<Expense> expenses;
  final _Period period;
  const _TrendCard({required this.expenses, required this.period});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final now = DateTime.now();

    final title = switch (period) {
      _Period.week => l10n.weeklySpending,
      _Period.month => l10n.monthlySpending,
      _Period.year => l10n.yearlyTrends,
    };

    Widget chart;
    switch (period) {
      case _Period.week:
        final series = AnalyticsMath.dailySeries(expenses, now, 7);
        chart = _bars(
          context,
          series,
          (i) => Formatters.weekdayShort(
              now.subtract(Duration(days: 6 - i)),
              locale: locale),
        );
      case _Period.month:
        final days = now.day;
        final series = AnalyticsMath.dailySeries(expenses, now, days);
        chart = _line(
          context,
          series,
          (i) {
            final day = i + 1;
            return day == 1 || day % 7 == 0 ? '$day' : '';
          },
        );
      case _Period.year:
        final series = AnalyticsMath.monthlySeries(expenses, now.year);
        chart = _line(
          context,
          series,
          (i) => Formatters.monthShort(DateTime(now.year, i + 1),
                  locale: locale)
              .substring(0, 1),
        );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              Icon(Icons.show_chart_rounded, color: scheme.primary, size: 20),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(height: 180, child: chart),
        ],
      ),
    );
  }

  Widget _bars(BuildContext context, List<double> series,
      String Function(int index) label) {
    final scheme = Theme.of(context).colorScheme;
    final maxY = AnalyticsMath.max(series);
    if (maxY <= 0) return _noData(context);
    return BarChart(
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
              reservedSize: 28,
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(label(value.toInt()),
                    style: TextStyle(
                        fontSize: 10, color: scheme.onSurfaceVariant)),
              ),
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < series.length; i++)
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                toY: series[i],
                width: 16,
                borderRadius: BorderRadius.circular(6),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    scheme.primary.withValues(alpha: .55),
                    scheme.primary,
                  ],
                ),
              ),
            ]),
        ],
      ),
      duration: const Duration(milliseconds: 500),
    );
  }

  Widget _line(BuildContext context, List<double> series,
      String Function(int index) label) {
    final scheme = Theme.of(context).colorScheme;
    final maxY = AnalyticsMath.max(series);
    if (maxY <= 0) return _noData(context);
    return LineChart(
      LineChartData(
        maxY: maxY * 1.2,
        minY: 0,
        lineTouchData: const LineTouchData(enabled: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: scheme.outlineVariant.withValues(alpha: .25),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(),
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 26,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final text = label(value.toInt());
                if (text.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(text,
                      style: TextStyle(
                          fontSize: 10, color: scheme.onSurfaceVariant)),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < series.length; i++)
                FlSpot(i.toDouble(), series[i]),
            ],
            isCurved: true,
            preventCurveOverShooting: true,
            barWidth: 3.5,
            color: scheme.primary,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  scheme.primary.withValues(alpha: .25),
                  scheme.primary.withValues(alpha: .0),
                ],
              ),
            ),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 500),
    );
  }

  Widget _noData(BuildContext context) => Center(
        child: Text(context.l10n.noDataForPeriod,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
      );
}

class _IncomeExpenseCard extends ConsumerWidget {
  final List<Expense> expenses;
  const _IncomeExpenseCard({required this.expenses});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final data =
        AnalyticsMath.incomeExpenseByMonth(expenses, DateTime.now(), 6);
    final maxY = AnalyticsMath.max(
        data.expand((d) => [d.income, d.expense]));

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.incomeVsExpense,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Row(
            children: [
              _LegendDot(color: scheme.primary, label: l10n.income),
              const SizedBox(width: 16),
              _LegendDot(color: scheme.error, label: l10n.expense),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
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
                            reservedSize: 28,
                            getTitlesWidget: (value, meta) => Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                Formatters.monthShort(
                                    data[value.toInt()].month,
                                    locale: locale),
                                style: TextStyle(
                                    fontSize: 10,
                                    color: scheme.onSurfaceVariant),
                              ),
                            ),
                          ),
                        ),
                      ),
                      barGroups: [
                        for (var i = 0; i < data.length; i++)
                          BarChartGroupData(
                            x: i,
                            barsSpace: 4,
                            barRods: [
                              BarChartRodData(
                                toY: data[i].income,
                                width: 8,
                                borderRadius: BorderRadius.circular(3),
                                color: scheme.primary,
                              ),
                              BarChartRodData(
                                toY: data[i].expense,
                                width: 8,
                                borderRadius: BorderRadius.circular(3),
                                color: scheme.error,
                              ),
                            ],
                          ),
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

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _BudgetComparisonCard extends ConsumerWidget {
  const _BudgetComparisonCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final progress = ref.watch(budgetProgressProvider);
    final categories = ref.watch(categoriesByIdProvider);
    final currency = ref.watch(settingsProvider).currencyCode;
    final locale = Localizations.localeOf(context).toString();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.budgetComparison,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          if (progress.isEmpty)
            Text(l10n.noBudgets,
                style: TextStyle(color: scheme.onSurfaceVariant))
          else
            Column(
              children: [
                for (final p in progress)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              p.budget.categoryId == null
                                  ? l10n.overallMonthlyBudget
                                  : categories[p.budget.categoryId] == null
                                      ? p.budget.categoryId!
                                      : categoryName(context,
                                          categories[p.budget.categoryId]!),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            Text(
                              '${Formatters.compactCurrency(p.spent, code: currency, locale: locale)} / ${Formatters.compactCurrency(p.budget.amount, code: currency, locale: locale)}',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: p.fraction.clamp(0.0, 1.0),
                            minHeight: 8,
                            backgroundColor: scheme.surfaceContainerHighest,
                            color: p.isExceeded
                                ? scheme.error
                                : p.isNearLimit
                                    ? const Color(0xFFF59E0B)
                                    : scheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _HeatmapCard extends ConsumerWidget {
  final List<Expense> expenses;
  const _HeatmapCard({required this.expenses});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    const days = 105; // 15 weeks
    final now = DateTime.now();
    final map = AnalyticsMath.heatmap(expenses, now, days);
    final maxSpend = AnalyticsMath.max(map.values);

    // Build week columns, oldest first, aligned to Monday.
    final endDay = DateRanges.startOfDay(now);
    final start = endDay.subtract(const Duration(days: days - 1));
    final alignedStart =
        start.subtract(Duration(days: start.weekday - 1));
    final weeks = <List<DateTime?>>[];
    var cursor = alignedStart;
    while (!cursor.isAfter(endDay)) {
      final week = <DateTime?>[];
      for (var d = 0; d < 7; d++) {
        final day = cursor.add(Duration(days: d));
        week.add(day.isBefore(start) || day.isAfter(endDay) ? null : day);
      }
      weeks.add(week);
      cursor = cursor.add(const Duration(days: 7));
    }

    Color cellColor(double value) {
      if (maxSpend <= 0 || value <= 0) {
        return scheme.surfaceContainerHighest.withValues(alpha: .55);
      }
      final t = (value / maxSpend).clamp(0.15, 1.0);
      return scheme.primary.withValues(alpha: t);
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.spendingHeatmap,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Row(
              children: [
                for (final week in weeks)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Column(
                      children: [
                        for (final day in week)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Container(
                              width: 15,
                              height: 15,
                              decoration: BoxDecoration(
                                color: day == null
                                    ? Colors.transparent
                                    : cellColor(map[day] ?? 0),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(l10n.heatLess,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant)),
              const SizedBox(width: 6),
              for (final alpha in const [.15, .35, .6, 1.0])
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: alpha),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              const SizedBox(width: 6),
              Text(l10n.heatMore,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}
