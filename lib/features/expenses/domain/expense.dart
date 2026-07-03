import 'package:freezed_annotation/freezed_annotation.dart';

part 'expense.freezed.dart';
part 'expense.g.dart';

enum TransactionType { expense, income }

enum PaymentMethod { cash, card, upi, bankTransfer, wallet, other }

/// A single transaction (expense or income). Immutable domain entity —
/// persistence is handled by repositories, keeping this model storage- and
/// sync-agnostic for future Firebase/Supabase backends.
@freezed
abstract class Expense with _$Expense {
  const factory Expense({
    required String id,
    required String title,
    required double amount,
    required String categoryId,
    required DateTime date,
    @Default(TransactionType.expense) TransactionType type,
    @Default(PaymentMethod.cash) PaymentMethod paymentMethod,
    @Default('') String notes,
    @Default(<String>[]) List<String> tags,
    @Default('INR') String currency,
    @Default(<String>[]) List<String> receiptPaths,
    String? location,
  }) = _Expense;

  factory Expense.fromJson(Map<String, dynamic> json) =>
      _$ExpenseFromJson(json);
}
