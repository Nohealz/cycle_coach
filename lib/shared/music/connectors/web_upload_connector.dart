import 'package:cycle_coach/shared/data/song_model.dart';

import 'music_connector.dart';

class WebUploadConnector extends MusicConnector {
  const WebUploadConnector();

  @override
  String get name => 'Web Upload';

  @override
  bool get isSupported => true;

  @override
  Future<void> ensureAuthorized() async {
    // No-op: all content is local.
  }

  @override
  Future<List<SongModel>> fetchInitialCatalog() async {
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
}
