// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Bill _$BillFromJson(Map<String, dynamic> json) => _Bill(
  id: json['id'] as String,
  title: json['title'] as String,
  amount: (json['amount'] as num).toDouble(),
  dueDate: DateTime.parse(json['dueDate'] as String),
  recurrence:
      $enumDecodeNullable(_$BillRecurrenceEnumMap, json['recurrence']) ??
      BillRecurrence.monthly,
  paid: json['paid'] as bool? ?? false,
);

Map<String, dynamic> _$BillToJson(_Bill instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'amount': instance.amount,
  'dueDate': instance.dueDate.toIso8601String(),
  'recurrence': _$BillRecurrenceEnumMap[instance.recurrence]!,
  'paid': instance.paid,
};

const _$BillRecurrenceEnumMap = {
  BillRecurrence.oneTime: 'oneTime',
  BillRecurrence.weekly: 'weekly',
  BillRecurrence.monthly: 'monthly',
  BillRecurrence.yearly: 'yearly',
};
