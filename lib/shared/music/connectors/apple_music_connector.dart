import 'package:flutter/foundation.dart';

import 'package:cycle_coach/shared/data/song_model.dart';
import 'package:cycle_coach/shared/services/apple_music_auth_service.dart';

import 'music_connector.dart';

class AppleMusicConnector extends MusicConnector {
  AppleMusicConnector(this._authService);

  final AppleMusicAuthService _authService;

  bool get _isSupported {
    if (kIsWeb) {
      return true;
    }
    return defaultTargetPlatform == TargetPlatform.iOS;
  }

  @override
  String get name => 'Apple Music';

  @override
  bool get isSupported => _isSupported;

  @override
  String? get unsupportedMessage =>
      'Apple Music is available on iOS and the web only.';

  @override
  bool get supportsSearch => true;

  @override
  Future<void> ensureAuthorized() async {
    if (!_isSupported) {
      throw UnsupportedError(unsupportedMessage ?? 'Not supported.');
    }
    await _authService.ensureAuthorized();
  }

  @override
  Future<List<SongModel>> fetchInitialCatalog() async {
    // Networking will be implemented in a later iteration. For now we simply
    // return an empty catalog which keeps the UI functional.
    return const <SongModel>[];
  }
}
