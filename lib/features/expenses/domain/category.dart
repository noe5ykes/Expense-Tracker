import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';
part 'category.g.dart';

/// An expense/income category. Default categories carry a `nameKey` that maps
/// to a localized string; user-created ones use `name` verbatim.
@freezed
abstract class Category with _$Category {
  const factory Category({
    required String id,
    required String name,
    String? nameKey,
    @Default('other') String icon,
    required int color,
    @Default(false) bool isIncome,
    @Default(false) bool isDefault,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
}
