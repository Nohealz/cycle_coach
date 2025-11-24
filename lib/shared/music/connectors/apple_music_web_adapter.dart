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
    await _waitForMusicKitReady();
    try {
      debugPrint('[MusicKit] configuring...');
      // Configure and immediately capture the real instance (configure returns void).
      final configScript = '''
        MusicKit.configure({
          developerToken: "$developerToken",
          app: { name: "Cycle Coach", build: "1.0.0" },
          bitrate: 256
        });
        window.cycleCoachMKInstance = MusicKit.getInstance();
      ''';
      js.context.callMethod('eval', [configScript]);
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
    try {
      debugPrint('[MusicKit] authorizing...');
      // Call authorize via eval to bypass proxies.
      await js_util.promiseToFuture(
        js.context.callMethod('eval', ['MusicKit.getInstance().authorize()']),
      );
      _authorized = true;
      debugPrint('[MusicKit] authorized via eval.');
    } catch (e) {
      debugPrint('[MusicKit] authorize failed: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchCharts() async {
    await authorize();
    debugPrint('[MusicKit] fetching charts...');
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
