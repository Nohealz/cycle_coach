import 'dart:async';

import 'package:cycle_coach/shared/models/cue_card.dart';

class CueRepository {
  final Map<String, List<CueCard>> _store = {};
  final Map<String, StreamController<List<CueCard>>> _controllers = {};

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
  }

  void remove(String songId, String cueId) {
    final cues = List<CueCard>.from(_store[songId] ?? const <CueCard>[]);
    cues.removeWhere((cue) => cue.id == cueId);
    _store[songId] = cues;
    _emit(songId);
  }

  void copyAll(String fromSongId, String toSongId) {
    final source = List<CueCard>.from(_store[fromSongId] ?? const <CueCard>[]);
    _store[toSongId] = source.map((cue) => cue.copyWith()).toList();
    _emit(toSongId);
  }

  void _emit(String songId) {
    final controller = _controllers[songId];
    if (controller != null && !controller.isClosed) {
      controller.add(list(songId));
    }
  }
}

