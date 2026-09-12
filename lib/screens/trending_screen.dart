import 'package:flutter/material.dart';
import '../data/movie_repository.dart';
import '../models/movie.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/simple_movie_grid.dart';

class TrendingScreen extends StatefulWidget {
  const TrendingScreen({super.key});

  @override
  State<TrendingScreen> createState() => _TrendingScreenState();
}

class _TrendingScreenState extends State<TrendingScreen> {
  List<Movie> _movies = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final movies = await MovieRepository.instance.trending();
    setState(() {
      _movies = movies;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Trending This Week',
      currentRouteLabel: 'Trending',
      body: _loading ? const Center(child: CircularProgressIndicator()) : SimpleMovieGrid(movies: _movies),
    );
  }
}
