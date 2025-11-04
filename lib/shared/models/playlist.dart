import 'package:freezed_annotation/freezed_annotation.dart';
import 'song.dart';
import 'cue_card.dart';

part 'playlist.freezed.dart';
part 'playlist.g.dart';

@freezed
abstract class Playlist with _$Playlist {
  const factory Playlist({
    required String id,
    required String name,
    @Default(<Song>[]) List<Song> songs,
    // Map songId -> list of cue cards at timestamps within that song
    @Default(<String, List<CueCard>>{}) Map<String, List<CueCard>> cuesBySongId,
  }) = _Playlist;

  factory Playlist.fromJson(Map<String, dynamic> json) => _$PlaylistFromJson(json);
}
