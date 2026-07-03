import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/utils/adaptive.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/utils/display.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/shimmer.dart';
import '../../settings/presentation/settings_providers.dart';
import '../domain/bill.dart';

class BillsScreen extends ConsumerWidget {
  const BillsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final billsAsync = ref.watch(billsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.upcomingBills)),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'bills-fab',
        onPressed: () => _showForm(context, null),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.addBill),
      ),
      body: SafeArea(
        child: billsAsync.when(
          loading: () => const ListShimmer(),
          error: (e, _) => EmptyState(
              icon: Icons.error_outline_rounded,
              title: l10n.somethingWentWrong),
          data: (bills) {
            final pending = bills.where((b) => !b.paid).toList();
            if (pending.isEmpty) {
              return EmptyState(
                icon: Icons.event_available_rounded,
                title: l10n.noBills,
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
              itemCount: pending.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _BillCard(bill: pending[index]),
            );
          },
        ),
      ),
    );
  }

  static void _showForm(BuildContext context, Bill? bill) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _BillFormSheet(bill: bill),
    );
  }
}

class _BillCard extends ConsumerWidget {
  final Bill bill;
  const _BillCard({required this.bill});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final currency = ref.watch(settingsProvider).currencyCode;
    final locale = Localizations.localeOf(context).toString();

    final today = DateTime.now();
    final daysLeft = DateTime(bill.dueDate.year, bill.dueDate.month,
            bill.dueDate.day)
        .difference(DateTime(today.year, today.month, today.day))
        .inDays;
    final overdue = daysLeft < 0;
    final chipColor = overdue
        ? scheme.error
        : daysLeft <= 2
            ? const Color(0xFFF59E0B)
            : scheme.primary;
    final chipLabel = overdue
        ? l10n.overdue
        : daysLeft == 0
            ? l10n.dueToday
            : l10n.dueInDays(daysLeft);

    return AppCard(
      onTap: () => BillsScreen._showForm(context, bill),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: scheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.receipt_long_rounded,
                    color: scheme.onTertiaryContainer),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(bill.title,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(
                      '${Formatters.date(bill.dueDate, locale: locale)} · ${recurrenceLabel(context, bill.recurrence)}',
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
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: chipColor.withValues(alpha: .13),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(chipLabel,
                    style: TextStyle(
                        color: chipColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12)),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () async {
                  await ref.read(billRepositoryProvider).markPaid(bill);
                  await NotificationService.instance
                      .cancelBillReminder(bill.id);
                  successHaptic();
                },
                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                label: Text(l10n.markPaid),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded,
                    size: 20, color: scheme.error),
                tooltip: l10n.delete,
                onPressed: () async {
                  final confirmed = await showConfirmDialog(
                    context,
                    title: l10n.deleteBill,
                    message: l10n.deleteBillConfirm,
                    confirmLabel: l10n.delete,
                    cancelLabel: l10n.cancel,
                    destructive: true,
                  );
                  if (!confirmed) return;
                  await ref.read(billRepositoryProvider).delete(bill.id);
                  await NotificationService.instance
                      .cancelBillReminder(bill.id);
                  if (context.mounted) {
                    showAppSnackBar(context, l10n.billDeleted);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BillFormSheet extends ConsumerStatefulWidget {
  final Bill? bill;
  const _BillFormSheet({this.bill});

  @override
  ConsumerState<_BillFormSheet> createState() => _BillFormSheetState();
}

class _BillFormSheetState extends ConsumerState<_BillFormSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late DateTime _dueDate;
  late BillRecurrence _recurrence;

  @override
  void initState() {
    super.initState();
    final b = widget.bill;
    _titleController = TextEditingController(text: b?.title ?? '');
    _amountController = TextEditingController(
        text: b == null ? '' : b.amount.toStringAsFixed(0));
    _dueDate = b?.dueDate ?? DateTime.now().add(const Duration(days: 7));
    _recurrence = b?.recurrence ?? BillRecurrence.monthly;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final title = _titleController.text.trim();
    final amount =
        double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (title.isEmpty) {
      showAppSnackBar(context, l10n.titleRequired);
      return;
    }
    if (amount == null || amount <= 0) {
      showAppSnackBar(context, l10n.invalidAmount);
      return;
    }
    final bill = Bill(
      id: widget.bill?.id ?? const Uuid().v4(),
      title: title,
      amount: amount,
      dueDate: _dueDate,
      recurrence: _recurrence,
    );
    final repo = ref.read(billRepositoryProvider);
    if (widget.bill == null) {
      await repo.add(bill);
    } else {
      await repo.update(bill);
    }
    if (ref.read(settingsProvider).billReminders) {
      await NotificationService.instance.scheduleBillReminder(
        billId: bill.id,
        dueDate: bill.dueDate,
        title: l10n.billReminderTitle,
        body: l10n.billReminderBody(bill.title),
      );
    }
    if (!mounted) return;
    successHaptic();
    showAppSnackBar(context, l10n.billSaved);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final isEdit = widget.bill != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 4, 24, 24 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(isEdit ? l10n.editBill : l10n.addBill,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          TextField(
            controller: _titleController,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: l10n.billName),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: l10n.amount),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () async {
              final picked = await showAdaptiveDatePicker(context,
                  initialDate: _dueDate);
              if (picked != null) setState(() => _dueDate = picked);
            },
            borderRadius: BorderRadius.circular(16),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: l10n.dueDate,
                prefixIcon: const Icon(Icons.event_rounded),
              ),
              child: Text(Formatters.date(_dueDate, locale: locale),
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<BillRecurrence>(
            initialValue: _recurrence,
            decoration: InputDecoration(labelText: l10n.recurrence),
            items: [
              for (final recurrence in BillRecurrence.values)
                DropdownMenuItem(
                  value: recurrence,
                  child: Text(recurrenceLabel(context, recurrence)),
                ),
            ],
            onChanged: (v) =>
                setState(() => _recurrence = v ?? _recurrence),
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: _save, child: Text(l10n.save)),
        ],
      ),
    );
  }
}
