import 'package:flutter/material.dart';
import '../data/genres.dart';
import '../data/movie_repository.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/simple_movie_grid.dart';
import '../models/movie.dart';

class GenresScreen extends StatefulWidget {
  const GenresScreen({super.key});

  @override
  State<GenresScreen> createState() => _GenresScreenState();
}

class _GenresScreenState extends State<GenresScreen> {
  GenreDef? _selected;
  List<Movie> _movies = [];
  bool _loading = false;

  Future<void> _select(GenreDef g) async {
    setState(() {
      _selected = g;
      _loading = true;
    });
    final movies = await MovieRepository.instance.loadDiscoverPool(pages: 1, genreId: g.id);
    setState(() {
      _movies = movies;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Genres',
      currentRouteLabel: 'Genres',
      body: Column(
        children: [
          SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              itemCount: kGenres.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final g = kGenres[i];
                final selected = _selected?.id == g.id;
                return ChoiceChip(
                  avatar: Icon(g.icon, size: 14),
                  label: Text(g.name),
                  selected: selected,
                  onSelected: (_) => _select(g),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _selected == null
                ? const Center(child: Text('Pick a genre to browse.'))
                : _loading
                    ? const Center(child: CircularProgressIndicator())
                    : SimpleMovieGrid(movies: _movies),
          ),
        ],
      ),
    );
  }
}
