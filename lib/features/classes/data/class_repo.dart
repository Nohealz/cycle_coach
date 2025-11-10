import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:cycle_coach/features/classes/domain/models/class_model.dart';
import 'package:cycle_coach/shared/services/local_storage_service.dart';

enum PlaylistKind { pre, workout, post }

class ClassRepo extends StateNotifier<List<ClassModel>> {
  ClassRepo(this._ref) : super(const []) {
    _hydrate();
  }

  final Ref _ref;

  LocalStorageService get _storage => _ref.read(localStorageServiceProvider);

  Future<void> _hydrate() async {
    final stored = await _storage.loadClasses();
    if (stored.isNotEmpty) {
      state = stored;
    }
  }

  Future<void> _persist() async {
    await _storage.saveClasses(state);
  }

  void create(ClassModel model) {
    state = [...state, model];
    _persist();
  }

  void update(ClassModel model) {
    state = [
      for (final existing in state)
        if (existing.id == model.id) model else existing,
    ];
    _persist();
  }

  void delete(String id) {
    state = [for (final existing in state) if (existing.id != id) existing];
    _persist();
  }
}

final classesProvider =
    StateNotifierProvider<ClassRepo, List<ClassModel>>((Ref ref) => ClassRepo(ref));
