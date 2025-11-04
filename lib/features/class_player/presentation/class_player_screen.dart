import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:uuid/uuid.dart';

import 'package:cycle_coach/features/class_player/domain/class_player_arguments.dart';
import 'package:cycle_coach/features/classes/data/class_repo.dart';
import 'package:cycle_coach/features/classes/domain/class_providers.dart';
import 'package:cycle_coach/features/classes/domain/cue_providers.dart';
import 'package:cycle_coach/features/classes/domain/models/class_model.dart';
import 'package:cycle_coach/shared/models/cue_card.dart';
import 'package:cycle_coach/shared/models/song.dart';
import 'package:cycle_coach/shared/services/audio_player_service.dart';
import 'package:cycle_coach/shared/utils/formatting.dart';

class ClassPlayerScreen extends ConsumerStatefulWidget {
  const ClassPlayerScreen({super.key, this.initialArgs});

  final ClassPlayerLaunchArgs? initialArgs;

  @override
  ConsumerState<ClassPlayerScreen> createState() => _ClassPlayerScreenState();
}

class _ClassPlayerScreenState extends ConsumerState<ClassPlayerScreen> {
  bool _appliedInitialClass = false;
  bool _appliedInitialSong = false;
  PlaylistKind _selectedPlaylist = PlaylistKind.workout;
  int _songIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedPlaylist = widget.initialArgs?.initialPlaylist ?? PlaylistKind.workout;
    _songIndex = widget.initialArgs?.initialSongIndex ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final classes = ref.watch(classesProvider);
    final selectedClassId = ref.watch(currentClassIdProvider);
    final classIdNotifier = ref.read(currentClassIdProvider.notifier);

    final targetInitialClassId = widget.initialArgs?.classId ??
        selectedClassId ??
        (classes.isNotEmpty ? classes.first.id : null);

