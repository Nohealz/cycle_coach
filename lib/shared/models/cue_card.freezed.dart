// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cue_card.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CueCard {

 String get id; String get title; String? get description;@DurationSecondsConverter() Duration get offset;@DurationSecondsConverter() Duration? get duration;
/// Create a copy of CueCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CueCardCopyWith<CueCard> get copyWith => _$CueCardCopyWithImpl<CueCard>(this as CueCard, _$identity);

  /// Serializes this CueCard to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CueCard&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.offset, offset) || other.offset == offset)&&(identical(other.duration, duration) || other.duration == duration));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,offset,duration);

@override
String toString() {
  return 'CueCard(id: $id, title: $title, description: $description, offset: $offset, duration: $duration)';
}


}

/// @nodoc
abstract mixin class $CueCardCopyWith<$Res>  {
  factory $CueCardCopyWith(CueCard value, $Res Function(CueCard) _then) = _$CueCardCopyWithImpl;
@useResult
$Res call({
 String id, String title, String? description,@DurationSecondsConverter() Duration offset,@DurationSecondsConverter() Duration? duration
});




}
/// @nodoc
class _$CueCardCopyWithImpl<$Res>
    implements $CueCardCopyWith<$Res> {
  _$CueCardCopyWithImpl(this._self, this._then);

  final CueCard _self;
  final $Res Function(CueCard) _then;

/// Create a copy of CueCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? offset = null,Object? duration = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,offset: null == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as Duration,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration?,
  ));
}

}


/// Adds pattern-matching-related methods to [CueCard].
extension CueCardPatterns on CueCard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CueCard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CueCard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CueCard value)  $default,){
final _that = this;
switch (_that) {
case _CueCard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CueCard value)?  $default,){
final _that = this;
switch (_that) {
case _CueCard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String? description, @DurationSecondsConverter()  Duration offset, @DurationSecondsConverter()  Duration? duration)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CueCard() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.offset,_that.duration);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String? description, @DurationSecondsConverter()  Duration offset, @DurationSecondsConverter()  Duration? duration)  $default,) {final _that = this;
switch (_that) {
case _CueCard():
return $default(_that.id,_that.title,_that.description,_that.offset,_that.duration);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String? description, @DurationSecondsConverter()  Duration offset, @DurationSecondsConverter()  Duration? duration)?  $default,) {final _that = this;
switch (_that) {
case _CueCard() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.offset,_that.duration);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CueCard implements CueCard {
  const _CueCard({required this.id, required this.title, this.description, @DurationSecondsConverter() required this.offset, @DurationSecondsConverter() this.duration});
  factory _CueCard.fromJson(Map<String, dynamic> json) => _$CueCardFromJson(json);

@override final  String id;
@override final  String title;
@override final  String? description;
@override@DurationSecondsConverter() final  Duration offset;
@override@DurationSecondsConverter() final  Duration? duration;

/// Create a copy of CueCard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CueCardCopyWith<_CueCard> get copyWith => __$CueCardCopyWithImpl<_CueCard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CueCardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CueCard&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.offset, offset) || other.offset == offset)&&(identical(other.duration, duration) || other.duration == duration));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,offset,duration);

@override
String toString() {
  return 'CueCard(id: $id, title: $title, description: $description, offset: $offset, duration: $duration)';
}


}

/// @nodoc
abstract mixin class _$CueCardCopyWith<$Res> implements $CueCardCopyWith<$Res> {
  factory _$CueCardCopyWith(_CueCard value, $Res Function(_CueCard) _then) = __$CueCardCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String? description,@DurationSecondsConverter() Duration offset,@DurationSecondsConverter() Duration? duration
});




}
/// @nodoc
class __$CueCardCopyWithImpl<$Res>
    implements _$CueCardCopyWith<$Res> {
  __$CueCardCopyWithImpl(this._self, this._then);

  final _CueCard _self;
  final $Res Function(_CueCard) _then;

/// Create a copy of CueCard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? offset = null,Object? duration = freezed,}) {
  return _then(_CueCard(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,offset: null == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as Duration,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration?,
  ));
}


}

// dart format on
