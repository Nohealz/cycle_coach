// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'class_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClassModel {

 String get id; String get name; DateTime get createdAt; DateTime get updatedAt; List<SongRef> get prePlaylist; List<SongRef> get workoutPlaylist; List<SongRef> get postPlaylist; bool get shufflePre; bool get shufflePost;
/// Create a copy of ClassModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClassModelCopyWith<ClassModel> get copyWith => _$ClassModelCopyWithImpl<ClassModel>(this as ClassModel, _$identity);

  /// Serializes this ClassModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClassModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.prePlaylist, prePlaylist)&&const DeepCollectionEquality().equals(other.workoutPlaylist, workoutPlaylist)&&const DeepCollectionEquality().equals(other.postPlaylist, postPlaylist)&&(identical(other.shufflePre, shufflePre) || other.shufflePre == shufflePre)&&(identical(other.shufflePost, shufflePost) || other.shufflePost == shufflePost));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,createdAt,updatedAt,const DeepCollectionEquality().hash(prePlaylist),const DeepCollectionEquality().hash(workoutPlaylist),const DeepCollectionEquality().hash(postPlaylist),shufflePre,shufflePost);

@override
String toString() {
  return 'ClassModel(id: $id, name: $name, createdAt: $createdAt, updatedAt: $updatedAt, prePlaylist: $prePlaylist, workoutPlaylist: $workoutPlaylist, postPlaylist: $postPlaylist, shufflePre: $shufflePre, shufflePost: $shufflePost)';
}


}

/// @nodoc
abstract mixin class $ClassModelCopyWith<$Res>  {
  factory $ClassModelCopyWith(ClassModel value, $Res Function(ClassModel) _then) = _$ClassModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, DateTime createdAt, DateTime updatedAt, List<SongRef> prePlaylist, List<SongRef> workoutPlaylist, List<SongRef> postPlaylist, bool shufflePre, bool shufflePost
});




}
/// @nodoc
class _$ClassModelCopyWithImpl<$Res>
    implements $ClassModelCopyWith<$Res> {
  _$ClassModelCopyWithImpl(this._self, this._then);

  final ClassModel _self;
  final $Res Function(ClassModel) _then;

/// Create a copy of ClassModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? createdAt = null,Object? updatedAt = null,Object? prePlaylist = null,Object? workoutPlaylist = null,Object? postPlaylist = null,Object? shufflePre = null,Object? shufflePost = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,prePlaylist: null == prePlaylist ? _self.prePlaylist : prePlaylist // ignore: cast_nullable_to_non_nullable
as List<SongRef>,workoutPlaylist: null == workoutPlaylist ? _self.workoutPlaylist : workoutPlaylist // ignore: cast_nullable_to_non_nullable
as List<SongRef>,postPlaylist: null == postPlaylist ? _self.postPlaylist : postPlaylist // ignore: cast_nullable_to_non_nullable
as List<SongRef>,shufflePre: null == shufflePre ? _self.shufflePre : shufflePre // ignore: cast_nullable_to_non_nullable
as bool,shufflePost: null == shufflePost ? _self.shufflePost : shufflePost // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ClassModel].
extension ClassModelPatterns on ClassModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClassModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClassModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClassModel value)  $default,){
final _that = this;
switch (_that) {
case _ClassModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClassModel value)?  $default,){
final _that = this;
switch (_that) {
case _ClassModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  DateTime createdAt,  DateTime updatedAt,  List<SongRef> prePlaylist,  List<SongRef> workoutPlaylist,  List<SongRef> postPlaylist,  bool shufflePre,  bool shufflePost)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClassModel() when $default != null:
return $default(_that.id,_that.name,_that.createdAt,_that.updatedAt,_that.prePlaylist,_that.workoutPlaylist,_that.postPlaylist,_that.shufflePre,_that.shufflePost);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  DateTime createdAt,  DateTime updatedAt,  List<SongRef> prePlaylist,  List<SongRef> workoutPlaylist,  List<SongRef> postPlaylist,  bool shufflePre,  bool shufflePost)  $default,) {final _that = this;
switch (_that) {
case _ClassModel():
return $default(_that.id,_that.name,_that.createdAt,_that.updatedAt,_that.prePlaylist,_that.workoutPlaylist,_that.postPlaylist,_that.shufflePre,_that.shufflePost);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  DateTime createdAt,  DateTime updatedAt,  List<SongRef> prePlaylist,  List<SongRef> workoutPlaylist,  List<SongRef> postPlaylist,  bool shufflePre,  bool shufflePost)?  $default,) {final _that = this;
switch (_that) {
case _ClassModel() when $default != null:
return $default(_that.id,_that.name,_that.createdAt,_that.updatedAt,_that.prePlaylist,_that.workoutPlaylist,_that.postPlaylist,_that.shufflePre,_that.shufflePost);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClassModel implements ClassModel {
  const _ClassModel({required this.id, required this.name, required this.createdAt, required this.updatedAt, required final  List<SongRef> prePlaylist, required final  List<SongRef> workoutPlaylist, required final  List<SongRef> postPlaylist, required this.shufflePre, required this.shufflePost}): _prePlaylist = prePlaylist,_workoutPlaylist = workoutPlaylist,_postPlaylist = postPlaylist;
  factory _ClassModel.fromJson(Map<String, dynamic> json) => _$ClassModelFromJson(json);

@override final  String id;
@override final  String name;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
 final  List<SongRef> _prePlaylist;
@override List<SongRef> get prePlaylist {
  if (_prePlaylist is EqualUnmodifiableListView) return _prePlaylist;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_prePlaylist);
}

 final  List<SongRef> _workoutPlaylist;
@override List<SongRef> get workoutPlaylist {
  if (_workoutPlaylist is EqualUnmodifiableListView) return _workoutPlaylist;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_workoutPlaylist);
}

 final  List<SongRef> _postPlaylist;
@override List<SongRef> get postPlaylist {
  if (_postPlaylist is EqualUnmodifiableListView) return _postPlaylist;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_postPlaylist);
}

