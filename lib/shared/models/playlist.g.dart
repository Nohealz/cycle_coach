// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Playlist _$PlaylistFromJson(Map<String, dynamic> json) => _Playlist(
  id: json['id'] as String,
  name: json['name'] as String,
  songs:
      (json['songs'] as List<dynamic>?)
          ?.map((e) => Song.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Song>[],
  cuesBySongId:
      (json['cuesBySongId'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
          k,
          (e as List<dynamic>)
              .map((e) => CueCard.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      ) ??
      const <String, List<CueCard>>{},
);

Map<String, dynamic> _$PlaylistToJson(_Playlist instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'songs': instance.songs,
  'cuesBySongId': instance.cuesBySongId,
};
