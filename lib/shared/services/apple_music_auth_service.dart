import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// URL for the backend service that mints Apple Music developer tokens.
const String _tokenEndpoint = String.fromEnvironment(
  'APPLE_MUSIC_TOKEN_URL',
  defaultValue: '',
);

class AppleMusicAuthService {
  AppleMusicAuthService({http.Client? httpClient}) : _client = httpClient ?? http.Client();

  final http.Client _client;
  static const MethodChannel _channel = MethodChannel('cycle_coach/apple_music');

  String? _developerToken;
  DateTime? _developerTokenExpiry;

  Future<void> ensureAuthorized() async {
    await getDeveloperToken();
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      await _requestUserToken(_developerToken!);
    }
  }

  Future<String> getDeveloperToken() async {
    if (_developerToken != null &&
        _developerTokenExpiry != null &&
        _developerTokenExpiry!.isAfter(DateTime.now().add(const Duration(minutes: 5)))) {
      return _developerToken!;
    }
    _developerToken = await _fetchDeveloperToken();
    return _developerToken!;
  }

  Future<String> _fetchDeveloperToken() async {
    if (_tokenEndpoint.isEmpty) {
      throw StateError('APPLE_MUSIC_TOKEN_URL is not configured.');
    }
    final response = await _client.post(Uri.parse(_tokenEndpoint));
    if (response.statusCode != 200) {
      throw StateError('Failed to fetch Apple Music token (${response.statusCode})');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final token = body['token'] as String?;
    if (token == null || token.isEmpty) {
      throw StateError('Apple Music token payload missing "token".');
    }
    final expiresAtString = body['expiresAt'] as String?;
    if (expiresAtString != null) {
      _developerTokenExpiry = DateTime.tryParse(expiresAtString);
    }
    return token;
  }

  Future<void> _requestUserToken(String developerToken) async {
    if (kIsWeb) {
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
