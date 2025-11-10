import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cycle_coach/features/classes/domain/models/class_model.dart';
import 'package:cycle_coach/shared/models/cue_card.dart';
import 'package:cycle_coach/shared/models/song.dart';
import 'package:cycle_coach/shared/music/connector.dart';

class LocalStorageService {
  static const _classesKey = 'classes';
  static const _songsKey = 'songs';
  static const _cuesKey = 'cues';
  static const _connectorKey = 'last_connector';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<List<ClassModel>> loadClasses() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_classesKey);
    if (raw == null) {
      return const [];
    }
    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((entry) => ClassModel.fromJson(entry as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveClasses(List<ClassModel> classes) async {
    final prefs = await _prefs;
    final encoded = jsonEncode(
      classes.map((item) => item.toJson()).toList(),
    );
    await prefs.setString(_classesKey, encoded);
  }

  Future<Map<String, Song>> loadSongs() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_songsKey);
    if (raw == null) {
      return {};
    }
    final Map<String, dynamic> decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map(
      (key, value) => MapEntry(key, Song.fromJson(value as Map<String, dynamic>)),
    );
  }

  Future<void> saveSongs(Map<String, Song> songs) async {
    final prefs = await _prefs;
    final encoded =
        jsonEncode(songs.map((key, value) => MapEntry(key, value.toJson())));
    await prefs.setString(_songsKey, encoded);
  }

  Future<Map<String, List<CueCard>>> loadCues() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_cuesKey);
    if (raw == null) {
      return {};
    }
    final Map<String, dynamic> decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map(
      (key, value) => MapEntry(
        key,
        (value as List<dynamic>)
            .map((entry) => CueCard.fromJson(entry as Map<String, dynamic>))
            .toList(),
      ),
    );
  }

  Future<void> saveCues(Map<String, List<CueCard>> cues) async {
    final prefs = await _prefs;
    final encoded = jsonEncode(
      cues.map(
        (key, value) => MapEntry(
          key,
          value.map((cue) => cue.toJson()).toList(),
        ),
      ),
    );
    await prefs.setString(_cuesKey, encoded);
  }

  Future<void> saveLastConnector(ConnectorType connector) async {
    final prefs = await _prefs;
    await prefs.setString(_connectorKey, connector.name);
  }

  Future<ConnectorType?> loadLastConnector() async {
    final prefs = await _prefs;
    final value = prefs.getString(_connectorKey);
    if (value == null) {
      return null;
    }
    for (final type in ConnectorType.values) {
      if (type.name == value) {
        return type;
      }
    }
    return null;
  }
}

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});
