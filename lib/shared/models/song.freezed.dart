// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'song.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Song {

 String get id; String get title; String get artist;@DurationSecondsConverter() Duration get duration; String? get album; String? get artworkUrl; String get source;// 'spotify' or 'apple'
 String? get spotifyId; String? get appleMusicId; String? get previewUrl;
/// Create a copy of Song
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SongCopyWith<Song> get copyWith => _$SongCopyWithImpl<Song>(this as Song, _$identity);

  /// Serializes this Song to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Song&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.album, album) || other.album == album)&&(identical(other.artworkUrl, artworkUrl) || other.artworkUrl == artworkUrl)&&(identical(other.source, source) || other.source == source)&&(identical(other.spotifyId, spotifyId) || other.spotifyId == spotifyId)&&(identical(other.appleMusicId, appleMusicId) || other.appleMusicId == appleMusicId)&&(identical(other.previewUrl, previewUrl) || other.previewUrl == previewUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,artist,duration,album,artworkUrl,source,spotifyId,appleMusicId,previewUrl);

@override
String toString() {
  return 'Song(id: $id, title: $title, artist: $artist, duration: $duration, album: $album, artworkUrl: $artworkUrl, source: $source, spotifyId: $spotifyId, appleMusicId: $appleMusicId, previewUrl: $previewUrl)';
}


}

/// @nodoc
abstract mixin class $SongCopyWith<$Res>  {
  factory $SongCopyWith(Song value, $Res Function(Song) _then) = _$SongCopyWithImpl;
@useResult
$Res call({
 String id, String title, String artist,@DurationSecondsConverter() Duration duration, String? album, String? artworkUrl, String source, String? spotifyId, String? appleMusicId, String? previewUrl
});




}
/// @nodoc
class _$SongCopyWithImpl<$Res>
    implements $SongCopyWith<$Res> {
  _$SongCopyWithImpl(this._self, this._then);

  final Song _self;
  final $Res Function(Song) _then;

/// Create a copy of Song
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? artist = null,Object? duration = null,Object? album = freezed,Object? artworkUrl = freezed,Object? source = null,Object? spotifyId = freezed,Object? appleMusicId = freezed,Object? previewUrl = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,artist: null == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,album: freezed == album ? _self.album : album // ignore: cast_nullable_to_non_nullable
as String?,artworkUrl: freezed == artworkUrl ? _self.artworkUrl : artworkUrl // ignore: cast_nullable_to_non_nullable
as String?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,spotifyId: freezed == spotifyId ? _self.spotifyId : spotifyId // ignore: cast_nullable_to_non_nullable
as String?,appleMusicId: freezed == appleMusicId ? _self.appleMusicId : appleMusicId // ignore: cast_nullable_to_non_nullable
as String?,previewUrl: freezed == previewUrl ? _self.previewUrl : previewUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Song].
extension SongPatterns on Song {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Song value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Song() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Song value)  $default,){
final _that = this;
switch (_that) {
case _Song():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Song value)?  $default,){
final _that = this;
switch (_that) {
case _Song() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String artist, @DurationSecondsConverter()  Duration duration,  String? album,  String? artworkUrl,  String source,  String? spotifyId,  String? appleMusicId,  String? previewUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Song() when $default != null:
return $default(_that.id,_that.title,_that.artist,_that.duration,_that.album,_that.artworkUrl,_that.source,_that.spotifyId,_that.appleMusicId,_that.previewUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String artist, @DurationSecondsConverter()  Duration duration,  String? album,  String? artworkUrl,  String source,  String? spotifyId,  String? appleMusicId,  String? previewUrl)  $default,) {final _that = this;
switch (_that) {
case _Song():
return $default(_that.id,_that.title,_that.artist,_that.duration,_that.album,_that.artworkUrl,_that.source,_that.spotifyId,_that.appleMusicId,_that.previewUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String artist, @DurationSecondsConverter()  Duration duration,  String? album,  String? artworkUrl,  String source,  String? spotifyId,  String? appleMusicId,  String? previewUrl)?  $default,) {final _that = this;
switch (_that) {
case _Song() when $default != null:
return $default(_that.id,_that.title,_that.artist,_that.duration,_that.album,_that.artworkUrl,_that.source,_that.spotifyId,_that.appleMusicId,_that.previewUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Song implements Song {
  const _Song({required this.id, required this.title, required this.artist, @DurationSecondsConverter() required this.duration, this.album, this.artworkUrl, required this.source, this.spotifyId, this.appleMusicId, this.previewUrl});
  factory _Song.fromJson(Map<String, dynamic> json) => _$SongFromJson(json);

@override final  String id;
@override final  String title;
@override final  String artist;
@override@DurationSecondsConverter() final  Duration duration;
@override final  String? album;
@override final  String? artworkUrl;
@override final  String source;
// 'spotify' or 'apple'
@override final  String? spotifyId;
@override final  String? appleMusicId;
@override final  String? previewUrl;

/// Create a copy of Song
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SongCopyWith<_Song> get copyWith => __$SongCopyWithImpl<_Song>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SongToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Song&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.album, album) || other.album == album)&&(identical(other.artworkUrl, artworkUrl) || other.artworkUrl == artworkUrl)&&(identical(other.source, source) || other.source == source)&&(identical(other.spotifyId, spotifyId) || other.spotifyId == spotifyId)&&(identical(other.appleMusicId, appleMusicId) || other.appleMusicId == appleMusicId)&&(identical(other.previewUrl, previewUrl) || other.previewUrl == previewUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,artist,duration,album,artworkUrl,source,spotifyId,appleMusicId,previewUrl);

@override
String toString() {
  return 'Song(id: $id, title: $title, artist: $artist, duration: $duration, album: $album, artworkUrl: $artworkUrl, source: $source, spotifyId: $spotifyId, appleMusicId: $appleMusicId, previewUrl: $previewUrl)';
}


}

/// @nodoc
abstract mixin class _$SongCopyWith<$Res> implements $SongCopyWith<$Res> {
  factory _$SongCopyWith(_Song value, $Res Function(_Song) _then) = __$SongCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String artist,@DurationSecondsConverter() Duration duration, String? album, String? artworkUrl, String source, String? spotifyId, String? appleMusicId, String? previewUrl
});




}
/// @nodoc
class __$SongCopyWithImpl<$Res>
    implements _$SongCopyWith<$Res> {
  __$SongCopyWithImpl(this._self, this._then);

  final _Song _self;
  final $Res Function(_Song) _then;

/// Create a copy of Song
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? artist = null,Object? duration = null,Object? album = freezed,Object? artworkUrl = freezed,Object? source = null,Object? spotifyId = freezed,Object? appleMusicId = freezed,Object? previewUrl = freezed,}) {
  return _then(_Song(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,artist: null == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,album: freezed == album ? _self.album : album // ignore: cast_nullable_to_non_nullable
as String?,artworkUrl: freezed == artworkUrl ? _self.artworkUrl : artworkUrl // ignore: cast_nullable_to_non_nullable
as String?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,spotifyId: freezed == spotifyId ? _self.spotifyId : spotifyId // ignore: cast_nullable_to_non_nullable
as String?,appleMusicId: freezed == appleMusicId ? _self.appleMusicId : appleMusicId // ignore: cast_nullable_to_non_nullable
as String?,previewUrl: freezed == previewUrl ? _self.previewUrl : previewUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
