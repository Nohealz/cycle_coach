import 'package:freezed_annotation/freezed_annotation.dart';
import 'converters.dart';

part 'song.freezed.dart';
part 'song.g.dart';

@freezed
abstract class Song with _$Song {
  const factory Song({
    required String id,
    required String title,
    required String artist,
    @DurationSecondsConverter() required Duration duration,
    String? album,
    String? artworkUrl,
    required String source, // 'spotify' or 'apple'
    String? spotifyId,
    String? appleMusicId,
    String? previewUrl,
  }) = _Song;

  factory Song.fromJson(Map<String, dynamic> json) => _$SongFromJson(json);
}
