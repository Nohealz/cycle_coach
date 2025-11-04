// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cue_card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CueCard _$CueCardFromJson(Map<String, dynamic> json) => _CueCard(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  offset: const DurationSecondsConverter().fromJson(
    (json['offset'] as num).toInt(),
  ),
  duration: _$JsonConverterFromJson<int, Duration>(
    json['duration'],
    const DurationSecondsConverter().fromJson,
  ),
);

Map<String, dynamic> _$CueCardToJson(_CueCard instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'offset': const DurationSecondsConverter().toJson(instance.offset),
  'duration': _$JsonConverterToJson<int, Duration>(
    instance.duration,
    const DurationSecondsConverter().toJson,
  ),
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
