import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:cycle_coach/features/classes/domain/models/class_model.dart';

enum PlaylistKind { pre, workout, post }

class ClassRepo extends StateNotifier<List<ClassModel>> {
  ClassRepo() : super(const []);

  void create(ClassModel model) {
    state = [...state, model];
  }

  void update(ClassModel model) {
    state = [
      for (final existing in state)
        if (existing.id == model.id) model else existing,
    ];
  }

  void delete(String id) {
    state = [for (final existing in state) if (existing.id != id) existing];
  }
}

final classesProvider =
    StateNotifierProvider<ClassRepo, List<ClassModel>>((Ref ref) => ClassRepo());
