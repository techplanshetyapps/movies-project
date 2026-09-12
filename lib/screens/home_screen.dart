import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../config/api_config.dart';
import '../data/movie_repository.dart';
import '../models/movie.dart';
import '../widgets/animated_movie_carousel.dart';
import '../widgets/app_scaffold.dart';
import 'movie_scene_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repo = MovieRepository.instance;
  List<Movie> _animation = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!ApiConfig.isConfigured) {
      setState(() {
        _loading = false;
        _error = 'Add your TMDB Bearer token in lib/config/api_config.dart to load movies.';
      });
      return;
    }
    try {
      final movies = await _repo.loadAnimationTop20();
      setState(() {
        _animation = movies;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Could not load movies: $e';
      });
    }
  }

  void _openScene(Movie movie) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MovieSceneScreen(slug: movie.slug)),
    );
  }

  Future<void> _uploadScene(Movie movie) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    setState(() {
      movie.localOverridePath = picked.path;
      _repo.setLocalOverride(movie.slug, picked.path);
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Scene image updated for "${movie.title}"')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Top 20 Animation',
      currentRouteLabel: 'Home',
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorState(message: _error!, onRetry: _load)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 32),
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                        child: Text(
                          'Featured carousel',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                      ),
                      AnimatedMovieCarousel(movies: _animation, onTap: _openScene),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                        child: Text(
                          'All 20 scenes',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.62,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: _animation.length,
                        itemBuilder: (context, index) {
                          final movie = _animation[index];
                          return _GridTile(
                            movie: movie,
                            onOpen: () => _openScene(movie),
                            onUpload: () => _uploadScene(movie),
                          );
                        },
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _GridTile extends StatelessWidget {
  final Movie movie;
  final VoidCallback onOpen;
  final VoidCallback onUpload;

  const _GridTile({required this.movie, required this.onOpen, required this.onUpload});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Stack(
          fit: StackFit.expand,
          children: [
            movie.posterPath != null
                ? Image.network(
                    '${ApiConfig.imageBase500}${movie.posterPath}',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: Colors.black38),
                  )
                : Container(color: Colors.black38),
            Positioned(
              top: 6,
              right: 6,
              child: Material(
                color: Colors.black54,
                shape: const CircleBorder(),
                child: IconButton(
                  tooltip: 'Upload custom scene image',
                  icon: const Icon(Icons.upload_rounded, color: Colors.white, size: 18),
                  onPressed: onUpload,
                ),
              ),
            ),
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
                  movie.title,
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
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 40, color: Colors.amber),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
