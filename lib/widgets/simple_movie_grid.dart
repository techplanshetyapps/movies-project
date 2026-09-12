import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../models/movie.dart';
import '../screens/movie_scene_screen.dart';

class SimpleMovieGrid extends StatelessWidget {
  final List<Movie> movies;
  const SimpleMovieGrid({super.key, required this.movies});

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return const Center(child: Text('Nothing here yet.'));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final m = movies[index];
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => MovieSceneScreen(slug: m.slug)),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                m.posterPath != null
                    ? Image.network('${ApiConfig.imageBase500}${m.posterPath}', fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: Colors.black38))
                    : Container(color: Colors.black38),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                      ),
                    ),
                    child: Text(
                      m.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
