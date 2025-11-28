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

    // Guarded zombie-fix: only if authorized but API is broken.
    final needsZombieFix = js.context.callMethod('eval', [
      '''
      (function() {
        const inst = MusicKit.getInstance();
        return inst && inst.isAuthorized && inst.api && !(inst.api.library && inst.api.library.playlists);
      })();
      '''
    ]) as bool? ??
        false;
    if (needsZombieFix) {
      debugPrint('[MusicKit] Detected zombie API – applying unauthorize + reconfigure fix');
      js.context.callMethod('eval', [
        '''
        (function() {
          const inst = MusicKit.getInstance();
          console.log('%cZOMBIE FIX: unauthorize + reconfigure', 'color:orange;font-weight:bold');
          if (inst && typeof inst.unauthorize === 'function') {
            try { inst.unauthorize(); } catch (_) {}
          }
          MusicKit.configure({
            developerToken: inst ? inst.developerToken : undefined,
            app: { name: "Cycle Coach", build: "1.0.0" },
            bitrate: 256,
            sourceType: 'web'
          });
        })();
        '''
      ]);
      await Future<void>.delayed(const Duration(milliseconds: 400));
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
          return inst.authorize();
        })();
        '''
      ]);
      debugPrint('[MusicKit] Apple Music popup opened. Waiting for you to log in...');
      // If authorize returned a promise, wait for it to settle before polling token.
      try {
        final inst = js.context.callMethod('eval', ['MusicKit.getInstance()']);
        final authResult = js_util.getProperty(inst, 'authorizeResult');
        final hasThen = authResult != null && js_util.hasProperty(authResult, 'then');
        if (hasThen) {
          await js_util.promiseToFuture(authResult);
        }
      } catch (_) {}
      final waited = await _waitForUserToken(timeoutSeconds: 120);
      _authorized = waited;
      final tokenLog = _musicUserToken ?? 'none';
      debugPrint('[MusicKit] musicUserToken after authorize: $tokenLog');
      if (!_authorized) {
        throw StateError('Apple Music login timed out. Please try again.');
      }
      // Zombie-instance killer: force a fresh shared instance after auth.
      js.context.callMethod('eval', [
        '''
        (function() {
          console.log('%cZOMBIE INSTANCE RESET', 'color:lime;font-weight:bold');
          window.cycleCoachMKInstance = MusicKit.getInstance();
        })();
        '''
      ]);
      debugPrint('[MusicKit] Login complete! You are now fully authorized.');
    } catch (e) {
      debugPrint('[MusicKit] authorize failed: $e');
      rethrow;
    }
  }

  void _refreshInstance() {
    js.context.callMethod('eval', [
      '''
      window.cycleCoachMKInstance = MusicKit.getInstance();
      '''
    ]);
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

  Future<List<dynamic>> fetchMyPlaylists() async {
    await authorize();
    _refreshInstance();
    debugPrint('[MusicKit] loading library playlists...');
    dynamic playlistsPromise;
    final stopAt = DateTime.now().add(const Duration(seconds: 12));
    while (DateTime.now().isBefore(stopAt)) {
      playlistsPromise = js.context.callMethod('eval', [
        '''
        (function() {
          const inst = MusicKit.getInstance();
          if (inst?.api?.library?.playlists && typeof inst.api.library.playlists === 'function') {
            return inst.api.library.playlists({ limit: 100 });
          }
          return null;
        })();
        '''
      ]);
      if (playlistsPromise != null) {
        break;
      }
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }
    if (playlistsPromise == null) {
      throw StateError('Could not load your playlists. Try refreshing.');
    }
    final resolved = await js_util.promiseToFuture(playlistsPromise);
    final jsonString = js_util.callMethod(
      js.context['JSON'],
      'stringify',
      [resolved],
    ) as String;
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    return (data['data'] as List<dynamic>? ?? <dynamic>[]);
  }

  Future<Map<String, dynamic>> search(String query) async {
    await authorize();
    _refreshInstance();
    dynamic searchPromise;
    final stopAt = DateTime.now().add(const Duration(seconds: 30));
    final safeQuery = query.replaceAll('"', '\\"');
    while (DateTime.now().isBefore(stopAt)) {
      searchPromise = js.context.callMethod('eval', [
        '''
        (function() {
          const inst = MusicKit.getInstance();
          if (inst && typeof inst.setActivity === 'function') {
            inst.setActivity({ type: 'library' });
          }
          if (inst?.api?.search && typeof inst.api.search === 'function') {
            return inst.api.search({ term: "$safeQuery", types: ['songs'], limit: 25 });
          }
          return null;
        })();
        '''
      ]);
      if (searchPromise != null) {
        break;
      }
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
    if (searchPromise == null) {
      debugPrint('[MusicKit] API still not ready after extended wait (search).');
      throw StateError('Apple Music catalog temporarily unavailable. Please refresh and try again.');
    }
    final result = await js_util.promiseToFuture(searchPromise);
    final jsonString = js_util.callMethod(js.context['JSON'], 'stringify', [result]) as String;
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }
}
