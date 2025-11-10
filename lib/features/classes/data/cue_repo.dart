import 'dart:async';

import 'package:cycle_coach/shared/models/cue_card.dart';
import 'package:cycle_coach/shared/services/local_storage_service.dart';

class CueRepository {
  CueRepository(this._storage) {
    _hydrate();
  }

  final LocalStorageService _storage;

  final Map<String, List<CueCard>> _store = {};
  final Map<String, StreamController<List<CueCard>>> _controllers = {};

  Future<void> _hydrate() async {
    final stored = await _storage.loadCues();
    if (stored.isNotEmpty) {
      _store
        ..clear()
        ..addAll(stored);
      for (final songId in stored.keys) {
        _emit(songId);
      }
    }
  }

  Future<void> _persist() async {
    await _storage.saveCues(_store);
  }

  List<CueCard> list(String songId) {
    return List.unmodifiable(_store[songId] ?? const <CueCard>[]);
  }

  Stream<List<CueCard>> watch(String songId) {
    final controller = _controllers.putIfAbsent(songId, () {
      StreamController<List<CueCard>>? created;
      created = StreamController<List<CueCard>>.broadcast(onListen: () {
        created!.add(list(songId));
      });
      return created;
    });
    return controller.stream;
  }

  void add(String songId, CueCard cue) {
    final cues = List<CueCard>.from(_store[songId] ?? const <CueCard>[]);
    cues.removeWhere((existing) => existing.id == cue.id);
    cues.add(cue);
    cues.sort((a, b) => a.offset.compareTo(b.offset));
    _store[songId] = cues;
    _emit(songId);
    _persist();
  }

  void update(String songId, CueCard cue) {
    final cues = List<CueCard>.from(_store[songId] ?? const <CueCard>[]);
    final index = cues.indexWhere((existing) => existing.id == cue.id);
    if (index == -1) {
      return;
    }
    cues[index] = cue;
    cues.sort((a, b) => a.offset.compareTo(b.offset));
    _store[songId] = cues;
    _emit(songId);
    _persist();
  }

  void remove(String songId, String cueId) {
    final cues = List<CueCard>.from(_store[songId] ?? const <CueCard>[]);
    cues.removeWhere((cue) => cue.id == cueId);
    _store[songId] = cues;
    _emit(songId);
    _persist();
  }

  void copyAll(String fromSongId, String toSongId) {
    final source = List<CueCard>.from(_store[fromSongId] ?? const <CueCard>[]);
    _store[toSongId] = source.map((cue) => cue.copyWith()).toList();
    _emit(toSongId);
    _persist();
  }

  void _emit(String songId) {
    final controller = _controllers[songId];
    if (controller != null && !controller.isClosed) {
      controller.add(list(songId));
    }
  }
}
