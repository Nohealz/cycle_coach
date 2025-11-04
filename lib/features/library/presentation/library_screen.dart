import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        title: const Text('Library'),
      ),
      body: const Center(child: Text('Playlists & Songs – placeholder')),
    );
  }
}
