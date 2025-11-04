import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AppTheme {
  final ThemeData dark;
  final ThemeData light;
  const AppTheme({required this.dark, required this.light});
}

final appThemeProvider = Provider<AppTheme>((ref) {
  final dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.teal,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF0D0D0D),
    appBarTheme: const AppBarTheme(centerTitle: true),
    visualDensity: VisualDensity.comfortable,
  );

  final light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
    appBarTheme: const AppBarTheme(centerTitle: true),
    visualDensity: VisualDensity.comfortable,
  );

  return AppTheme(dark: dark, light: light);
});

