import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// URL for the backend service that mints Apple Music developer tokens.
const String _tokenEndpoint = String.fromEnvironment(
  'APPLE_MUSIC_TOKEN_URL',
  defaultValue: '',
);

class AppleMusicAuthService {
  AppleMusicAuthService({http.Client? httpClient}) : _client = httpClient ?? http.Client();

  final http.Client _client;
  static const MethodChannel _channel = MethodChannel('cycle_coach/apple_music');

  Future<void> ensureAuthorized() async {
    if (_tokenEndpoint.isEmpty) {
      throw StateError('APPLE_MUSIC_TOKEN_URL is not configured.');
    }
    final developerToken = await _fetchDeveloperToken();
    await _requestUserToken(developerToken);
  }

  Future<String> _fetchDeveloperToken() async {
    final response = await _client.post(Uri.parse(_tokenEndpoint));
    if (response.statusCode != 200) {
      throw StateError('Failed to fetch Apple Music token (${response.statusCode})');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final token = body['token'] as String?;
    if (token == null || token.isEmpty) {
      throw StateError('Apple Music token payload missing "token".');
    }
    return token;
  }

  Future<void> _requestUserToken(String developerToken) async {
    if (kIsWeb) {
      // Web will handle authorization via JS interop in a later iteration.
      return;
    }
    await _channel.invokeMethod<String>('requestUserToken', {
      'developerToken': developerToken,
    });
  }

  Future<void> dispose() async {
    _client.close();
  }
}

final appleMusicAuthServiceProvider = Provider<AppleMusicAuthService>((ref) {
  final service = AppleMusicAuthService();
  ref.onDispose(service.dispose);
  return service;
});
