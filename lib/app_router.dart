import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'features/home/presentation/home_screen.dart';
import 'features/create_class/presentation/create_class_screen.dart';
import 'features/classes/presentation/classes_list_screen.dart';
import 'features/class_player/domain/class_player_arguments.dart';
import 'features/class_player/presentation/class_player_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/create-class',
        name: 'createClass',
        builder: (context, state) {
          final classId = state.extra as String? ?? state.uri.queryParameters['id'];
          return CreateClassScreen(classId: classId);
        },
      ),
      GoRoute(
        path: '/classes',
        name: 'classes',
        builder: (context, state) => const ClassesListScreen(),
      ),
      GoRoute(
        path: '/class-player',
        name: 'classPlayer',
        builder: (context, state) {
          final args = state.extra as ClassPlayerLaunchArgs?;
          return ClassPlayerScreen(initialArgs: args);
        },
      ),
    ],
  );
});
