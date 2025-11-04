import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/song.dart';
import '../music/connector.dart';
import 'song_model.dart';

class SongRepository extends StateNotifier<Map<String, Song>> {
  SongRepository() : super(const {});

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
  }

  void remove(String id) {
    if (!state.containsKey(id)) {
      return;
    }
    final next = Map<String, Song>.from(state)..remove(id);
    state = next;
  }
}

final songRepositoryProvider =
    StateNotifierProvider<SongRepository, Map<String, Song>>(
  (Ref ref) => SongRepository(),
);

final songsProvider = Provider<List<Song>>((Ref ref) {
  final map = ref.watch(songRepositoryProvider);
  return map.values.toList()
    ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
});

Future<List<SongModel>> fetchCatalog(ConnectorType connector) async {
  if (connector == ConnectorType.webUpload) {
    return const [
      SongModel(
        id: 'wu_001',
        title: 'Warmup Glide',
        artist: 'CC Library',
        durationSeconds: 150,
        previewUrl:
            'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      ),
      SongModel(
        id: 'wu_002',
        title: 'Cadence Push',
        artist: 'CC Library',
        durationSeconds: 210,
        previewUrl:
            'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
      ),
      SongModel(
        id: 'wu_003',
        title: 'Cool Down Echo',
        artist: 'CC Library',
        durationSeconds: 180,
        previewUrl:
            'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
      ),
    ];
  }
  return const <SongModel>[];
}

final catalogProvider =
    FutureProvider.family<List<SongModel>, ConnectorType>((ref, connector) {
  return fetchCatalog(connector);
});
