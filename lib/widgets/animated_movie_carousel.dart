import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../models/movie.dart';

class AnimatedMovieCarousel extends StatefulWidget {
  final List<Movie> movies;
  final void Function(Movie movie) onTap;
  final double height;

  const AnimatedMovieCarousel({
    super.key,
    required this.movies,
    required this.onTap,
    this.height = 340,
  });

  @override
  State<AnimatedMovieCarousel> createState() => _AnimatedMovieCarouselState();
}

class _AnimatedMovieCarouselState extends State<AnimatedMovieCarousel> {
  late final PageController _controller = PageController(viewportFraction: 0.62);
  int _current = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.movies.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: const Center(child: Text('No movies to show yet.')),
      );
    }
    return SizedBox(
      height: widget.height,
      child: PageView.builder(
        controller: _controller,
        itemCount: widget.movies.length,
        onPageChanged: (index) => setState(() => _current = index),
        itemBuilder: (context, index) {
          final movie = widget.movies[index];
          final isActive = index == _current;
          return Center(
            child: _BounceInCard(
              key: ValueKey(movie.slug),
              movie: movie,
              isActive: isActive,
              onTap: () => widget.onTap(movie),
            ),
          );
        },
      ),
    );
  }
}

class _BounceInCard extends StatelessWidget {
  final Movie movie;
  final bool isActive;
  final VoidCallback onTap;

  const _BounceInCard({
    super.key,
    required this.movie,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TweenAnimationBuilder<double>(
      // 0 = squeezed/off, 1 = settled in line. Animating to a new target
      // whenever `isActive` flips re-triggers from wherever the value
      // currently sits, so this can never get "stuck" mid-animation.
      tween: Tween<double>(begin: 0, end: isActive ? 1 : 0),
      duration: Duration(milliseconds: isActive ? 700 : 350),
      curve: isActive ? Curves.elasticOut : Curves.easeIn,
      builder: (context, t, child) {
        final clamped = t.clamp(0.0, 1.35); // allow slight overshoot for the bounce
        final scaleX = 0.45 + (0.55 * clamped);
        final scaleY = 1.25 - (0.25 * clamped);
        final opacity = t.clamp(0.0, 1.0);
        return Opacity(
          opacity: 0.35 + (0.65 * opacity),
          child: Transform.scale(
            scaleX: scaleX,
            scaleY: scaleY,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Hero(
            tag: 'poster-${movie.slug}',
            child: Card(
              clipBehavior: Clip.antiAlias,
              elevation: isActive ? 10 : 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isActive ? scheme.tertiary : Colors.transparent,
                  width: 2.5,
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _poster(movie),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(12, 24, 12, 10),
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _poster(Movie movie) {
    if (movie.localOverridePath != null) {
      return Image.network(
        movie.localOverridePath!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }
    if (movie.posterPath == null) return _fallback();

    return Image.network(
      '${ApiConfig.imageBase500}${movie.posterPath}',
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _fallback(),
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : Container(color: Colors.black26),
    );
  }

  Widget _fallback() => Container(
        color: Colors.black38,
        alignment: Alignment.center,
        child: const Icon(Icons.movie_creation_outlined, size: 40, color: Colors.white54),
      );
}