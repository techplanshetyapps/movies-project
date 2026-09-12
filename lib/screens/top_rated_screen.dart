import 'package:flutter/material.dart';
import '../data/movie_repository.dart';
import '../models/movie.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/simple_movie_grid.dart';

class TopRatedScreen extends StatefulWidget {
  const TopRatedScreen({super.key});

  @override
  State<TopRatedScreen> createState() => _TopRatedScreenState();
}

class _TopRatedScreenState extends State<TopRatedScreen> {
  List<Movie> _movies = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final movies = await MovieRepository.instance.topRated();
    setState(() {
      _movies = movies;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Top Rated',
      currentRouteLabel: 'Top Rated',
      body: _loading ? const Center(child: CircularProgressIndicator()) : SimpleMovieGrid(movies: _movies),
    );
  }
}
