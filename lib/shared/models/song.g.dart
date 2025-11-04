// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Song _$SongFromJson(Map<String, dynamic> json) => _Song(
  id: json['id'] as String,
  title: json['title'] as String,
  artist: json['artist'] as String,
  duration: const DurationSecondsConverter().fromJson(
    (json['duration'] as num).toInt(),
  ),
  album: json['album'] as String?,
  artworkUrl: json['artworkUrl'] as String?,
  source: json['source'] as String,
  spotifyId: json['spotifyId'] as String?,
  appleMusicId: json['appleMusicId'] as String?,
  previewUrl: json['previewUrl'] as String?,
);

Map<String, dynamic> _$SongToJson(_Song instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'artist': instance.artist,
  'duration': const DurationSecondsConverter().toJson(instance.duration),
  'album': instance.album,
  'artworkUrl': instance.artworkUrl,
  'source': instance.source,
  'spotifyId': instance.spotifyId,
  'appleMusicId': instance.appleMusicId,
  'previewUrl': instance.previewUrl,
};
