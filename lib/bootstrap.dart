import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO: initialize services (shared_prefs, logging, error reporting, etc.)
  runApp(const ProviderScope(child: App()));
}

