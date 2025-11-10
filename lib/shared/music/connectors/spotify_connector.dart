import 'package:cycle_coach/shared/data/song_model.dart';

import 'music_connector.dart';

class SpotifyConnector extends MusicConnector {
  const SpotifyConnector();

  @override
  String get name => 'Spotify';

  @override
  bool get isSupported => true;

  @override
  bool get supportsSearch => true;

  @override
  Future<void> ensureAuthorized() async {
    // TODO: implement PKCE flow. For now, this is a no-op placeholder.
  }

  @override
  Future<List<SongModel>> fetchInitialCatalog() async {
    return const <SongModel>[];
  }
}
