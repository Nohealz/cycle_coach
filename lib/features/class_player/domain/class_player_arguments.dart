import 'package:cycle_coach/features/classes/data/class_repo.dart';

class ClassPlayerLaunchArgs {
  const ClassPlayerLaunchArgs({
    this.classId,
    this.initialPlaylist,
    this.initialSongId,
    this.initialSongIndex,
  });

  final String? classId;
  final PlaylistKind? initialPlaylist;
  final String? initialSongId;
  final int? initialSongIndex;
}

