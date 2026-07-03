import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/utils/date_ranges.dart';
import 'expense.dart';

part 'expense_filter.freezed.dart';

enum TimeFilter { all, today, week, month, year, custom }

enum SortOrder { latest, oldest, highestAmount, lowestAmount }

/// Search/filter/sort criteria for the expense list.
@freezed
abstract class ExpenseFilter with _$ExpenseFilter {
  const ExpenseFilter._();

  const factory ExpenseFilter({
    @Default('') String query,
    @Default(<String>{}) Set<String> categoryIds,
    @Default(TimeFilter.all) TimeFilter timeFilter,
    DateTime? customStart,
    DateTime? customEnd,
    double? minAmount,
    double? maxAmount,
    @Default(SortOrder.latest) SortOrder sort,
    TransactionType? type,
  }) = _ExpenseFilter;

  bool get isActive =>
      categoryIds.isNotEmpty ||
      timeFilter != TimeFilter.all ||
      minAmount != null ||
      maxAmount != null ||
      type != null;
}

/// Pure filtering/sorting logic — unit tested.
List<Expense> applyExpenseFilter(List<Expense> all, ExpenseFilter filter,
    {DateTime? now}) {
  final reference = now ?? DateTime.now();
  DateTime? start;
  DateTime? end;
  switch (filter.timeFilter) {
    case TimeFilter.all:
      break;
    case TimeFilter.today:
      start = DateRanges.startOfDay(reference);
      end = DateRanges.endOfDay(reference);
    case TimeFilter.week:
      start = DateRanges.startOfWeek(reference);
      end = DateRanges.endOfDay(reference);
    case TimeFilter.month:
      start = DateRanges.startOfMonth(reference);
      end = DateRanges.endOfMonth(reference);
    case TimeFilter.year:
      start = DateRanges.startOfYear(reference);
      end = DateRanges.endOfYear(reference);
    case TimeFilter.custom:
      start = filter.customStart != null
          ? DateRanges.startOfDay(filter.customStart!)
          : null;
      end = filter.customEnd != null
          ? DateRanges.endOfDay(filter.customEnd!)
          : null;
  }

  final query = filter.query.trim().toLowerCase();
  final tagQuery = query.startsWith('#') ? query.substring(1) : null;

  final result = all.where((e) {
    if (start != null && e.date.isBefore(start)) return false;
    if (end != null && e.date.isAfter(end)) return false;
    if (filter.categoryIds.isNotEmpty &&
        !filter.categoryIds.contains(e.categoryId)) {
      return false;
    }
    if (filter.minAmount != null && e.amount < filter.minAmount!) return false;
    if (filter.maxAmount != null && e.amount > filter.maxAmount!) return false;
    if (filter.type != null && e.type != filter.type) return false;
    if (query.isNotEmpty) {
      if (tagQuery != null) {
        return e.tags.any((t) => t.toLowerCase().contains(tagQuery));
      }
      final haystack = '${e.title} ${e.notes} ${e.tags.join(' ')} '
              '${e.amount.toStringAsFixed(2)}'
          .toLowerCase();
      if (!haystack.contains(query)) return false;
    }
    return true;
  }).toList();

  switch (filter.sort) {
    case SortOrder.latest:
      result.sort((a, b) => b.date.compareTo(a.date));
    case SortOrder.oldest:
      result.sort((a, b) => a.date.compareTo(b.date));
    case SortOrder.highestAmount:
      result.sort((a, b) => b.amount.compareTo(a.amount));
    case SortOrder.lowestAmount:
      result.sort((a, b) => a.amount.compareTo(b.amount));
  }
  return result;
}
