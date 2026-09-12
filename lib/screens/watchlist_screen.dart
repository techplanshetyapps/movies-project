import 'package:flutter/material.dart';
import '../data/movie_repository.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/simple_movie_grid.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  @override
  Widget build(BuildContext context) {
    final movies = MovieRepository.instance.watchlistMovies;
    return AppScaffold(
      title: 'Watchlist (${movies.length})',
      currentRouteLabel: 'Watchlist',
      body: movies.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Bookmark a movie from its scene page and it will show up here.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : SimpleMovieGrid(movies: movies),
    );
  }
}
