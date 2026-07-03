import 'package:flutter/widgets.dart';

import '../../core/l10n/l10n_ext.dart';
import '../../features/bills/domain/bill.dart';
import '../../features/expenses/domain/category.dart';
import '../../features/expenses/domain/expense.dart';
import '../../features/expenses/domain/expense_filter.dart';

/// Localized display names for domain values.
String categoryName(BuildContext context, Category category) {
  final l10n = context.l10n;
  return switch (category.nameKey) {
    'food' => l10n.catFood,
    'grocery' => l10n.catGrocery,
    'fuel' => l10n.catFuel,
    'shopping' => l10n.catShopping,
    'travel' => l10n.catTravel,
    'medical' => l10n.catMedical,
    'education' => l10n.catEducation,
    'entertainment' => l10n.catEntertainment,
    'utilities' => l10n.catUtilities,
    'bills' => l10n.catBills,
    'salary' => l10n.catSalary,
    'investments' => l10n.catInvestments,
    'other' => l10n.catOther,
    _ => category.name,
  };
}

String paymentMethodLabel(BuildContext context, PaymentMethod method) {
  final l10n = context.l10n;
  return switch (method) {
    PaymentMethod.cash => l10n.cash,
    PaymentMethod.card => l10n.card,
    PaymentMethod.upi => l10n.upi,
    PaymentMethod.bankTransfer => l10n.bankTransfer,
    PaymentMethod.wallet => l10n.wallet,
    PaymentMethod.other => l10n.otherMethod,
  };
}

String timeFilterLabel(BuildContext context, TimeFilter filter) {
  final l10n = context.l10n;
  return switch (filter) {
    TimeFilter.all => l10n.all,
    TimeFilter.today => l10n.today,
    TimeFilter.week => l10n.thisWeek,
    TimeFilter.month => l10n.thisMonth,
    TimeFilter.year => l10n.thisYear,
    TimeFilter.custom => l10n.customRange,
  };
}

String sortOrderLabel(BuildContext context, SortOrder sort) {
  final l10n = context.l10n;
  return switch (sort) {
    SortOrder.latest => l10n.latest,
    SortOrder.oldest => l10n.oldest,
    SortOrder.highestAmount => l10n.highestAmount,
    SortOrder.lowestAmount => l10n.lowestAmount,
  };
}

String recurrenceLabel(BuildContext context, BillRecurrence recurrence) {
  final l10n = context.l10n;
  return switch (recurrence) {
    BillRecurrence.oneTime => l10n.oneTime,
    BillRecurrence.weekly => l10n.weekly,
    BillRecurrence.monthly => l10n.monthly,
    BillRecurrence.yearly => l10n.yearly,
  };
}

String greeting(BuildContext context, DateTime now) {
  final l10n = context.l10n;
  if (now.hour < 12) return l10n.greetingMorning;
  if (now.hour < 17) return l10n.greetingAfternoon;
  return l10n.greetingEvening;
}
