// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_ref.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SongRef _$SongRefFromJson(Map<String, dynamic> json) => _SongRef(
  songId: json['songId'] as String,
  orderIndex: (json['orderIndex'] as num).toInt(),
);

Map<String, dynamic> _$SongRefToJson(_SongRef instance) => <String, dynamic>{
  'songId': instance.songId,
  'orderIndex': instance.orderIndex,
};
