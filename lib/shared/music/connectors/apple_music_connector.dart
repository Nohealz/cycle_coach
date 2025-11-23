import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:cycle_coach/shared/data/song_model.dart';
import 'package:cycle_coach/shared/services/apple_music_auth_service.dart';

import 'apple_music_web_adapter.dart';
import 'music_connector.dart';

class AppleMusicConnector extends MusicConnector {
  AppleMusicConnector(
    this._authService, {
    http.Client? httpClient,
    AppleMusicWebAdapter? webAdapter,
  })  : _client = httpClient ?? http.Client(),
        _webAdapter = webAdapter ?? (kIsWeb ? AppleMusicWebAdapter() : null);

  final AppleMusicAuthService _authService;
  final http.Client _client;
  final AppleMusicWebAdapter? _webAdapter;

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
    final adapter = _webAdapter;
    if (kIsWeb && adapter != null) {
      final token = await _authService.getDeveloperToken();
      await adapter.ensureConfigured(token);
      await adapter.authorize();
      return;
    }
    await _authService.ensureAuthorized();
  }

  @override
  Future<List<SongModel>> fetchInitialCatalog() async {
    final adapter = _webAdapter;
    if (kIsWeb && adapter != null) {
      final token = await _authService.getDeveloperToken();
      await adapter.ensureConfigured(token);
      final charts = await adapter.fetchCharts();
      return _parseChartSongs(charts);
    }
    return _fetchChartsViaRest();
  }

  @override
  Future<List<SongModel>> search(String query) async {
    final adapter = _webAdapter;
    if (kIsWeb && adapter != null) {
      final token = await _authService.getDeveloperToken();
      await adapter.ensureConfigured(token);
      final result = await adapter.search(query);
      return _parseSearchSongs(result);
    }
    return _searchViaRest(query);
  }

  Future<List<SongModel>> _fetchChartsViaRest() async {
    final token = await _authService.getDeveloperToken();
    final uri = Uri.https(
      'api.music.apple.com',
      '/v1/catalog/us/charts',
      {'types': 'songs', 'limit': '20'},
    );
    try {
      final response = await _client.get(uri, headers: {
        'Authorization': 'Bearer $token',
      });
      if (response.statusCode != 200) {
        throw StateError(
          'Apple Music request failed (${response.statusCode}): ${response.body}',
        );
      }
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return _parseChartSongs(json);
    } catch (error, stack) {
      debugPrint('Apple Music fetchInitialCatalog error: $error\n$stack');
      rethrow;
    }
  }

  Future<List<SongModel>> _searchViaRest(String query) async {
    final token = await _authService.getDeveloperToken();
    final uri = Uri.https(
      'api.music.apple.com',
      '/v1/catalog/us/search',
      {
        'term': query,
        'types': 'songs',
        'limit': '25',
      },
    );
    try {
      final response = await _client.get(uri, headers: {
        'Authorization': 'Bearer $token',
      });
      if (response.statusCode != 200) {
        throw StateError(
          'Apple Music search failed (${response.statusCode}): ${response.body}',
        );
      }
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return _parseSearchSongs(json);
    } catch (error, stack) {
      debugPrint('Apple Music search error: $error\n$stack');
      rethrow;
    }
  }

  List<SongModel> _parseChartSongs(Map<String, dynamic> json) {
    final results = json['results'] as Map<String, dynamic>? ?? {};
    final songs = results['songs'] as List<dynamic>? ?? const [];
    final List<SongModel> output = [];
    for (final entry in songs) {
      final data = (entry as Map<String, dynamic>)['data'] as List<dynamic>? ?? const [];
      for (final song in data) {
        final model = _mapSong(song as Map<String, dynamic>);
        if (model != null) {
          output.add(model);
        }
      }
    }
    return output;
  }

  List<SongModel> _parseSearchSongs(Map<String, dynamic> json) {
    final results = json['results'] as Map<String, dynamic>? ?? {};
    final songs = results['songs']?['data'] as List<dynamic>? ?? const [];
    final List<SongModel> output = [];
    for (final song in songs) {
      final model = _mapSong(song as Map<String, dynamic>);
      if (model != null) {
        output.add(model);
      }
    }
    return output;
  }

  SongModel? _mapSong(Map<String, dynamic> payload) {
    final attributes = payload['attributes'] as Map<String, dynamic>? ?? {};
    final name = attributes['name'] as String?;
    final artist = attributes['artistName'] as String?;
    final durationMs = attributes['durationInMillis'] as int?;
    final previews = attributes['previews'] as List<dynamic>? ?? const [];
    final previewUrl =
        previews.isNotEmpty ? previews.first['url'] as String? : null;
    final id = payload['id'] as String? ??
        attributes['playParams']?['id'] as String? ??
        name;
    if (id == null || name == null || artist == null) {
      return null;
    }
    return SongModel(
      id: id,
      title: name,
      artist: artist,
      durationSeconds: durationMs != null ? durationMs ~/ 1000 : 0,
      previewUrl: previewUrl,
    );
  }
}
