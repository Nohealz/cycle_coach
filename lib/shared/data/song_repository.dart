import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/song.dart';
import '../music/connector.dart';
import '../music/connectors/connector_registry.dart';
import '../services/local_storage_service.dart';
import 'song_model.dart';

class SongRepository extends StateNotifier<Map<String, Song>> {
  SongRepository(this._ref) : super(const {}) {
    _hydrate();
  }

  final Ref _ref;

  LocalStorageService get _storage => _ref.read(localStorageServiceProvider);

  Future<void> _hydrate() async {
    final stored = await _storage.loadSongs();
    if (stored.isNotEmpty) {
      state = stored;
    }
  }

  Future<void> _persist() async {
    await _storage.saveSongs(state);
  }

  List<Song> list() => state.values.toList()
    ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

  Song? getById(String id) => state[id];

  Song? findByTitleArtist(String title, String artist) {
    final normalizedTitle = title.trim().toLowerCase();
    final normalizedArtist = artist.trim().toLowerCase();
    for (final song in state.values) {
      if (song.title.trim().toLowerCase() == normalizedTitle &&
          song.artist.trim().toLowerCase() == normalizedArtist) {
        return song;
      }
    }
    return null;
  }

  void upsert(Song song) {
    state = {
      ...state,
      song.id: song,
    };
    _persist();
  }

  void remove(String id) {
    if (!state.containsKey(id)) {
      return;
    }
    final next = Map<String, Song>.from(state)..remove(id);
    state = next;
    _persist();
  }
}

final songRepositoryProvider =
    StateNotifierProvider<SongRepository, Map<String, Song>>(
  (Ref ref) => SongRepository(ref),
);

final songsProvider = Provider<List<Song>>((Ref ref) {
  final map = ref.watch(songRepositoryProvider);
  return map.values.toList()
    ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
});

final catalogProvider =
    FutureProvider.family<List<SongModel>, ConnectorType>((ref, connector) {
  final connectorInstance = ref.watch(musicConnectorProvider(connector));
  return connectorInstance.fetchInitialCatalog();
});
