import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:cycle_coach/features/classes/data/class_repo.dart';
import 'package:cycle_coach/features/classes/domain/models/class_model.dart';
import 'package:cycle_coach/features/classes/domain/models/song_ref.dart';
import 'package:cycle_coach/shared/data/song_repository.dart';
import 'package:cycle_coach/shared/music/connector.dart';
import 'package:cycle_coach/shared/models/song.dart';

final selectedConnectorProvider =
    StateProvider<ConnectorType>((Ref ref) => ConnectorType.spotify);

final currentClassIdProvider = StateProvider<String?>((_) => null);

final currentClassProvider = Provider<ClassModel?>((ref) {
  final classId = ref.watch(currentClassIdProvider);
  if (classId == null) {
    return null;
  }
  final classes = ref.watch(classesProvider);
  for (final element in classes) {
    if (element.id == classId) {
      return element;
    }
  }
  return null;
});

final classPlaylistProvider = Provider.autoDispose
    .family<List<SongRef>, (String classId, PlaylistKind kind)>(
  (ref, args) {
    final classes = ref.watch(classesProvider);
    ClassModel? classModel;
    for (final element in classes) {
      if (element.id == args.$1) {
        classModel = element;
        break;
      }
    }
    if (classModel == null) {
      return const [];
    }
    List<SongRef> sort(List<SongRef> refs) {
      final copy = List<SongRef>.from(refs)
        ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
      return copy;
    }

    switch (args.$2) {
      case PlaylistKind.pre:
        return sort(classModel.prePlaylist);
      case PlaylistKind.workout:
        return sort(classModel.workoutPlaylist);
      case PlaylistKind.post:
        return sort(classModel.postPlaylist);
    }
  },
);

final songsForPlaylistProvider = Provider.autoDispose
    .family<List<Song>, (String classId, PlaylistKind kind)>(
  (ref, args) {
    final songMap = ref.watch(songRepositoryProvider);
    final refs = ref.watch(classPlaylistProvider(args));
    final songs = <Song>[];
    for (final refEntry in refs) {
      final song = songMap[refEntry.songId];
      if (song != null) {
        songs.add(song);
      }
    }
    return songs;
  },
);
