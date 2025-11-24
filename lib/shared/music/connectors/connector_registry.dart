import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cycle_coach/shared/music/connector.dart';
import 'package:cycle_coach/shared/music/connectors/apple_music_connector.dart';
import 'package:cycle_coach/shared/music/connectors/music_connector.dart';
import 'package:cycle_coach/shared/music/connectors/spotify_connector.dart';
import 'package:cycle_coach/shared/music/connectors/web_upload_connector.dart';
import 'package:cycle_coach/shared/services/apple_music_auth_service.dart';
import 'apple_music_web_adapter.dart';

final musicConnectorProvider =
    Provider.family<MusicConnector, ConnectorType>((ref, type) {
  switch (type) {
    case ConnectorType.appleMusic:
      return AppleMusicConnector(
        ref.read(appleMusicAuthServiceProvider),
        webAdapter: kIsWeb ? AppleMusicWebAdapter() : null,
      );
    case ConnectorType.spotify:
      return const SpotifyConnector();
    case ConnectorType.webUpload:
      return const WebUploadConnector();
  }
});