@override final  bool shufflePre;
@override final  bool shufflePost;

/// Create a copy of ClassModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClassModelCopyWith<_ClassModel> get copyWith => __$ClassModelCopyWithImpl<_ClassModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClassModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClassModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._prePlaylist, _prePlaylist)&&const DeepCollectionEquality().equals(other._workoutPlaylist, _workoutPlaylist)&&const DeepCollectionEquality().equals(other._postPlaylist, _postPlaylist)&&(identical(other.shufflePre, shufflePre) || other.shufflePre == shufflePre)&&(identical(other.shufflePost, shufflePost) || other.shufflePost == shufflePost));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,createdAt,updatedAt,const DeepCollectionEquality().hash(_prePlaylist),const DeepCollectionEquality().hash(_workoutPlaylist),const DeepCollectionEquality().hash(_postPlaylist),shufflePre,shufflePost);

@override
String toString() {
  return 'ClassModel(id: $id, name: $name, createdAt: $createdAt, updatedAt: $updatedAt, prePlaylist: $prePlaylist, workoutPlaylist: $workoutPlaylist, postPlaylist: $postPlaylist, shufflePre: $shufflePre, shufflePost: $shufflePost)';
}


}

/// @nodoc
abstract mixin class _$ClassModelCopyWith<$Res> implements $ClassModelCopyWith<$Res> {
  factory _$ClassModelCopyWith(_ClassModel value, $Res Function(_ClassModel) _then) = __$ClassModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, DateTime createdAt, DateTime updatedAt, List<SongRef> prePlaylist, List<SongRef> workoutPlaylist, List<SongRef> postPlaylist, bool shufflePre, bool shufflePost
});




}
/// @nodoc
class __$ClassModelCopyWithImpl<$Res>
    implements _$ClassModelCopyWith<$Res> {
  __$ClassModelCopyWithImpl(this._self, this._then);

  final _ClassModel _self;
  final $Res Function(_ClassModel) _then;

/// Create a copy of ClassModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? createdAt = null,Object? updatedAt = null,Object? prePlaylist = null,Object? workoutPlaylist = null,Object? postPlaylist = null,Object? shufflePre = null,Object? shufflePost = null,}) {
  return _then(_ClassModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,prePlaylist: null == prePlaylist ? _self._prePlaylist : prePlaylist // ignore: cast_nullable_to_non_nullable
as List<SongRef>,workoutPlaylist: null == workoutPlaylist ? _self._workoutPlaylist : workoutPlaylist // ignore: cast_nullable_to_non_nullable
as List<SongRef>,postPlaylist: null == postPlaylist ? _self._postPlaylist : postPlaylist // ignore: cast_nullable_to_non_nullable
as List<SongRef>,shufflePre: null == shufflePre ? _self.shufflePre : shufflePre // ignore: cast_nullable_to_non_nullable
as bool,shufflePost: null == shufflePost ? _self.shufflePost : shufflePost // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
