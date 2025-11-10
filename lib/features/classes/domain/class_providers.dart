import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:cycle_coach/features/classes/data/class_repo.dart';
import 'package:cycle_coach/features/classes/domain/models/class_model.dart';
import 'package:cycle_coach/features/classes/domain/models/song_ref.dart';
import 'package:cycle_coach/shared/data/song_repository.dart';
import 'package:cycle_coach/shared/music/connector.dart';
import 'package:cycle_coach/shared/models/song.dart';
import 'package:cycle_coach/shared/services/local_storage_service.dart';

final selectedConnectorProvider =
    StateNotifierProvider<SelectedConnectorNotifier, ConnectorType>(
  (ref) => SelectedConnectorNotifier(ref),
);

class SelectedConnectorNotifier extends StateNotifier<ConnectorType> {
  SelectedConnectorNotifier(this._ref) : super(ConnectorType.spotify) {
    _hydrate();
  }

  final Ref _ref;

  LocalStorageService get _storage => _ref.read(localStorageServiceProvider);

  Future<void> _hydrate() async {
    final stored = await _storage.loadLastConnector();
    if (stored != null) {
      state = stored;
    }
  }

  Future<void> select(ConnectorType connector) async {
    if (state == connector) {
      return;
    }
    state = connector;
    await _storage.saveLastConnector(connector);
  }
}

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
