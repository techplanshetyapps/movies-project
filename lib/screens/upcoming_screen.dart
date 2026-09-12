import 'package:flutter/material.dart';
import '../data/movie_repository.dart';
import '../models/movie.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/simple_movie_grid.dart';

class UpcomingScreen extends StatefulWidget {
  const UpcomingScreen({super.key});

  @override
  State<UpcomingScreen> createState() => _UpcomingScreenState();
}

class _UpcomingScreenState extends State<UpcomingScreen> {
  List<Movie> _movies = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final movies = await MovieRepository.instance.upcoming();
    setState(() {
      _movies = movies;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Upcoming Releases',
      currentRouteLabel: 'Upcoming',
      body: _loading ? const Center(child: CircularProgressIndicator()) : SimpleMovieGrid(movies: _movies),
    );
  }
}
