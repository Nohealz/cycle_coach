// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'song_ref.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SongRef {

 String get songId; int get orderIndex;
/// Create a copy of SongRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SongRefCopyWith<SongRef> get copyWith => _$SongRefCopyWithImpl<SongRef>(this as SongRef, _$identity);

  /// Serializes this SongRef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SongRef&&(identical(other.songId, songId) || other.songId == songId)&&(identical(other.orderIndex, orderIndex) || other.orderIndex == orderIndex));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,songId,orderIndex);

@override
String toString() {
  return 'SongRef(songId: $songId, orderIndex: $orderIndex)';
}


}

/// @nodoc
abstract mixin class $SongRefCopyWith<$Res>  {
  factory $SongRefCopyWith(SongRef value, $Res Function(SongRef) _then) = _$SongRefCopyWithImpl;
@useResult
$Res call({
 String songId, int orderIndex
});




}
/// @nodoc
class _$SongRefCopyWithImpl<$Res>
    implements $SongRefCopyWith<$Res> {
  _$SongRefCopyWithImpl(this._self, this._then);

  final SongRef _self;
  final $Res Function(SongRef) _then;

/// Create a copy of SongRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? songId = null,Object? orderIndex = null,}) {
  return _then(_self.copyWith(
songId: null == songId ? _self.songId : songId // ignore: cast_nullable_to_non_nullable
as String,orderIndex: null == orderIndex ? _self.orderIndex : orderIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SongRef].
extension SongRefPatterns on SongRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SongRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SongRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SongRef value)  $default,){
final _that = this;
switch (_that) {
case _SongRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SongRef value)?  $default,){
final _that = this;
switch (_that) {
case _SongRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String songId,  int orderIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SongRef() when $default != null:
return $default(_that.songId,_that.orderIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String songId,  int orderIndex)  $default,) {final _that = this;
switch (_that) {
case _SongRef():
return $default(_that.songId,_that.orderIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String songId,  int orderIndex)?  $default,) {final _that = this;
switch (_that) {
case _SongRef() when $default != null:
return $default(_that.songId,_that.orderIndex);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SongRef implements SongRef {
  const _SongRef({required this.songId, required this.orderIndex});
  factory _SongRef.fromJson(Map<String, dynamic> json) => _$SongRefFromJson(json);

@override final  String songId;
@override final  int orderIndex;

/// Create a copy of SongRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SongRefCopyWith<_SongRef> get copyWith => __$SongRefCopyWithImpl<_SongRef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SongRefToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SongRef&&(identical(other.songId, songId) || other.songId == songId)&&(identical(other.orderIndex, orderIndex) || other.orderIndex == orderIndex));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,songId,orderIndex);

@override
String toString() {
  return 'SongRef(songId: $songId, orderIndex: $orderIndex)';
}


}

/// @nodoc
abstract mixin class _$SongRefCopyWith<$Res> implements $SongRefCopyWith<$Res> {
  factory _$SongRefCopyWith(_SongRef value, $Res Function(_SongRef) _then) = __$SongRefCopyWithImpl;
@override @useResult
$Res call({
 String songId, int orderIndex
});




}
/// @nodoc
class __$SongRefCopyWithImpl<$Res>
    implements _$SongRefCopyWith<$Res> {
  __$SongRefCopyWithImpl(this._self, this._then);

  final _SongRef _self;
  final $Res Function(_SongRef) _then;

/// Create a copy of SongRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? songId = null,Object? orderIndex = null,}) {
  return _then(_SongRef(
songId: null == songId ? _self.songId : songId // ignore: cast_nullable_to_non_nullable
as String,orderIndex: null == orderIndex ? _self.orderIndex : orderIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
