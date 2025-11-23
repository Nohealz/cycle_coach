// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:js' as js;

import 'package:flutter/foundation.dart';

class AppleMusicWebAdapter {
  AppleMusicWebAdapter();

  bool _configured = false;

  js.JsObject get _helper {
    final helper = js.context['cycleCoachMusicKit'];
    if (helper == null) {
      throw StateError('MusicKit helper not loaded.');
    }
    return helper as js.JsObject;
  }

  Future<void> ensureConfigured(String developerToken) async {
    if (!kIsWeb) {
      return;
    }
    if (_configured) {
      return;
    }
    final helper = _helper;
    await _promiseToFuture<void>(
      helper.callMethod('configure', [developerToken]) as js.JsObject,
    );
    _configured = true;
  }

  Future<void> authorize() async {
    final helper = _helper;
    await _promiseToFuture<void>(
      helper.callMethod('authorize', []) as js.JsObject,
    );
  }

  Future<Map<String, dynamic>> fetchCharts() async {
    final helper = _helper;
    final result = await _promiseToFuture<String>(
      helper.callMethod('charts', []) as js.JsObject,
    );
    return jsonDecode(result) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> search(String query) async {
    final helper = _helper;
    final result = await _promiseToFuture<String>(
      helper.callMethod('search', [query]) as js.JsObject,
    );
    return jsonDecode(result) as Map<String, dynamic>;
  }

  Future<T> _promiseToFuture<T>(js.JsObject promise) {
    final completer = Completer<T>();
    promise.callMethod('then', [
      (value) => completer.complete(value as T),
    ]);
    promise.callMethod('catch', [
      (error) => completer.completeError(error),
    ]);
    return completer.future;
  }
}
