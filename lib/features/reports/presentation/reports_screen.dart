import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/services/report_service.dart';
import '../../../core/utils/adaptive.dart';
import '../../../core/utils/date_ranges.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/utils/display.dart';
import '../../../shared/widgets/app_card.dart';
import '../../expenses/domain/expense.dart';
import '../../settings/presentation/settings_providers.dart';
import '../../analytics/domain/analytics_math.dart';

enum _ReportType { monthly, annual, category }

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  _ReportType _type = _ReportType.monthly;
  DateTime _month = DateRanges.startOfMonth(DateTime.now());
  bool _busy = false;

  List<Expense> _expensesForPeriod(List<Expense> all) {
    final (start, end) = switch (_type) {
      _ReportType.annual => (
          DateRanges.startOfYear(_month),
          DateRanges.endOfYear(_month)
        ),
      _ => (DateRanges.startOfMonth(_month), DateRanges.endOfMonth(_month)),
    };
    return all
        .where((e) => !e.date.isBefore(start) && !e.date.isAfter(end))
        .toList();
  }

  String _periodLabel() {
    final locale = Localizations.localeOf(context).toString();
    return _type == _ReportType.annual
        ? '${_month.year}'
        : Formatters.monthYear(_month, locale: locale);
  }

  ReportLabels _labels() {
    final l10n = context.l10n;
    final title = switch (_type) {
      _ReportType.monthly => l10n.monthlyReport,
      _ReportType.annual => l10n.annualReport,
      _ReportType.category => l10n.categoryReport,
    };
    return (
      reportTitle: '${l10n.appName} — $title',
      period: _periodLabel(),
      colDate: l10n.date,
      colTitle: l10n.title,
      colCategory: l10n.category,
      colType: l10n.transactionType,
      colMethod: l10n.paymentMethod,
      colAmount: l10n.amount,
      byCategory: l10n.categoryAnalysis,
      total: l10n.totalSpent,
      income: l10n.income,
      expense: l10n.expense,
    );
  }

  Future<void> _export(
      Future<void> Function(ReportService service, List<Expense> expenses,
              Map<String, String> names)
          exporter) async {
    final l10n = context.l10n;
    setState(() => _busy = true);
    try {
      final all = ref.read(allExpensesProvider).value ?? const <Expense>[];
      var expenses = _expensesForPeriod(all);
      if (_type == _ReportType.category) {
        expenses = [...expenses]
          ..sort((a, b) => a.categoryId.compareTo(b.categoryId));
      }
      final categories = ref.read(categoriesByIdProvider);
      final names = {
        for (final entry in categories.entries)
          entry.key: categoryName(context, entry.value),
      };
      await exporter(ReportService(), expenses, names);
      if (mounted) showAppSnackBar(context, l10n.reportGenerated);
    } catch (_) {
      if (mounted) showAppSnackBar(context, l10n.reportFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickPeriod() async {
    if (_type == _ReportType.annual) {
      final now = DateTime.now();
      final year = await showDialog<int>(
        context: context,
        builder: (ctx) => SimpleDialog(
          title: Text(context.l10n.selectYear),
          children: [
            for (var y = now.year; y >= now.year - 5; y--)
              SimpleDialogOption(
                onPressed: () => Navigator.of(ctx).pop(y),
                child: Text('$y'),
              ),
          ],
        ),
      );
      if (year != null) setState(() => _month = DateTime(year));
    } else {
      final picked = await showAdaptiveDatePicker(context,
          initialDate: _month, lastDate: DateTime.now());
      if (picked != null) {
        setState(() => _month = DateRanges.startOfMonth(picked));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final currency = ref.watch(settingsProvider).currencyCode;
    final locale = Localizations.localeOf(context).toString();
    final all = ref.watch(allExpensesProvider).value ?? const <Expense>[];
    final expenses = _expensesForPeriod(all);
    final spends = expenses
        .where((e) => e.type == TransactionType.expense)
        .map((e) => e.amount);
    final total = AnalyticsMath.sum(spends);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reports)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            SegmentedButton<_ReportType>(
              segments: [
                ButtonSegment(
                    value: _ReportType.monthly, label: Text(l10n.month)),
                ButtonSegment(
                    value: _ReportType.annual, label: Text(l10n.year)),
                ButtonSegment(
                    value: _ReportType.category, label: Text(l10n.category)),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() => _type = s.first),
            ),
            const SizedBox(height: 16),
            AppCard(
              onTap: _pickPeriod,
              child: Row(
                children: [
                  Icon(Icons.event_rounded, color: scheme.primary),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.reportPeriod,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: scheme.onSurfaceVariant)),
                        Text(_periodLabel(),
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 16)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        Formatters.currency(total,
                            code: currency, locale: locale),
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      Text(l10n.totalSpent,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant)),
                    ],
                  ),
                  Column(
                    children: [
                      Text('${expenses.length}',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800)),
                      Text(l10n.transactionsCount(expenses.length),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _ExportTile(
              icon: Icons.picture_as_pdf_rounded,
              color: const Color(0xFFEF4444),
              label: l10n.exportPdf,
              busy: _busy,
              onTap: () => _export((service, expenses, names) =>
                  service.sharePdf(
                      expenses: expenses,
                      categoryNames: names,
                      labels: _labels(),
                      // ASCII code instead of symbol: the PDF base fonts have
                      // no glyphs for ₹ and other non-WinAnsi symbols.
                      currencySymbol:
                          '${ref.read(settingsProvider).currencyCode} ')),
            ),
            const SizedBox(height: 12),
            _ExportTile(
              icon: Icons.table_chart_rounded,
              color: const Color(0xFF3B82F6),
              label: l10n.exportCsv,
              busy: _busy,
              onTap: () => _export((service, expenses, names) =>
                  service.shareCsv(
                      expenses: expenses,
                      categoryNames: names,
                      labels: _labels())),
            ),
            const SizedBox(height: 12),
            _ExportTile(
              icon: Icons.grid_on_rounded,
              color: const Color(0xFF22C55E),
              label: l10n.exportExcel,
              busy: _busy,
              onTap: () => _export((service, expenses, names) =>
                  service.shareExcel(
                      expenses: expenses,
                      categoryNames: names,
                      labels: _labels())),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExportTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final bool busy;
  final VoidCallback onTap;

  const _ExportTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.busy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: busy ? null : onTap,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          if (busy)
            const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2))
          else
            const Icon(Icons.ios_share_rounded, size: 20),
        ],
      ),
    );
  }
}
