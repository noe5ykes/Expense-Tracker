// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Expense _$ExpenseFromJson(Map<String, dynamic> json) => _Expense(
  id: json['id'] as String,
  title: json['title'] as String,
  amount: (json['amount'] as num).toDouble(),
  categoryId: json['categoryId'] as String,
  date: DateTime.parse(json['date'] as String),
  type:
      $enumDecodeNullable(_$TransactionTypeEnumMap, json['type']) ??
      TransactionType.expense,
  paymentMethod:
      $enumDecodeNullable(_$PaymentMethodEnumMap, json['paymentMethod']) ??
      PaymentMethod.cash,
  notes: json['notes'] as String? ?? '',
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  currency: json['currency'] as String? ?? 'INR',
  receiptPaths:
      (json['receiptPaths'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  location: json['location'] as String?,
);

Map<String, dynamic> _$ExpenseToJson(_Expense instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'amount': instance.amount,
  'categoryId': instance.categoryId,
  'date': instance.date.toIso8601String(),
  'type': _$TransactionTypeEnumMap[instance.type]!,
  'paymentMethod': _$PaymentMethodEnumMap[instance.paymentMethod]!,
  'notes': instance.notes,
  'tags': instance.tags,
  'currency': instance.currency,
  'receiptPaths': instance.receiptPaths,
  'location': instance.location,
};

const _$TransactionTypeEnumMap = {
  TransactionType.expense: 'expense',
  TransactionType.income: 'income',
};

const _$PaymentMethodEnumMap = {
  PaymentMethod.cash: 'cash',
  PaymentMethod.card: 'card',
  PaymentMethod.upi: 'upi',
  PaymentMethod.bankTransfer: 'bankTransfer',
  PaymentMethod.wallet: 'wallet',
  PaymentMethod.other: 'other',
};
