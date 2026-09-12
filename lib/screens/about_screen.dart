import 'package:flutter/material.dart';
import '../widgets/app_scaffold.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppScaffold(
      title: 'About',
      currentRouteLabel: 'About',
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.movie_creation_rounded, color: scheme.secondary, size: 32),
                const SizedBox(width: 12),
                Text('Movie Explorer', style: Theme.of(context).textTheme.headlineMedium),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Movie Explorer is built by a small independent software studio focused on '
              'clean, data-driven media apps. We design fast, accessible interfaces on top '
              'of public film data, following Material 3 guidelines with a strong emphasis '
              'on readability and contrast.',
              style: TextStyle(height: 1.5),
            ),
            const SizedBox(height: 12),
            const Text(
              'This app is powered by The Movie Database (TMDB) API but is not endorsed or '
              'certified by TMDB.',
              style: TextStyle(height: 1.5, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 24),
            Text('Version 1.0.0', style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.6))),
          ],
        ),
      ),
    );
  }
}
