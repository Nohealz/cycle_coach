// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClassModel _$ClassModelFromJson(Map<String, dynamic> json) => _ClassModel(
  id: json['id'] as String,
  name: json['name'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  prePlaylist: (json['prePlaylist'] as List<dynamic>)
      .map((e) => SongRef.fromJson(e as Map<String, dynamic>))
      .toList(),
  workoutPlaylist: (json['workoutPlaylist'] as List<dynamic>)
      .map((e) => SongRef.fromJson(e as Map<String, dynamic>))
      .toList(),
  postPlaylist: (json['postPlaylist'] as List<dynamic>)
      .map((e) => SongRef.fromJson(e as Map<String, dynamic>))
      .toList(),
  shufflePre: json['shufflePre'] as bool,
  shufflePost: json['shufflePost'] as bool,
);

Map<String, dynamic> _$ClassModelToJson(_ClassModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'prePlaylist': instance.prePlaylist,
      'workoutPlaylist': instance.workoutPlaylist,
      'postPlaylist': instance.postPlaylist,
      'shufflePre': instance.shufflePre,
      'shufflePost': instance.shufflePost,
    };
