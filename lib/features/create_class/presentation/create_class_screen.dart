import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:uuid/uuid.dart';
import 'package:cycle_coach/features/classes/data/class_repo.dart';
import 'package:cycle_coach/features/classes/domain/cue_providers.dart';
import 'package:cycle_coach/features/classes/domain/models/class_model.dart';
import 'package:cycle_coach/features/classes/domain/models/song_ref.dart';
import 'package:cycle_coach/shared/data/song_repository.dart';
import 'package:cycle_coach/shared/data/song_model.dart';
import 'package:cycle_coach/features/classes/domain/class_providers.dart';
import 'package:cycle_coach/shared/services/audio_player_service.dart';
import 'package:cycle_coach/shared/models/song.dart';
import 'package:cycle_coach/shared/models/cue_card.dart';
import 'package:cycle_coach/shared/utils/formatting.dart';
import 'package:cycle_coach/shared/music/connector.dart';

class CreateClassScreen extends ConsumerStatefulWidget {
  const CreateClassScreen({super.key, this.classId});
  final String? classId;
  @override
  ConsumerState<CreateClassScreen> createState() => _CreateClassScreenState();
}
class _CreateClassScreenState extends ConsumerState<CreateClassScreen> {
  late final TextEditingController _nameController;
  bool _shufflePre = false;
  bool _shufflePost = false;
  final List<_EditableSongEntry> _preSongs = [];
  final List<_EditableSongEntry> _workoutSongs = [];
  final List<_EditableSongEntry> _postSongs = [];
  ClassModel? _originalClass;
  bool _isDirty = false;
  _ClipboardSong? _clipboard;
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController()
      ..addListener(_handleNameChanged);
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_originalClass == null && widget.classId != null) {
      final classes = ref.read(classesProvider);
      for (final item in classes) {
        if (item.id == widget.classId) {
          _originalClass = item;
          break;
        }
      }
      if (_originalClass != null) {
        _hydrateFromClass(_originalClass!);
      }
    }
  }
  void _hydrateFromClass(ClassModel model) {
    _nameController.text = model.name;
    _shufflePre = model.shufflePre;
    _shufflePost = model.shufflePost;
    final songMap = ref.read(songRepositoryProvider);
    _fillEntries(_preSongs, model.prePlaylist, songMap);
    _fillEntries(_workoutSongs, model.workoutPlaylist, songMap);
    _fillEntries(_postSongs, model.postPlaylist, songMap);
  }
  void _fillEntries(
    List<_EditableSongEntry> target,
    List<SongRef> refs,
    Map<String, Song> songMap,
  ) {
    target
      ..clear()
      ..addAll(
        refs
            .map((ref) => MapEntry(ref, songMap[ref.songId]))
            .where((entry) => entry.value != null)
            .map(
              (entry) => _EditableSongEntry(
                song: entry.value!,
                ref: entry.key,
              ),
            ),
      );
    _reindex(target);
  }
  @override
  void dispose() {
    _nameController.removeListener(_handleNameChanged);
    _nameController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final isEditing = _originalClass != null;
    final classRepo = ref.read(classesProvider.notifier);
    final ConnectorType connector = ref.watch(selectedConnectorProvider);
    Future<void> handleAddSong(PlaylistKind playlist) async {
      final existingIds = _entriesFor(playlist)
          .map((entry) => entry.song.id)
          .toSet();
      final selection = await _showAddSongDialog(context, existingIds);
      if (selection == null || selection.songs.isEmpty) {
        return;
      }
      final selectedConnector = selection.connector;
      final songRepoNotifier = ref.read(songRepositoryProvider.notifier);
      final existingSongs = ref.read(songRepositoryProvider);
      final songsToAdd = <Song>[];
      for (final model in selection.songs) {
        final existing = existingSongs[model.id];
        final song = existing?.copyWith(
              duration: Duration(seconds: model.durationSeconds),
              previewUrl: model.previewUrl ?? existing.previewUrl,
            ) ??
            Song(
              id: model.id,
              title: model.title,
              artist: model.artist,
              duration: Duration(seconds: model.durationSeconds),
              source: _connectorToSourceValue(selectedConnector),
              previewUrl: model.previewUrl,
              spotifyId:
                  selectedConnector == ConnectorType.spotify ? model.id : null,
              appleMusicId: selectedConnector == ConnectorType.appleMusic
                  ? model.id
                  : null,
            );
        songRepoNotifier.upsert(song);
        songsToAdd.add(song);
      }
      setState(() {
        final list = _entriesFor(playlist);
        for (final song in songsToAdd) {
          list.add(
            _EditableSongEntry(
              song: song,
              ref: SongRef(songId: song.id, orderIndex: list.length),
            ),
          );
        }
        _reindex(list);
        _isDirty = true;
      });
    }
    Future<void> handleEditCues(
      PlaylistKind playlist,
      _EditableSongEntry entry,
    ) async {
      await _showCueEditorDialog(entry.song);
    }
  Future<void> handleSave() async {
    final name = _nameController.text.trim();
      if (name.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Give this class a name.')),
        );
        return;
      }
      if (_preSongs.isEmpty && _workoutSongs.isEmpty && _postSongs.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add at least one song.')),
        );
        return;
      }
      final now = DateTime.now();
      final classId = _originalClass?.id ?? const Uuid().v4();
      SongRef mapRef(_EditableSongEntry entry, int index) =>
          entry.ref.copyWith(orderIndex: index, songId: entry.song.id);
      final model = ClassModel(
        id: classId,
        name: name,
        createdAt: _originalClass?.createdAt ?? now,
        updatedAt: now,
        prePlaylist: [
          for (var i = 0; i < _preSongs.length; i++) mapRef(_preSongs[i], i),
        ],
        workoutPlaylist: [
          for (var i = 0; i < _workoutSongs.length; i++)
            mapRef(_workoutSongs[i], i),
        ],
        postPlaylist: [
          for (var i = 0; i < _postSongs.length; i++) mapRef(_postSongs[i], i),
        ],
        shufflePre: _shufflePre,
        shufflePost: _shufflePost,
      );
      if (_originalClass == null) {
        classRepo.create(model);
      } else {
        classRepo.update(model);
      }
      _originalClass = model;
      ref.read(currentClassIdProvider.notifier).state = classId;
      if (!mounted) return;
      setState(() {
        _isDirty = false;
      });
      final outerContext = context;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Class "$name" saved.')),
      );
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Class Saved'),
            content: const Text('What would you like to do next?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  outerContext.go('/');
                },
                child: const Text('Main Menu'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  outerContext.go('/class-player');
                },
                child: const Text('Open Class Player'),
              ),
            ],
          );
        },
      );
    }

    final workoutDuration = _workoutSongs.fold<Duration>(
      Duration.zero,
      (acc, entry) => acc + entry.song.duration,
    );
    final hasClipboard = _clipboard != null;

    final sections = [
      _PlaylistSectionConfig(
        title: 'Pre-Workout',
        kind: PlaylistKind.pre,
        entries: _preSongs,
        allowShuffle: true,
        shuffleValue: _shufflePre,
        onShuffleChanged: (value) => setState(() {
          _shufflePre = value;
          _isDirty = true;
        }),
      ),
      _PlaylistSectionConfig(
        title: 'Workout',
        kind: PlaylistKind.workout,
        entries: _workoutSongs,
        totalDurationLabel: workoutDuration > Duration.zero
            ? _formatPlaylistDuration(workoutDuration)
            : null,
      ),
      _PlaylistSectionConfig(
        title: 'Post-Workout',
        kind: PlaylistKind.post,
        entries: _postSongs,
        allowShuffle: true,
        shuffleValue: _shufflePost,
        onShuffleChanged: (value) => setState(() {
          _shufflePost = value;
          _isDirty = true;
        }),
      ),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        final navigator = Navigator.of(context);
        final router = GoRouter.of(context);
        if (didPop) {
          return;
        }
        final shouldLeave = await _confirmDiscardChanges();
        if (shouldLeave) {
          if (navigator.canPop()) {
            navigator.pop();
          } else {
            router.go('/');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: _handleBackPressed),
          title: Text(isEditing ? 'Edit Class' : 'Create Class'),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                onPressed: _handleStartOver,
                child: const Text('Start Over'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: _canSave
                  ? FilledButton(
                      onPressed: handleSave,
                      child: const Text('Save'),
                    )
                  : GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _showSaveRequirements,
                      child: AbsorbPointer(
                        child: FilledButton(
                          onPressed: null,
                          child: const Text('Save'),
                        ),
                      ),
                    ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  label: Center(child: Text('Class Name')),
                  floatingLabelAlignment: FloatingLabelAlignment.center,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ConnectorType>(
                key: ValueKey(connector),
                initialValue: connector,
                alignment: Alignment.center,
                isExpanded: true,
                decoration: const InputDecoration(
                  label: Center(child: Text('Music Source')),
                  floatingLabelAlignment: FloatingLabelAlignment.center,
                  contentPadding: EdgeInsets.symmetric(horizontal: 32),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
                icon: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem<ConnectorType>(
                    value: ConnectorType.spotify,
                    child: Center(child: Text('Spotify')),
                  ),
                  DropdownMenuItem<ConnectorType>(
                    value: ConnectorType.appleMusic,
                    child: Center(child: Text('Apple Music')),
                  ),
                  DropdownMenuItem<ConnectorType>(
                    value: ConnectorType.webUpload,
                    child: Center(child: Text('Web Upload')),
                  ),
                ],
                selectedItemBuilder: (context) => const [
                  Align(
                    alignment: Alignment.center,
                    child: Text('Spotify', textAlign: TextAlign.center),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text('Apple Music', textAlign: TextAlign.center),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text('Web Upload', textAlign: TextAlign.center),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    ref.read(selectedConnectorProvider.notifier).state = value;
                  }
                },
          ),
          const SizedBox(height: 24),
              for (final section in sections)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: _PlaylistEditor(
                  config: section,
                  onAddSong: () => handleAddSong(section.kind),
                  canPaste: hasClipboard,
                  onPasteSong: hasClipboard
                      ? () {
                          _handlePasteSong(section.kind);
                        }
                      : null,
                  onDeleteSong: (index) => setState(() {
                    final list = _entriesFor(section.kind);
                    if (index >= 0 && index < list.length) {
                      list.removeAt(index);
                      _reindex(list);
                      _isDirty = true;
                    }
                  }),
                  onReorderSong: (oldIndex, newIndex) => setState(() {
                    final list = _entriesFor(section.kind);
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    if (newIndex < 0 || newIndex >= list.length) {
                      return;
                    }
                    final entry = list.removeAt(oldIndex);
                    list.insert(newIndex, entry);
                    _reindex(list);
                    _isDirty = true;
                  }),
                  onEntryLongPress: (entry, index, position) =>
                      _handleSongContextMenu(
                        section.kind,
                        entry,
                        index,
                        position,
                      ),
                  onEditCues: (entry) => handleEditCues(section.kind, entry),
                ),
              ),
          ],
        ),
      ),
    ));
  }
  List<_EditableSongEntry> _entriesFor(PlaylistKind kind) {
    switch (kind) {
      case PlaylistKind.pre:
        return _preSongs;
      case PlaylistKind.workout:
        return _workoutSongs;
      case PlaylistKind.post:
        return _postSongs;
    }
  }
  String _connectorToSourceValue(ConnectorType connector) {
    switch (connector) {
      case ConnectorType.spotify:
        return 'spotify';
      case ConnectorType.appleMusic:
        return 'apple';
      case ConnectorType.webUpload:
        return 'web';
    }
  }

  String _formatPlaylistDuration(Duration duration) {
    if (duration.inHours >= 1) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
      final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
      return '$hours:$minutes:$seconds';
    }
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _handleStartOver() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Over?'),
        content: const Text('This will remove all songs and cues for this class draft.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Start Over'),
          ),
        ],
      ),
    );
    if (confirm != true) {
      return;
    }

    final cueRepo = ref.read(cueRepositoryProvider);
    final songIds = <String>{
      for (final entry in _preSongs) entry.song.id,
      for (final entry in _workoutSongs) entry.song.id,
      for (final entry in _postSongs) entry.song.id,
    };
    for (final songId in songIds) {
      final cues = cueRepo.list(songId);
      for (final cue in cues) {
        cueRepo.remove(songId, cue.id);
      }
    }

    setState(() {
      _preSongs.clear();
      _workoutSongs.clear();
      _postSongs.clear();
      _shufflePre = false;
      _shufflePost = false;
      _isDirty = true;
    });
  }

  void _reindex(List<_EditableSongEntry> entries) {
    for (var i = 0; i < entries.length; i++) {
      entries[i] = entries[i].copyWith(
        ref: entries[i].ref.copyWith(orderIndex: i),
      );
    }
  }
  void _handleNameChanged() {
    if (!context.mounted) {
      return;
    }
    setState(() {
      _isDirty = true;
    });
  }

  void _markDirty() {
    if (!_isDirty && mounted) {
      setState(() {
        _isDirty = true;
      });
    }
  }

  Future<bool> _confirmDiscardChanges() async {
    if (!_isDirty) {
      return true;
    }
    final shouldDiscard = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Discard changes?'),
            content: const Text('You have unsaved edits. Leave without saving?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Stay'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Discard'),
              ),
            ],
          ),
        ) ??
        false;
    if (shouldDiscard && mounted) {
      setState(() {
        _isDirty = false;
      });
    }
    return shouldDiscard;
  }

  void _showSaveRequirements() {
    if (!mounted) {
      return;
    }
    final requirements = <String>[];
    if (_nameController.text.trim().isEmpty) {
      requirements.add('Add a class name.');
    }
    if (_preSongs.isEmpty && _workoutSongs.isEmpty && _postSongs.isEmpty) {
      requirements.add('Add at least one song.');
    }
    if (requirements.isEmpty) {
      requirements.add('Ready to save.');
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(requirements.join('\n'))),
    );
  }

  Future<void> _handleSongContextMenu(
    PlaylistKind kind,
    _EditableSongEntry entry,
    int index,
    Offset position,
  ) async {
    if (!mounted) {
      return;
    }
    final overlay = Overlay.of(context);
    final renderBox = overlay.context.findRenderObject() as RenderBox?;
    final menuPosition = renderBox == null
        ? RelativeRect.fill
        : RelativeRect.fromRect(
            Rect.fromLTWH(position.dx, position.dy, 0, 0),
            Offset.zero & renderBox.size,
          );
    final clipboardAvailable = _clipboard != null;
    final action = await showMenu<_SongContextAction>(
      context: context,
      position: menuPosition,
      items: [
        const PopupMenuItem<_SongContextAction>(
          value: _SongContextAction.copy,
          child: Text('Copy song'),
        ),
        if (clipboardAvailable)
          const PopupMenuItem<_SongContextAction>(
            value: _SongContextAction.pasteAbove,
            child: Text('Paste above'),
          ),
        if (clipboardAvailable)
          const PopupMenuItem<_SongContextAction>(
            value: _SongContextAction.pasteBelow,
            child: Text('Paste below'),
          ),
      ],
    );
    if (!mounted) {
      return;
    }
    switch (action) {
      case _SongContextAction.copy:
        final cueRepo = ref.read(cueRepositoryProvider);
        final cueCount = cueRepo.list(entry.song.id).length;
        setState(() {
          _clipboard = _ClipboardSong(song: entry.song);
        });
        final cueSuffix = cueCount == 0
            ? ''
            : ' with $cueCount cue${cueCount == 1 ? '' : 's'}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Copied "${entry.song.title}"$cueSuffix.')),
        );
        break;
      case _SongContextAction.pasteAbove:
        await _handlePasteSong(kind, insertIndex: index);
        break;
      case _SongContextAction.pasteBelow:
        await _handlePasteSong(kind, insertIndex: index + 1);
        break;
      case null:
        break;
    }
  }

  Future<void> _handlePasteSong(
    PlaylistKind kind, {
    int? insertIndex,
  }) async {
    final data = _clipboard;
    if (data == null) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copy a song first.')),
      );
      return;
    }
    final songRepoNotifier = ref.read(songRepositoryProvider.notifier);
    final newSong = data.song.copyWith(id: const Uuid().v4());
    songRepoNotifier.upsert(newSong);
    final list = _entriesFor(kind);
    final targetIndex =
        insertIndex == null ? list.length : insertIndex.clamp(0, list.length);
    setState(() {
      list.insert(
        targetIndex,
        _EditableSongEntry(
          song: newSong,
          ref: SongRef(songId: newSong.id, orderIndex: targetIndex),
        ),
      );
      _reindex(list);
      _isDirty = true;
    });
    final cueRepo = ref.read(cueRepositoryProvider);
    cueRepo.copyAll(data.song.id, newSong.id);
    setState(() {
      _clipboard = null;
    });
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pasted "${data.song.title}".')),
    );
  }

  Future<void> _handleBackPressed() async {
    final navigator = Navigator.of(context);
    final router = GoRouter.of(context);
    final shouldLeave = await _confirmDiscardChanges();
    if (!shouldLeave || !mounted) {
      return;
    }
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      router.go('/');
    }
  }
  Future<({ConnectorType connector, List<SongModel> songs})?>
      _showAddSongDialog(BuildContext context, Set<String> existingSongIds) async {
    var connector = ref.read(selectedConnectorProvider);
    final result =
        await showDialog<({ConnectorType connector, List<SongModel> songs})?>(
      context: context,
      builder: (context) {
        final selectedIds = <String>{};
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Consumer(
              builder: (context, dialogRef, _) {
                final catalogAsync =
                    dialogRef.watch(catalogProvider(connector));
                var currentCatalog = <SongModel>[];
                final catalogBody = catalogAsync.when(
                  data: (songs) {
                    final availableSongs = songs
                        .where((song) => !existingSongIds.contains(song.id))
                        .toList();
                    currentCatalog = availableSongs;
                    if (availableSongs.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          existingSongIds.isEmpty
                              ? 'Coming soon'
                              : 'All songs from this source are already in the playlist.',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return SizedBox(
                      width: double.maxFinite,
                      height: 300,
                      child: ListView.builder(
                        itemCount: availableSongs.length,
                        itemBuilder: (context, index) {
                          final song = availableSongs[index];
                          final isSelected = selectedIds.contains(song.id);
                          return CheckboxListTile(
                            value: isSelected,
                            onChanged: (checked) {
                              setStateDialog(() {
                                if (checked ?? false) {
                                  selectedIds.add(song.id);
                                } else {
                                  selectedIds.remove(song.id);
                                }
                              });
                            },
                            title: Text(song.title),
                            subtitle: Text(
                              '${song.artist} - ${durationToMMSS(Duration(seconds: song.durationSeconds))}',
                            ),
                            secondary: song.previewUrl != null
                                ? const Icon(Icons.audiotrack)
                                : null,
                          );
                        },
                      ),
                    );
                  },
                  loading: () => const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, _) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'Failed to load catalog: $error',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
                final canAdd = selectedIds.isNotEmpty;
                return AlertDialog(
                  title: const Center(
                    child: Text('Add Song', textAlign: TextAlign.center),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<ConnectorType>(
                          key: ValueKey(connector),
                          initialValue: connector,
                          alignment: Alignment.center,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            label: Center(child: Text('Source')),
                            floatingLabelAlignment:
                                FloatingLabelAlignment.center,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 32),
                            suffixIcon: Icon(Icons.arrow_drop_down),
                          ),
                          icon: const SizedBox.shrink(),
                          items: const [
                            DropdownMenuItem<ConnectorType>(
                              value: ConnectorType.spotify,
                              child: Center(child: Text('Spotify')),
                            ),
                            DropdownMenuItem<ConnectorType>(
                              value: ConnectorType.appleMusic,
                              child: Center(child: Text('Apple Music')),
                            ),
                            DropdownMenuItem<ConnectorType>(
                              value: ConnectorType.webUpload,
                              child: Center(child: Text('Web Upload')),
                            ),
                          ],
                          selectedItemBuilder: (context) => const [
                            Align(
                              alignment: Alignment.center,
                              child:
                                  Text('Spotify', textAlign: TextAlign.center),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Text('Apple Music',
                                  textAlign: TextAlign.center),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Text('Web Upload',
                                  textAlign: TextAlign.center),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setStateDialog(() {
                                connector = value;
                                selectedIds.clear();
                              });
                              dialogRef
                                  .read(selectedConnectorProvider.notifier)
                                  .state = value;
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        catalogBody,
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: canAdd
                          ? () {
                              final songs = currentCatalog
                                  .where((song) => selectedIds.contains(song.id))
                                  .toList();
                              Navigator.of(context).pop((
                                connector: connector,
                                songs: songs,
                              ));
                            }
                          : null,
                      child: Text('Add (${selectedIds.length})'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
    return result;
  }

Future<void> _showCueEditorDialog(Song song) async {
    final cueRepo = ref.read(cueRepositoryProvider);
    final audioService = ref.read(audioPlayerServiceProvider);
    await showDialog<void>(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, dialogRef, _) {
            return StatefulBuilder(
              builder: (context, setStateDialog) {
                final cues = cueRepo.list(song.id);
                final previewUrl = song.previewUrl;
                final messenger = ScaffoldMessenger.of(context);
                final position = dialogRef.watch(positionProvider).maybeWhen(
                      data: (value) => value,
                      orElse: () => Duration.zero,
                    );
                final durationFromStream = dialogRef
                        .watch(durationProvider)
                        .maybeWhen(data: (value) => value, orElse: () => null) ??
                    song.duration;
                final isPlaying = dialogRef.watch(playingProvider).maybeWhen(
                      data: (value) => value,
                      orElse: () => false,
                    );
                final processing = dialogRef
                    .watch(processingStateProvider)
                    .maybeWhen(
                      data: (value) => value,
                      orElse: () => ProcessingState.idle,
                    );
                final isBuffering = processing == ProcessingState.loading ||
                    processing == ProcessingState.buffering;

                Future<bool> ensureLoaded() async {
                  if (previewUrl == null || previewUrl.isEmpty) {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('No preview available for this song.'),
                      ),
                    );
                    return false;
                  }
                  if (audioService.currentUrl != previewUrl) {
                    try {
                      await audioService.load(previewUrl);
                      await audioService.seek(Duration.zero);
                    } catch (error) {
                      messenger.showSnackBar(
                        SnackBar(content: Text('Audio error: $error')),
                      );
                      return false;
                    }
                  }
                  return true;
                }

                Future<void> togglePlayback() async {
                  final ready = await ensureLoaded();
                  if (!ready) return;
                  if (isPlaying) {
                    await audioService.pause();
                  } else {
                    await audioService.play();
                  }
                }

                Future<void> seekToMilliseconds(int targetMs) async {
                  final maxMs = durationFromStream.inMilliseconds;
                  final safeMax = maxMs < 0 ? 0 : maxMs;
                  final clamped = targetMs.clamp(0, safeMax).toInt();
                  await audioService.seek(Duration(milliseconds: clamped));
                }

                Future<void> seekRelativeSeconds(int seconds) async {
                  final target = position.inMilliseconds + (seconds * 1000);
                  await seekToMilliseconds(target);
                }

                Future<void> addCueAtCurrentPosition() async {
                  final ready = await ensureLoaded();
                  if (!ready || !context.mounted) {
                    return;
                  }
                  final result = await _showCueFormDialog(
                    context: context,
                    maxDuration: durationFromStream,
                    initialOffset: Duration(milliseconds: position.inMilliseconds),
                  );
                  if (!context.mounted) return;
                  if (result == null) return;
                  cueRepo.add(
                    song.id,
                    CueCard(
                      id: const Uuid().v4(),
                      title: result.title,
                      offset: result.offset,
                    ),
                  );
                  setStateDialog(() {});
                  if (mounted) _markDirty();
                }

                Future<void> editCue(CueCard cue) async {
                  final result = await _showCueFormDialog(
                    context: context,
                    initial: cue,
                    maxDuration: durationFromStream,
                  );
                  if (!context.mounted) return;
                  if (result == null) return;
                  cueRepo.update(
                    song.id,
                    cue.copyWith(
                      title: result.title,
                      offset: result.offset,
                    ),
                  );
                  setStateDialog(() {});
                  if (mounted) _markDirty();
                }

                void removeCue(CueCard cue) {
                  cueRepo.remove(song.id, cue.id);
                  setStateDialog(() {});
                  if (mounted) _markDirty();
                }

                final sliderMaxMs = durationFromStream.inMilliseconds;
                final sliderMax = sliderMaxMs > 0 ? sliderMaxMs.toDouble() : 1.0;
                final sliderValue = position.inMilliseconds
                    .clamp(0, sliderMaxMs > 0 ? sliderMaxMs : 0)
                    .toDouble();
                final canSeek = sliderMaxMs > 0;

                Widget playbackControls;
                if (previewUrl == null || previewUrl.isEmpty) {
                  playbackControls = const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('No preview available for this song.'),
                  );
                } else {
                  playbackControls = Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _CueControlButton(
                            label: '-10s',
                            onPressed:
                                canSeek ? () => seekRelativeSeconds(-10) : null,
                          ),
                          const SizedBox(width: 12),
                          _CueControlButton(
                            label: '-5s',
                            onPressed:
                                canSeek ? () => seekRelativeSeconds(-5) : null,
                          ),
                          const SizedBox(width: 12),
                          FilledButton.icon(
                            onPressed: isBuffering ? null : togglePlayback,
                            icon: isBuffering
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                            label: Text(isPlaying ? 'Pause' : 'Play'),
                          ),
                          const SizedBox(width: 12),
                          _CueControlButton(
                            label: '+5s',
                            onPressed:
                                canSeek ? () => seekRelativeSeconds(5) : null,
                          ),
                          const SizedBox(width: 12),
                          _CueControlButton(
                            label: '+10s',
                            onPressed:
                                canSeek ? () => seekRelativeSeconds(10) : null,
                          ),
                        ],
                      ),
                      Slider(
                        value: sliderValue,
                        max: sliderMax,
                        onChanged: canSeek
                            ? (value) => seekToMilliseconds(value.round())
                            : null,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${durationToMMSS(position)} / ${durationToMMSS(durationFromStream)}',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    ],
                  );
                }

                final cuesList = cues.isEmpty
                    ? const Center(
                        child: Text('No cues yet. Tap "Add Cue" to create one.'),
                      )
                    : ListView.builder(
                        itemCount: cues.length,
                        itemBuilder: (context, index) {
                          final cue = cues[index];
                          return ListTile(
                            title: Text(cue.title),
                            subtitle: Text(durationToMMSS(cue.offset)),
                            trailing: Wrap(
                              spacing: 4,
                              children: [
                                IconButton(
                                  tooltip: 'Edit cue',
                                  onPressed: () => editCue(cue),
                                  icon: const Icon(Icons.edit),
                                ),
                                IconButton(
                                  tooltip: 'Delete cue',
                                  onPressed: () => removeCue(cue),
                                  icon: const Icon(Icons.delete),
                                ),
                              ],
                            ),
                          );
                        },
                      );

                return AlertDialog(
                  title: Center(
                    child: Text(
                      'Cues for ${song.title}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  content: SizedBox(
                    width: double.maxFinite,
                    height: 420,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        playbackControls,
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.center,
                          child: FilledButton.icon(
                            onPressed: previewUrl == null || previewUrl.isEmpty
                                ? null
                                : addCueAtCurrentPosition,
                            icon: const Icon(Icons.push_pin),
                            label: const Text('Mark cue @ current time'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(child: cuesList),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
    await audioService.pause();
    if (audioService.hasLoaded) {
      await audioService.seek(Duration.zero);
    }
  }

Future<({String title, Duration offset})?> _showCueFormDialog({
    required BuildContext context,
    CueCard? initial,
    Duration? initialOffset,
    required Duration maxDuration,
  }) async {
  final titleController = TextEditingController(text: initial?.title ?? '');
  final defaultOffset = initial?.offset ?? initialOffset ?? Duration.zero;
  final offsetController = TextEditingController(
    text: durationToMMSS(defaultOffset),
  );
  String? error;

  final result = await showDialog<({String title, Duration offset})?>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setStateDialog) {
          void submit() {
            final title = titleController.text.trim();
            final parsed = parseDurationFromMMSS(offsetController.text);
            if (title.isEmpty) {
              setStateDialog(() => error = 'Title cannot be empty.');
              return;
            }
            if (parsed == null) {
              setStateDialog(() => error = 'Time must be in mm:ss format.');
              return;
            }
            if (parsed < Duration.zero || parsed >= maxDuration) {
              setStateDialog(
                () => error = 'Time must fall within the song duration.',
              );
              return;
            }
            Navigator.of(context).pop((title: title, offset: parsed));
          }

          return AlertDialog(
            title: Text(initial == null ? 'Add Cue' : 'Edit Cue'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: offsetController,
                  decoration: InputDecoration(
                    labelText: 'Offset (mm:ss)',
                    errorText: error,
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: submit,
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );

  titleController.dispose();
  offsetController.dispose();
  return result;
}

  bool get _canSave =>
      _nameController.text.trim().isNotEmpty &&
      (_preSongs.isNotEmpty || _workoutSongs.isNotEmpty || _postSongs.isNotEmpty);
}
class _PlaylistSectionConfig {
  _PlaylistSectionConfig({
    required this.title,
    required this.kind,
    required this.entries,
    this.allowShuffle = false,
    this.shuffleValue = false,
    this.onShuffleChanged,
    this.totalDurationLabel,
  });
  final String title;
  final PlaylistKind kind;
  final List<_EditableSongEntry> entries;
  final bool allowShuffle;
  final bool shuffleValue;
  final ValueChanged<bool>? onShuffleChanged;
  final String? totalDurationLabel;
}
class _PlaylistEditor extends StatelessWidget {
  const _PlaylistEditor({
    required this.config,
    required this.onAddSong,
    required this.canPaste,
    this.onPasteSong,
    required this.onDeleteSong,
    required this.onReorderSong,
    required this.onEditCues,
    required this.onEntryLongPress,
  });
  final _PlaylistSectionConfig config;
  final VoidCallback onAddSong;
  final bool canPaste;
  final VoidCallback? onPasteSong;
  final void Function(int index) onDeleteSong;
  final void Function(int oldIndex, int newIndex) onReorderSong;
  final void Function(_EditableSongEntry entry) onEditCues;
  final Future<void> Function(
    _EditableSongEntry entry,
    int index,
    Offset position,
  ) onEntryLongPress;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: config.allowShuffle ? 96 : 64,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          config.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (config.totalDurationLabel != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              config.totalDurationLabel!,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (config.allowShuffle)
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Switch.adaptive(
                                  value: config.shuffleValue,
                                  onChanged: config.onShuffleChanged,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Shuffle playback',
                                  style:
                                      Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        if (canPaste && onPasteSong != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: OutlinedButton.icon(
                              onPressed: onPasteSong,
                              icon: const Icon(Icons.content_paste),
                              label: const Text('Paste Song'),
                            ),
                          ),
                        FilledButton.icon(
                          onPressed: onAddSong,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Song'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (config.entries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No songs yet.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            else
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                buildDefaultDragHandles: false,
                itemCount: config.entries.length,
                onReorder: onReorderSong,
                itemBuilder: (context, index) {
                  final entry = config.entries[index];
                  return Padding(
                    key: ValueKey(entry.song.id),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        ReorderableDelayedDragStartListener(
                          index: index,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Icon(
                              Icons.drag_handle,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ),
                        Expanded(
                          child: _ReorderableSongTile(
                            entry: entry,
                            onShowMenu: (entry, position) =>
                                onEntryLongPress(entry, index, position),
                            child: _PlaylistSongTile(
                              entry: entry,
                              displayIndex: index,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Edit cues',
                          onPressed: () => onEditCues(entry),
                          icon: const Icon(Icons.sticky_note_2_outlined),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        IconButton(
                          tooltip: 'Remove',
                          onPressed: () => onDeleteSong(index),
                          icon: const Icon(Icons.delete),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _PlaylistSongTile extends ConsumerWidget {
  const _PlaylistSongTile({
    required this.entry,
    required this.displayIndex,
  });

  final _EditableSongEntry entry;
  final int displayIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cueCount = ref.watch(cueListProvider(entry.song.id)).maybeWhen(
      data: (cues) => cues.length,
      orElse: () => 0,
    );
    final cueLabel = cueCount == 1 ? '1 cue' : '$cueCount cues';
    const indexWidth = 48.0; // supports up to 4 digits with spacing
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: indexWidth,
            child: Text(
              '${displayIndex + 1}',
              textAlign: TextAlign.left,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${entry.song.title} • ${entry.song.artist}',
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(left: indexWidth + 12),
        child: Text(
          '$cueLabel • ${durationToMMSS(entry.song.duration)}',
          textAlign: TextAlign.left,
        ),
      ),
    );
  }
}

class _ReorderableSongTile extends StatefulWidget {
  const _ReorderableSongTile({
    required this.entry,
    required this.child,
    required this.onShowMenu,
  });
  final _EditableSongEntry entry;
  final Widget child;
  final Future<void> Function(
    _EditableSongEntry entry,
    Offset position,
  ) onShowMenu;

  @override
  State<_ReorderableSongTile> createState() => _ReorderableSongTileState();
}

class _ReorderableSongTileState extends State<_ReorderableSongTile> {
  Offset? _tapPosition;

  void _openMenu(Offset position) {
    widget.onShowMenu(widget.entry, position);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (details) => _tapPosition = details.globalPosition,
      onLongPressStart: (details) {
        final position = _tapPosition ?? details.globalPosition;
        _openMenu(position);
      },
      child: widget.child,
    );
  }
}

class _EditableSongEntry {
  _EditableSongEntry({required this.song, required this.ref});
  final Song song;
  final SongRef ref;
  _EditableSongEntry copyWith({Song? song, SongRef? ref}) {
    return _EditableSongEntry(
      song: song ?? this.song,
      ref: ref ?? this.ref,
    );
  }
}




class _ClipboardSong {
  _ClipboardSong({required this.song});
  final Song song;
}

enum _SongContextAction { copy, pasteAbove, pasteBelow }

class _CueControlButton extends StatelessWidget {
  const _CueControlButton({
    required this.label,
    this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(60, 40),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      child: Text(label),
    );
  }
}
