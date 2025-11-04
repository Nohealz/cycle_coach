import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  AudioPlayerService() : _player = AudioPlayer() {
    _initialization = _setup();
  }

  final AudioPlayer _player;
  late final Future<void> _initialization;
  AudioSession? _session;
  String? _loadedUrl;

  Future<void> _setup() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    _session = session;
  }

  Future<void> _ensureReady() async {
    await _initialization;
  }

  Future<void> load(String url) async {
    await _ensureReady();
    if (_loadedUrl == url) {
      return;
    }
    try {
      await _player.stop();
      await _session?.setActive(true);
      await _player.setUrl(url);
      _loadedUrl = url;
    } catch (error) {
      _loadedUrl = null;
      rethrow;
    }
  }

  Future<void> play() async {
    await _ensureReady();
    await _session?.setActive(true);
    await _player.play();
  }

  Future<void> pause() async {
    await _ensureReady();
    await _player.pause();
  }

  Future<void> seek(Duration position) async {
    await _ensureReady();
    await _player.seek(position);
  }

  Stream<Duration> get positionStream => _player.positionStream;

  Stream<Duration?> get durationStream => _player.durationStream;

  Stream<bool> get playingStream => _player.playingStream;

  Stream<ProcessingState> get processingStateStream =>
      _player.processingStateStream;

  bool get hasLoaded => _loadedUrl != null;

  String? get currentUrl => _loadedUrl;

  Future<void> dispose() async {
    await _player.dispose();
  }
}

final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  final service = AudioPlayerService();
  ref.onDispose(() {
    // Dispose asynchronously; ignore returned future.
    service.dispose();
  });
  return service;
});

final positionProvider = StreamProvider<Duration>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.positionStream;
});

final durationProvider = StreamProvider<Duration?>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.durationStream;
});

final playingProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.playingStream;
});

final processingStateProvider = StreamProvider<ProcessingState>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.processingStateStream;
});
