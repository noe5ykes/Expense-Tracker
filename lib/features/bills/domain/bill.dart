import 'package:freezed_annotation/freezed_annotation.dart';

part 'bill.freezed.dart';
part 'bill.g.dart';

enum BillRecurrence { oneTime, weekly, monthly, yearly }

/// An upcoming/recurring bill used for reminders and the dashboard.
@freezed
abstract class Bill with _$Bill {
  const Bill._();

  const factory Bill({
    required String id,
    required String title,
    required double amount,
    required DateTime dueDate,
    @Default(BillRecurrence.monthly) BillRecurrence recurrence,
    @Default(false) bool paid,
  }) = _Bill;

  factory Bill.fromJson(Map<String, dynamic> json) => _$BillFromJson(json);

  /// The due date that follows [dueDate] according to [recurrence], or null
  /// for one-time bills. Pure — unit tested.
  DateTime? get nextDueDate => switch (recurrence) {
        BillRecurrence.oneTime => null,
        BillRecurrence.weekly => dueDate.add(const Duration(days: 7)),
        BillRecurrence.monthly =>
          DateTime(dueDate.year, dueDate.month + 1, dueDate.day),
        BillRecurrence.yearly =>
          DateTime(dueDate.year + 1, dueDate.month, dueDate.day),
      };
}
