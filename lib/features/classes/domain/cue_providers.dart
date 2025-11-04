import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:cycle_coach/features/classes/data/cue_repo.dart';
import 'package:cycle_coach/shared/models/cue_card.dart';
import 'package:cycle_coach/shared/services/audio_player_service.dart';

final cueRepositoryProvider = Provider<CueRepository>((ref) {
  return CueRepository();
});

final cueListProvider = StreamProvider.autoDispose.family<List<CueCard>, String>(
  (ref, songId) {
    final repo = ref.watch(cueRepositoryProvider);
    return repo.watch(songId);
  },
);

final currentCueProvider = Provider.autoDispose.family<CueCard?, String>(
  (ref, songId) {
    final position = ref.watch(positionProvider).value ?? Duration.zero;
    final cues = ref.watch(cueListProvider(songId)).asData?.value ?? const [];
    if (cues.isEmpty) {
      return null;
    }
    CueCard? current;
    for (final cue in cues) {
      if (cue.offset <= position) {
        current = cue;
      } else {
        break;
      }
    }
    return current;
  },
);

final nextCueProvider = Provider.autoDispose.family<CueCard?, String>(
  (ref, songId) {
    final position = ref.watch(positionProvider).value ?? Duration.zero;
    final cues = ref.watch(cueListProvider(songId)).asData?.value ?? const [];
    for (final cue in cues) {
      if (cue.offset > position) {
        return cue;
      }
    }
    return null;
  },
);

final showFlashProvider = Provider.autoDispose.family<bool, String>(
  (ref, songId) {
    final nextCue = ref.watch(nextCueProvider(songId));
    if (nextCue == null) {
      return false;
    }
    final position = ref.watch(positionProvider).value ?? Duration.zero;
    final diff = nextCue.offset - position;
    return !diff.isNegative && diff <= const Duration(seconds: 10);
  },
);
