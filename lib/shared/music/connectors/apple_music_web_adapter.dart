// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:convert';
import 'dart:js' as js;

import 'package:flutter/foundation.dart';
// ignore: uri_does_not_exist
import 'dart:js_util' as js_util;

class AppleMusicWebAdapter {
  AppleMusicWebAdapter();

  bool _configured = false;
  bool _authorized = false;
  String? _musicUserToken;

  String? _loadCachedToken() {
    try {
      final storage = js.context['localStorage'];
      if (storage != null) {
        return storage.callMethod('getItem', ['cycleCoachMusicUserToken']) as String?;
      }
    } catch (_) {}
    return null;
  }

  void _persistToken(String token) {
    _musicUserToken = token;
    try {
      final storage = js.context['localStorage'];
      storage?.callMethod('setItem', ['cycleCoachMusicUserToken', token]);
    } catch (_) {}
  }

  Future<void> _waitForMusicKitReady() async {
    if (!kIsWeb) {
      return;
    }
    final start = DateTime.now();
    while (true) {
      final readyFlag = js.context['musicKitReady'] == true;
      final mkPresent = js.context['MusicKit'] != null;
      if (readyFlag || mkPresent) {
        if (!readyFlag && mkPresent) {
          js.context['musicKitReady'] = true;
        }
        return;
      }
      if (DateTime.now().difference(start) > const Duration(seconds: 5)) {
        debugPrint('[MusicKit] wait for ready timed out');
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
  }

  Future<void> ensureConfigured(String developerToken) async {
    if (!kIsWeb) {
      return;
    }
    if (_configured) {
      return;
    }
    _musicUserToken ??= _loadCachedToken();
    await _waitForMusicKitReady();
    try {
      debugPrint('[MusicKit] configuring...');
      // Configure and immediately capture the real instance (configure returns void).
      final configScript = '''
        MusicKit.configure({
          developerToken: "$developerToken",
          app: { name: "Cycle Coach", build: "1.0.0" },
          bitrate: 256,
          sourceType: 'web'
        });
        window.cycleCoachMKInstance = MusicKit.getInstance();
      ''';
      js.context.callMethod('eval', [configScript]);
      // If we have a cached user token, set it silently.
      if (_musicUserToken != null && _musicUserToken!.isNotEmpty) {
        final tokenToSet = _musicUserToken!;
        js.context.callMethod('eval', [
          '''
          (function() {
            const inst = MusicKit.getInstance();
            inst.musicUserToken = "$tokenToSet";
          })();
          '''
        ]);
        _authorized = true;
        debugPrint('[MusicKit] Silent login with cached token.');
      }
      _configured = true;
      await Future<void>.delayed(const Duration(milliseconds: 300));
      debugPrint('[MusicKit] configured + instance cached.');
    } catch (e) {
      debugPrint('[MusicKit] configure failed: $e');
      rethrow;
    }
  }

  Future<void> authorize() async {
    if (!kIsWeb) {
      return;
    }
    if (_authorized) {
      return;
    }
    if (!_configured) {
      throw StateError('MusicKit must be configured before authorize().');
    }
    await _waitForMusicKitReady();
    // Try silent login if we have a cached token.
    _musicUserToken ??= _loadCachedToken();
    if (_musicUserToken != null && _musicUserToken!.isNotEmpty) {
      js.context.callMethod('eval', [
        '''
        (function() {
          const inst = MusicKit.getInstance();
          inst.musicUserToken = "$_musicUserToken";
        })();
        '''
      ]);
      _authorized = true;
      debugPrint('[MusicKit] Silent login successful');
      return;
    }
    try {
      debugPrint('[MusicKit] authorizing...');
      // Call authorize via eval to bypass proxies and guard for missing authorize.
      js.context.callMethod('eval', [
        '''
        (function() {
          const inst = MusicKit.getInstance();
          if (!inst || typeof inst.authorize !== 'function') {
            throw 'MusicKit authorize missing on instance';
          }
          inst.authorize();
        })();
        '''
      ]);
      debugPrint('[MusicKit] Apple Music popup opened. Waiting for you to log in...');
      final waited = await _waitForUserToken(timeoutSeconds: 120);
      _authorized = waited;
      final tokenLog = _musicUserToken ?? 'none';
      debugPrint('[MusicKit] musicUserToken after authorize: $tokenLog');
      if (!_authorized) {
        throw StateError('Apple Music login timed out. Please try again.');
      }
      debugPrint('[MusicKit] Login complete! You are now fully authorized.');
    } catch (e) {
      debugPrint('[MusicKit] authorize failed: $e');
      rethrow;
    }
  }

  Future<bool> _waitForUserToken({int timeoutSeconds = 120}) async {
    final start = DateTime.now();
    while (DateTime.now().difference(start) <
        Duration(seconds: timeoutSeconds)) {
      final token = js.context.callMethod('eval', [
        '''
        (function() {
          const inst = MusicKit.getInstance();
          return inst && inst.musicUserToken ? inst.musicUserToken : null;
        })();
        '''
      ]) as String?;
      if (token != null && token.isNotEmpty) {
        _persistToken(token);
        debugPrint('[MusicKit] musicUserToken cached (poll).');
        return true;
      }
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
    return false;
  }

  Future<Map<String, dynamic>> fetchCharts() async {
    await authorize();
    debugPrint('[MusicKit] fetching charts...');
    final apiAvailable = js.context.callMethod('eval', [
      '''
      (function() {
        const inst = MusicKit.getInstance();
        return inst && inst.api && typeof inst.api.charts === 'function';
      })();
      '''
    ]) as bool?;
    if (apiAvailable != true) {
      throw StateError('Login to Apple Music to load catalog (charts unavailable).');
    }
    final result = await js_util.promiseToFuture(
      js.context.callMethod('eval', [
        '''
        (async function() {
          const inst = MusicKit.getInstance();
          return await inst.api.charts({ types: ['songs'], limit: 20 });
        })();
        '''
      ]),
    );
    final jsonString = js_util.callMethod(
      js.context['JSON'],
      'stringify',
      [result],
    ) as String;
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> search(String query) async {
    await authorize();
    final apiAvailable = js.context.callMethod('eval', [
      '''
      (function() {
        const inst = MusicKit.getInstance();
        return inst && inst.api && typeof inst.api.search === 'function';
      })();
      '''
    ]) as bool?;
    if (apiAvailable != true) {
      throw StateError('Login to Apple Music to search.');
    }
    final result = await js_util.promiseToFuture(
      js.context.callMethod('eval', [
        '''
        (async function() {
          const inst = MusicKit.getInstance();
          return await inst.api.search({
            term: "${query.replaceAll('"', '\\"')}",
            types: ['songs'],
            limit: 25
          });
        })();
        '''
      ]),
    );
    final jsonString = js_util.callMethod(
      js.context['JSON'],
      'stringify',
      [result],
    ) as String;
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }
}
