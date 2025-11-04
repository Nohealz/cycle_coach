import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'shared/theme/app_theme.dart';
import 'app_router.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final theme = ref.watch(appThemeProvider);
    return MaterialApp.router(
      title: 'Cycle Coach',
      theme: theme.light,
      darkTheme: theme.dark,
      themeMode: ThemeMode.dark, // default to dark for studio environment
      routerConfig: router,
    );
  }
}

