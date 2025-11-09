import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cycle Coach')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('Create Class'),
              onTap: () => context.go('/create-class'),
            ),
            ListTile(
              leading: const Icon(Icons.library_books_outlined),
              title: const Text('Classes'),
              onTap: () => context.go('/classes'),
            ),
          ],
        ),
      ),
    );
  }
}
