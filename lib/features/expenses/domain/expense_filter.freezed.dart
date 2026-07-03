// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'expense_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ExpenseFilter {

 String get query; Set<String> get categoryIds; TimeFilter get timeFilter; DateTime? get customStart; DateTime? get customEnd; double? get minAmount; double? get maxAmount; SortOrder get sort; TransactionType? get type;
/// Create a copy of ExpenseFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpenseFilterCopyWith<ExpenseFilter> get copyWith => _$ExpenseFilterCopyWithImpl<ExpenseFilter>(this as ExpenseFilter, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExpenseFilter&&(identical(other.query, query) || other.query == query)&&const DeepCollectionEquality().equals(other.categoryIds, categoryIds)&&(identical(other.timeFilter, timeFilter) || other.timeFilter == timeFilter)&&(identical(other.customStart, customStart) || other.customStart == customStart)&&(identical(other.customEnd, customEnd) || other.customEnd == customEnd)&&(identical(other.minAmount, minAmount) || other.minAmount == minAmount)&&(identical(other.maxAmount, maxAmount) || other.maxAmount == maxAmount)&&(identical(other.sort, sort) || other.sort == sort)&&(identical(other.type, type) || other.type == type));
}


@override
int get hashCode => Object.hash(runtimeType,query,const DeepCollectionEquality().hash(categoryIds),timeFilter,customStart,customEnd,minAmount,maxAmount,sort,type);

@override
String toString() {
  return 'ExpenseFilter(query: $query, categoryIds: $categoryIds, timeFilter: $timeFilter, customStart: $customStart, customEnd: $customEnd, minAmount: $minAmount, maxAmount: $maxAmount, sort: $sort, type: $type)';
}


}

/// @nodoc
abstract mixin class $ExpenseFilterCopyWith<$Res>  {
  factory $ExpenseFilterCopyWith(ExpenseFilter value, $Res Function(ExpenseFilter) _then) = _$ExpenseFilterCopyWithImpl;
@useResult
$Res call({
 String query, Set<String> categoryIds, TimeFilter timeFilter, DateTime? customStart, DateTime? customEnd, double? minAmount, double? maxAmount, SortOrder sort, TransactionType? type
});




}
/// @nodoc
class _$ExpenseFilterCopyWithImpl<$Res>
    implements $ExpenseFilterCopyWith<$Res> {
  _$ExpenseFilterCopyWithImpl(this._self, this._then);

  final ExpenseFilter _self;
  final $Res Function(ExpenseFilter) _then;

/// Create a copy of ExpenseFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? query = null,Object? categoryIds = null,Object? timeFilter = null,Object? customStart = freezed,Object? customEnd = freezed,Object? minAmount = freezed,Object? maxAmount = freezed,Object? sort = null,Object? type = freezed,}) {
  return _then(_self.copyWith(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,categoryIds: null == categoryIds ? _self.categoryIds : categoryIds // ignore: cast_nullable_to_non_nullable
as Set<String>,timeFilter: null == timeFilter ? _self.timeFilter : timeFilter // ignore: cast_nullable_to_non_nullable
as TimeFilter,customStart: freezed == customStart ? _self.customStart : customStart // ignore: cast_nullable_to_non_nullable
as DateTime?,customEnd: freezed == customEnd ? _self.customEnd : customEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,minAmount: freezed == minAmount ? _self.minAmount : minAmount // ignore: cast_nullable_to_non_nullable
as double?,maxAmount: freezed == maxAmount ? _self.maxAmount : maxAmount // ignore: cast_nullable_to_non_nullable
as double?,sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as SortOrder,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType?,
  ));
}

}


/// Adds pattern-matching-related methods to [ExpenseFilter].
extension ExpenseFilterPatterns on ExpenseFilter {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExpenseFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExpenseFilter() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExpenseFilter value)  $default,){
final _that = this;
switch (_that) {
case _ExpenseFilter():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExpenseFilter value)?  $default,){
final _that = this;
switch (_that) {
case _ExpenseFilter() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String query,  Set<String> categoryIds,  TimeFilter timeFilter,  DateTime? customStart,  DateTime? customEnd,  double? minAmount,  double? maxAmount,  SortOrder sort,  TransactionType? type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExpenseFilter() when $default != null:
return $default(_that.query,_that.categoryIds,_that.timeFilter,_that.customStart,_that.customEnd,_that.minAmount,_that.maxAmount,_that.sort,_that.type);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String query,  Set<String> categoryIds,  TimeFilter timeFilter,  DateTime? customStart,  DateTime? customEnd,  double? minAmount,  double? maxAmount,  SortOrder sort,  TransactionType? type)  $default,) {final _that = this;
switch (_that) {
case _ExpenseFilter():
return $default(_that.query,_that.categoryIds,_that.timeFilter,_that.customStart,_that.customEnd,_that.minAmount,_that.maxAmount,_that.sort,_that.type);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String query,  Set<String> categoryIds,  TimeFilter timeFilter,  DateTime? customStart,  DateTime? customEnd,  double? minAmount,  double? maxAmount,  SortOrder sort,  TransactionType? type)?  $default,) {final _that = this;
switch (_that) {
case _ExpenseFilter() when $default != null:
return $default(_that.query,_that.categoryIds,_that.timeFilter,_that.customStart,_that.customEnd,_that.minAmount,_that.maxAmount,_that.sort,_that.type);case _:
  return null;

}
}

}

