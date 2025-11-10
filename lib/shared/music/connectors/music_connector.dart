import 'package:cycle_coach/shared/data/song_model.dart';

/// Base interface every music connector must implement.
///
/// Each connector is responsible for performing any authorization that is
/// required on the current platform and returning catalog results that can be
/// surfaced in the UI.
abstract class MusicConnector {
  const MusicConnector();

  /// Human friendly label used in logs / debug messages.
  String get name;

  /// Whether the connector is fully supported on the current platform.
  bool get isSupported;

  /// Whether the connector supports arbitrary search queries.
  bool get supportsSearch => false;

  /// Returns an optional message that can be shown to the user when the
  /// connector is not supported on the current device.
  String? get unsupportedMessage => null;

  /// Ensures the user is authorized to access this connector.
  Future<void> ensureAuthorized();

  /// Fetches an initial catalog to render in the add-song dialog.
  Future<List<SongModel>> fetchInitialCatalog();

  /// Performs a query against the connector catalog if supported.
  Future<List<SongModel>> search(String query) async {
    if (!supportsSearch) {
      return fetchInitialCatalog();
    }
    return fetchInitialCatalog();
  }
}
