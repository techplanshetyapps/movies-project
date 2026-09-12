import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../data/movie_repository.dart';
import '../models/movie.dart';
import '../widgets/app_scaffold.dart';

/// Full scene/detail page, always reached by slug — e.g. pushed from the
/// carousel, the grid, the discover table, search results, etc.
class MovieSceneScreen extends StatefulWidget {
  final String slug;
  const MovieSceneScreen({super.key, required this.slug});

  @override
  State<MovieSceneScreen> createState() => _MovieSceneScreenState();
}

class _MovieSceneScreenState extends State<MovieSceneScreen> {
  Movie? _movie;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    final repo = MovieRepository.instance;
    final found = repo.bySlug(widget.slug);
    if (found == null) {
      setState(() => _loading = false);
      return;
    }
    final enriched = await repo.enrich(found);
    setState(() {
      _movie = enriched;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final movie = _movie;
    if (movie == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Scene not found')),
        body: Center(child: Text('No movie for slug "${widget.slug}"')),
      );
    }

    final repo = MovieRepository.instance;
    final inWatchlist = repo.watchlistSlugs.contains(movie.slug);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            actions: [
              IconButton(
                icon: Icon(inWatchlist ? Icons.bookmark : Icons.bookmark_border),
                onPressed: () => setState(() => repo.toggleWatchlist(movie.slug)),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'poster-${movie.slug}',
                child: movie.backdropPath != null
                    ? Image.network('${ApiConfig.imageBaseOriginal}${movie.backdropPath}', fit: BoxFit.cover)
                    : Container(color: Colors.black38),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(movie.title, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  Text('/${movie.slug}',
                      style: TextStyle(fontFamily: 'monospace', color: scheme.onSurface.withValues(alpha: 0.5))),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _statChip(context, Icons.star_rounded, movie.voteAverage.toStringAsFixed(1)),
                      _statChip(context, Icons.how_to_vote_rounded, '${movie.voteCount} votes'),
                      _statChip(context, Icons.language_rounded, movie.originalLanguage.toUpperCase()),
                      if (movie.runtimeMinutes > 0)
                        _statChip(context, Icons.schedule_rounded, '${movie.runtimeMinutes} min'),
                      _statChip(context, Icons.category_rounded, movie.genreNames),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('Overview', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(movie.overview.isEmpty ? 'No overview available.' : movie.overview),
                  const SizedBox(height: 20),
                  if (movie.keywords.isNotEmpty) ...[
                    Text('Keywords', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: movie.keywords.map((k) => Chip(label: Text(k))).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(BuildContext context, IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
    );
  }
}