/// @nodoc


class _ExpenseFilter extends ExpenseFilter {
  const _ExpenseFilter({this.query = '', final  Set<String> categoryIds = const <String>{}, this.timeFilter = TimeFilter.all, this.customStart, this.customEnd, this.minAmount, this.maxAmount, this.sort = SortOrder.latest, this.type}): _categoryIds = categoryIds,super._();
  

@override@JsonKey() final  String query;
 final  Set<String> _categoryIds;
@override@JsonKey() Set<String> get categoryIds {
  if (_categoryIds is EqualUnmodifiableSetView) return _categoryIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_categoryIds);
}

@override@JsonKey() final  TimeFilter timeFilter;
@override final  DateTime? customStart;
@override final  DateTime? customEnd;
@override final  double? minAmount;
@override final  double? maxAmount;
@override@JsonKey() final  SortOrder sort;
@override final  TransactionType? type;

/// Create a copy of ExpenseFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExpenseFilterCopyWith<_ExpenseFilter> get copyWith => __$ExpenseFilterCopyWithImpl<_ExpenseFilter>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExpenseFilter&&(identical(other.query, query) || other.query == query)&&const DeepCollectionEquality().equals(other._categoryIds, _categoryIds)&&(identical(other.timeFilter, timeFilter) || other.timeFilter == timeFilter)&&(identical(other.customStart, customStart) || other.customStart == customStart)&&(identical(other.customEnd, customEnd) || other.customEnd == customEnd)&&(identical(other.minAmount, minAmount) || other.minAmount == minAmount)&&(identical(other.maxAmount, maxAmount) || other.maxAmount == maxAmount)&&(identical(other.sort, sort) || other.sort == sort)&&(identical(other.type, type) || other.type == type));
}


@override
int get hashCode => Object.hash(runtimeType,query,const DeepCollectionEquality().hash(_categoryIds),timeFilter,customStart,customEnd,minAmount,maxAmount,sort,type);

@override
String toString() {
  return 'ExpenseFilter(query: $query, categoryIds: $categoryIds, timeFilter: $timeFilter, customStart: $customStart, customEnd: $customEnd, minAmount: $minAmount, maxAmount: $maxAmount, sort: $sort, type: $type)';
}


}

/// @nodoc
abstract mixin class _$ExpenseFilterCopyWith<$Res> implements $ExpenseFilterCopyWith<$Res> {
  factory _$ExpenseFilterCopyWith(_ExpenseFilter value, $Res Function(_ExpenseFilter) _then) = __$ExpenseFilterCopyWithImpl;
@override @useResult
$Res call({
 String query, Set<String> categoryIds, TimeFilter timeFilter, DateTime? customStart, DateTime? customEnd, double? minAmount, double? maxAmount, SortOrder sort, TransactionType? type
});




}
/// @nodoc
class __$ExpenseFilterCopyWithImpl<$Res>
    implements _$ExpenseFilterCopyWith<$Res> {
  __$ExpenseFilterCopyWithImpl(this._self, this._then);

  final _ExpenseFilter _self;
  final $Res Function(_ExpenseFilter) _then;

/// Create a copy of ExpenseFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? query = null,Object? categoryIds = null,Object? timeFilter = null,Object? customStart = freezed,Object? customEnd = freezed,Object? minAmount = freezed,Object? maxAmount = freezed,Object? sort = null,Object? type = freezed,}) {
  return _then(_ExpenseFilter(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,categoryIds: null == categoryIds ? _self._categoryIds : categoryIds // ignore: cast_nullable_to_non_nullable
as Set<String>,timeFilter: null == timeFilter ? _self.timeFilter : timeFilter // ignore: cast_nullable_to_non_nullable
as TimeFilter,customStart: freezed == customStart ? _self.customStart : customStart // ignore: cast_nullable_to_non_nullable
as DateTime?,customEnd: freezed == customEnd ? _self.customEnd : customEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,minAmount: freezed == minAmount ? _self.minAmount : minAmount // ignore: cast_nullable_to_non_nullable
as double?,maxAmount: freezed == maxAmount ? _self.maxAmount : maxAmount // ignore: cast_nullable_to_non_nullable
as double?,sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as SortOrder,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType?,
  ));
}


}

// dart format on
