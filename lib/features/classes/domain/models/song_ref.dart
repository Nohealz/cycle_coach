import 'package:freezed_annotation/freezed_annotation.dart';

part 'song_ref.freezed.dart';
part 'song_ref.g.dart';

@freezed
abstract class SongRef with _$SongRef {
  const factory SongRef({
    required String songId,
    required int orderIndex,
  }) = _SongRef;

  factory SongRef.fromJson(Map<String, dynamic> json) => _$SongRefFromJson(json);
}
