import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cycle_coach/features/class_player/domain/class_player_arguments.dart';
import 'package:cycle_coach/features/classes/data/class_repo.dart';
import 'package:cycle_coach/features/classes/domain/class_providers.dart';

class ClassesListScreen extends ConsumerWidget {
  const ClassesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classes = ref.watch(classesProvider);
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
        title: const Text('Saved Classes'),
        actions: [
          IconButton(
            tooltip: 'New Class',
            onPressed: () => context.push('/create-class'),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: classes.isEmpty
          ? const Center(
              child: Text('No classes yet. Tap the + button to create one.'),
            )
          : ListView.separated(
              itemCount: classes.length,
              separatorBuilder: (context, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = classes[index];
                final workoutCount = item.workoutPlaylist.length;
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text(
                    'Workout tracks: $workoutCount - Updated ${_formatDate(item.updatedAt)}',
                  ),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          ref.read(currentClassIdProvider.notifier).state = item.id;
                          context.push(
                            '/class-player',
                            extra: ClassPlayerLaunchArgs(classId: item.id),
                          );
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Play'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () =>
                            context.push('/create-class', extra: item.id),
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    if (difference == 0) {
      return 'today';
    }
    if (difference == 1) {
      return 'yesterday';
    }
    return '${difference}d ago';
  }
}
