import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget.freezed.dart';
part 'budget.g.dart';

/// A recurring monthly spending limit. `categoryId == null` represents the
/// overall monthly budget.
@freezed
abstract class Budget with _$Budget {
  const factory Budget({
    required String id,
    String? categoryId,
    required double amount,
  }) = _Budget;

  factory Budget.fromJson(Map<String, dynamic> json) => _$BudgetFromJson(json);
}

/// Progress of [budget] given the amount spent this month. Pure — unit tested.
class BudgetProgress {
  final Budget budget;
  final double spent;
  const BudgetProgress({required this.budget, required this.spent});

  double get fraction =>
      budget.amount <= 0 ? 0 : (spent / budget.amount).clamp(0, double.infinity);
  double get remaining => budget.amount - spent;
  bool get isExceeded => spent > budget.amount;
  bool get isNearLimit => !isExceeded && fraction >= 0.8;
}
