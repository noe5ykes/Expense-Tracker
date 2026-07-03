// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Category _$CategoryFromJson(Map<String, dynamic> json) => _Category(
  id: json['id'] as String,
  name: json['name'] as String,
  nameKey: json['nameKey'] as String?,
  icon: json['icon'] as String? ?? 'other',
  color: (json['color'] as num).toInt(),
  isIncome: json['isIncome'] as bool? ?? false,
  isDefault: json['isDefault'] as bool? ?? false,
);

Map<String, dynamic> _$CategoryToJson(_Category instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'nameKey': instance.nameKey,
  'icon': instance.icon,
  'color': instance.color,
  'isIncome': instance.isIncome,
  'isDefault': instance.isDefault,
};