    if (!_appliedInitialClass && targetInitialClassId != null) {
      _appliedInitialClass = true;
      if (targetInitialClassId != selectedClassId) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          classIdNotifier.state = targetInitialClassId;
        });
      }
    } else if (selectedClassId == null && classes.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        classIdNotifier.state = classes.first.id;
      });
    }

    final currentClass = ref.watch(currentClassProvider);

    _ensureValidPlaylist(currentClass);

    final songs = (currentClass != null)
        ? ref.watch(
            songsForPlaylistProvider((currentClass.id, _selectedPlaylist)),
          )
        : const <Song>[];

    if ((songs.isEmpty && _songIndex != 0) ||
        (songs.isNotEmpty && _songIndex >= songs.length)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        setState(() {
          _songIndex = 0;
        });
      });
    }

    final requestedSongId = widget.initialArgs?.initialSongId;
    if (!_appliedInitialSong && requestedSongId != null && songs.isNotEmpty) {
      final matchIndex = songs.indexWhere((song) => song.id == requestedSongId);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        setState(() {
          _songIndex = matchIndex >= 0 ? matchIndex : 0;
          _appliedInitialSong = true;
        });
      });
    } else if (!_appliedInitialSong && songs.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        setState(() {
          _appliedInitialSong = true;
        });
      });
    }

    final selectedSong = songs.isNotEmpty ? songs[_songIndex] : null;

    final audioService = ref.read(audioPlayerServiceProvider);
    final positionAsync = ref.watch(positionProvider);
    final durationAsync = ref.watch(durationProvider);
    final playingAsync = ref.watch(playingProvider);
    final processingStateAsync = ref.watch(processingStateProvider);

    final cuesAsync = selectedSong != null
        ? ref.watch(cueListProvider(selectedSong.id))
        : const AsyncValue<List<CueCard>>.data(<CueCard>[]);
    final currentCue =
        selectedSong != null ? ref.watch(currentCueProvider(selectedSong.id)) : null;
    final nextCue =
        selectedSong != null ? ref.watch(nextCueProvider(selectedSong.id)) : null;
    final showFlash =
        selectedSong != null ? ref.watch(showFlashProvider(selectedSong.id)) : false;

    final position = positionAsync.value ?? Duration.zero;
    final duration = durationAsync.value ?? selectedSong?.duration ?? Duration.zero;
    final isPlaying = playingAsync.value ?? false;
    final processingState = processingStateAsync.value;
    final isBuffering = processingState == ProcessingState.loading ||
        processingState == ProcessingState.buffering;

    final countdown = nextCue != null
        ? _positive(nextCue.offset - position)
        : Duration.zero;

    final maxMilliseconds = duration.inMilliseconds > 0
        ? duration.inMilliseconds.toDouble()
        : 1.0;
    final currentMilliseconds = position.inMilliseconds
        .toDouble()
        .clamp(0, max(maxMilliseconds, 1.0))
        .toDouble();

    final canSeek = selectedSong != null && !isBuffering && duration.inMilliseconds > 0;

    void changeSong(int delta) {
      if (songs.isEmpty) {
        return;
      }
      final newIndex = _songIndex + delta;
      if (newIndex < 0 || newIndex >= songs.length) {
        return;
      }
      setState(() {
        _songIndex = newIndex;
      });
      unawaited(audioService.pause());
    }

    Future<void> seekToMilliseconds(double value) async {
      final clamped = value.clamp(0.0, maxMilliseconds).round();
      await audioService.seek(Duration(milliseconds: clamped));
    }

    Future<void> seekRelativeSeconds(int seconds) async {
      if (!canSeek) {
        return;
      }
      final targetMs = (position.inMilliseconds + (seconds * 1000))
          .clamp(0, duration.inMilliseconds);
      await audioService.seek(Duration(milliseconds: targetMs));
    }

    Future<void> togglePlayback() async {
      final messenger = ScaffoldMessenger.of(context);
      if (selectedSong == null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Select a song to play.')),
        );
        return;
      }
      final previewUrl = selectedSong.previewUrl;
      if (previewUrl == null || previewUrl.isEmpty) {
        messenger.showSnackBar(
          const SnackBar(content: Text('No preview URL available for this song.')),
        );
        return;
      }

      try {
        if (audioService.currentUrl != previewUrl ||
            processingState == ProcessingState.completed) {
          await audioService.load(previewUrl);
          if (!context.mounted) return;
        }
        if (isPlaying) {
          await audioService.pause();
        } else {
          await audioService.play();
        }
        if (!context.mounted) return;
      } catch (error) {
        if (!context.mounted) return;
        messenger.showSnackBar(
          SnackBar(content: Text('Audio error: $error')),
        );
      }
    }

    Future<void> addCue() async {
      if (selectedSong == null) {
        return;
      }
      final titleController = TextEditingController();
      final messenger = ScaffoldMessenger.of(context);
      final result = await showDialog<String?>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Add Cue'),
            content: TextField(
              controller: titleController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(titleController.text),
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
      titleController.dispose();
      if (result == null || result.trim().isEmpty) {
        return;
      }
      if (!context.mounted) {
        return;
      }

      final cueRepo = ref.read(cueRepositoryProvider);
      final offset = Duration(seconds: position.inSeconds);
      final cue = CueCard(
        id: const Uuid().v4(),
        title: result.trim(),
        offset: offset,
      );
      cueRepo.add(selectedSong.id, cue);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Cue "${cue.title}" added at ${durationToMMSS(offset)}',
          ),
        ),
      );
    }

    Future<void> editCue(CueCard cue) async {
      if (selectedSong == null) {
        return;
      }
      final titleController = TextEditingController(text: cue.title);
      final timeController = TextEditingController(text: durationToMMSS(cue.offset));
      final messenger = ScaffoldMessenger.of(context);
      await audioService.seek(cue.offset);
      if (!context.mounted) {
        titleController.dispose();
        timeController.dispose();
        return;
      }

      final result = await showDialog<_CueFormResult?>(
        context: context,
        builder: (context) {
          String? error;
          return StatefulBuilder(
            builder: (context, setStateDialog) {
              void save() {
                final parsed = parseDurationFromMMSS(timeController.text);
                if (titleController.text.trim().isEmpty) {
                  setStateDialog(() => error = 'Title cannot be empty.');
                  return;
                }
                if (parsed == null) {
                  setStateDialog(
                    () => error = 'Time must be in mm:ss format.',
                  );
                  return;
                }
                if (duration != Duration.zero && parsed >= duration) {
                  setStateDialog(
                    () => error = 'Time must be within the track length.',
                  );
                  return;
                }
                Navigator.of(context).pop(
                  _CueFormResult(
                    title: titleController.text.trim(),
                    offset: parsed,
                  ),
                );
              }

              return AlertDialog(
                title: const Text('Edit Cue'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: timeController,
                      decoration: InputDecoration(
                        labelText: 'Time (mm:ss)',
                        errorText: error,
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: save,
                    child: const Text('Save'),
                  ),
                ],
              );
            },
          );
        },
      );
      titleController.dispose();
      timeController.dispose();
      if (result == null) {
        return;
      }
      if (!context.mounted) return;
      final cueRepo = ref.read(cueRepositoryProvider);
      cueRepo.update(
        selectedSong.id,
        cue.copyWith(
          title: result.title,
          offset: Duration(seconds: result.offset.inSeconds),
        ),
      );
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Cue "${result.title}" updated to ${durationToMMSS(result.offset)}',
          ),
        ),
      );
    }

    void deleteCue(CueCard cue) {
      if (selectedSong == null) {
        return;
      }
      ref.read(cueRepositoryProvider).remove(selectedSong.id, cue.id);
    }

    final playlistChips = Row(
      children: PlaylistKind.values.map((kind) {
        final label = switch (kind) {
          PlaylistKind.pre => 'Pre',
          PlaylistKind.workout => 'Workout',
          PlaylistKind.post => 'Post',
        };
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(label),
            selected: _selectedPlaylist == kind,
            onSelected: (value) {
              if (!value) return;
              setState(() {
                _selectedPlaylist = kind;
                _songIndex = 0;
              });
            },
          ),
        );
      }).toList(),
    );

    final navigator = Navigator.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            if (navigator.canPop()) {
              navigator.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: const Text('Class Player'),
        actions: [
          IconButton(
            tooltip: 'Create Class',
            onPressed: () => context.push('/create-class'),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              initialValue: selectedClassId,
              decoration: const InputDecoration(labelText: 'Select class'),
              items: [
                for (final item in classes)
                  DropdownMenuItem(
                    value: item.id,
                    child: Text(item.name),
                  ),
              ],
              onChanged: (value) {
                setState(() {
                  _songIndex = 0;
                  _selectedPlaylist = PlaylistKind.workout;
                  _appliedInitialSong = true;
                });
                classIdNotifier.state = value;
              },
            ),
            const SizedBox(height: 16),
            if (currentClass == null)
              Expanded(
                child: Center(
                  child: Text(
                    classes.isEmpty
                        ? 'No classes yet. Create one to get started.'
                        : 'Select a class to begin playback.',
                  ),
                ),
              )
            else ...[
              playlistChips,
              const SizedBox(height: 12),
              _SongHeader(
                song: selectedSong,
                songIndex: _songIndex,
                songCount: songs.length,
                onPrevious: () => changeSong(-1),
                onNext: () => changeSong(1),
              ),
              const SizedBox(height: 16),
              _CueDisplay(
                currentSong: selectedSong,
                currentCue: currentCue,
                nextCue: nextCue,
                countdown: countdown,
                showFlash: showFlash,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: selectedSong == null ? null : addCue,
                icon: const Icon(Icons.add),
                label: const Text('Add Cue @ current time'),
              ),
              const SizedBox(height: 16),
              Slider(
                min: 0,
                max: maxMilliseconds,
                value: canSeek ? currentMilliseconds : 0,
                onChanged:
                    canSeek ? (value) => unawaited(seekToMilliseconds(value)) : null,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(durationToMMSS(position)),
                  Text(durationToMMSS(duration)),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  for (final seconds in const [-10, -5, 5, 10])
                    OutlinedButton(
                      onPressed: canSeek
                          ? () => unawaited(seekRelativeSeconds(seconds))
                          : null,
                      child:
                          Text(seconds > 0 ? '+${seconds}s' : '${seconds}s'),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: selectedSong == null
                        ? null
                        : () => unawaited(togglePlayback()),
                    icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                    label: Text(isPlaying ? 'Pause' : 'Play'),
                  ),
                  if (isBuffering) ...[
                    const SizedBox(width: 16),
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: cuesAsync.when(
                  data: (cues) => _CueList(
                    cues: cues,
                    onEdit: editCue,
                    onDelete: deleteCue,
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(
                    child: Text('Error loading cues: $error'),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _ensureValidPlaylist(ClassModel? classModel) {
    if (classModel == null) {
      return;
    }
    final available = <PlaylistKind>[];
    if (classModel.prePlaylist.isNotEmpty) {
      available.add(PlaylistKind.pre);
    }
    if (classModel.workoutPlaylist.isNotEmpty) {
      available.add(PlaylistKind.workout);
    }
    if (classModel.postPlaylist.isNotEmpty) {
      available.add(PlaylistKind.post);
    }
    if (available.isEmpty) {
      return;
    }
    if (!available.contains(_selectedPlaylist)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        setState(() {
          _selectedPlaylist = available.first;
          _songIndex = 0;
        });
      });
    }
  }

  Duration _positive(Duration value) {
    return value.isNegative ? Duration.zero : value;
  }
}

class _SongHeader extends StatelessWidget {
  const _SongHeader({
    required this.song,
    required this.songIndex,
    required this.songCount,
    required this.onPrevious,
    required this.onNext,
  });

  final Song? song;
  final int songIndex;
  final int songCount;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.skip_previous),
          onPressed: songIndex > 0 ? onPrevious : null,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                song?.title ?? 'No song selected',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              if (song != null)
                Text(
                  song!.artist,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              if (song != null)
                Text(
                  'Track ${songIndex + 1} of $songCount',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.skip_next),
          onPressed: song != null && songIndex < songCount - 1 ? onNext : null,
        ),
      ],
    );
  }
}

class _CueDisplay extends StatelessWidget {
  const _CueDisplay({
    required this.currentSong,
    required this.currentCue,
    required this.nextCue,
    required this.countdown,
    required this.showFlash,
  });

  final Song? currentSong;
  final CueCard? currentCue;
  final CueCard? nextCue;
  final Duration countdown;
  final bool showFlash;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;
        final mainContent = _buildCurrent(context);
        final nextContent = _NextCueCard(
          cue: nextCue,
          countdown: countdown,
          showFlash: showFlash,
        );
        if (isNarrow) {
          return Column(
            children: [
              mainContent,
              const SizedBox(height: 16),
              nextContent,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: mainContent),
            const SizedBox(width: 24),
            SizedBox(width: 220, child: nextContent),
          ],
        );
      },
    );
  }

  Widget _buildCurrent(BuildContext context) {
    final theme = Theme.of(context);
    final title = currentCue?.title ?? currentSong?.title ?? 'No cue active';
    final subtitle = currentSong != null
        ? currentSong!.artist
        : 'Select a song to begin.';
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              theme.colorScheme.primary.withAlpha((255 * 0.2).round()),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          // TODO(settings): allow showing a countdown under the current cue based on instructor preferences.
          Text(
            subtitle,
            style: theme.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _NextCueCard extends StatelessWidget {
  const _NextCueCard({
    required this.cue,
    required this.countdown,
    required this.showFlash,
  });

  final CueCard? cue;
  final Duration countdown;
  final bool showFlash;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: showFlash
              ? theme.colorScheme.secondary
              : theme.colorScheme.outlineVariant
                  .withAlpha((255 * 0.4).round()),
        ),
        boxShadow: showFlash
            ? [
                BoxShadow(
                  color: theme.colorScheme.secondary
                      .withAlpha((255 * 0.35).round()),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: cue == null
          ? const Text('No upcoming cue')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next Cue',
                  style: theme.textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  cue!.title,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  countdown > Duration.zero
                      ? 'Starts in ${durationToMMSS(countdown)}'
                      : 'Starting now',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
    );
  }
}

class _CueList extends StatelessWidget {
  const _CueList({
    required this.cues,
    required this.onEdit,
    required this.onDelete,
  });

  final List<CueCard> cues;
  final Future<void> Function(CueCard cue) onEdit;
  final void Function(CueCard cue) onDelete;

  @override
  Widget build(BuildContext context) {
    if (cues.isEmpty) {
      return const Center(child: Text('No cues yet. Add one to get started.'));
    }
    return ListView.builder(
      itemCount: cues.length,
      itemBuilder: (context, index) {
        final cue = cues[index];
        return Card(
          child: ListTile(
            title: Text(cue.title),
            subtitle: Text(durationToMMSS(cue.offset)),
            trailing: Wrap(
              spacing: 8,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit cue',
                  onPressed: () => onEdit(cue),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete cue',
                  onPressed: () => onDelete(cue),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CueFormResult {
  const _CueFormResult({required this.title, required this.offset});

  final String title;
  final Duration offset;
}






