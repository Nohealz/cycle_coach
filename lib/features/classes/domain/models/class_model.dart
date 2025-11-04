import 'package:freezed_annotation/freezed_annotation.dart';

import 'song_ref.dart';

part 'class_model.freezed.dart';
part 'class_model.g.dart';

@freezed
abstract class ClassModel with _$ClassModel {
  const factory ClassModel({
    required String id,
    required String name,
    required DateTime createdAt,
    required DateTime updatedAt,
    required List<SongRef> prePlaylist,
    required List<SongRef> workoutPlaylist,
    required List<SongRef> postPlaylist,
    required bool shufflePre,
    required bool shufflePost,
  }) = _ClassModel;

  factory ClassModel.fromJson(Map<String, dynamic> json) =>
      _$ClassModelFromJson(json);
}
