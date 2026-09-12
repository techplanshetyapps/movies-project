import '../models/movie.dart';
import '../services/tmdb_api_service.dart';

/// Central in-memory store that keeps every movie the app has ever loaded,
/// indexed by its slug, so any screen can resolve `/movie/<slug>` without
/// re-fetching, and the watchlist can reference movies by slug too.
class MovieRepository {
  MovieRepository._internal();
  static final MovieRepository instance = MovieRepository._internal();

  final TmdbApiService api = TmdbApiService();
  final Map<String, Movie> _bySlug = {};
  final Set<String> watchlistSlugs = {};

  List<Movie> _animationCarousel = [];
  List<Movie> get animationCarousel => List.unmodifiable(_animationCarousel);

  void _register(Iterable<Movie> movies) {
    for (final m in movies) {
      _bySlug[m.slug] = m;
    }
  }

  Movie? bySlug(String slug) => _bySlug[slug];

  /// The 20 most popular Animation-genre movies, used by the home screen
  /// grid + carousel.
  Future<List<Movie>> loadAnimationTop20() async {
    final movies = await api.discoverByGenre(16, pages: 1); // 20 per page
    final top20 = movies.take(20).toList();
    _animationCarousel = top20;
    _register(top20);
    return top20;
  }

  /// Pulls a broad, multi-genre pool of 100+ movies for the discover table.
  Future<List<Movie>> loadDiscoverPool({int pages = 6, int? genreId}) async {
    final movies = await api.discoverMixed(pages: pages, genreId: genreId);
    _register(movies);
    return movies;
  }

  Future<List<Movie>> trending() async {
    final movies = await api.trending();
    _register(movies);
    return movies;
  }

  Future<List<Movie>> topRated({int pages = 2}) async {
    final movies = await api.topRated(pages: pages);
    _register(movies);
    return movies;
  }

  Future<List<Movie>> upcoming({int pages = 2}) async {
    final movies = await api.upcoming(pages: pages);
    _register(movies);
    return movies;
  }

  Future<List<Movie>> search(String query) async {
    final movies = await api.search(query);
    _register(movies);
    return movies;
  }

  /// Lazily fetches runtime + keywords for a single movie (list endpoints
  /// don't include them) and updates the registry in place.
  Future<Movie> enrich(Movie movie) async {
    if (movie.runtimeMinutes > 0 && movie.keywords.isNotEmpty) return movie;
    final results = await Future.wait([
      movie.runtimeMinutes > 0 ? Future.value(movie.runtimeMinutes) : api.fetchRuntime(movie.id),
      movie.keywords.isNotEmpty ? Future.value(movie.keywords) : api.fetchKeywords(movie.id),
    ]);
    final enriched = movie.copyWith(
      runtimeMinutes: results[0] as int,
      keywords: results[1] as List<String>,
    );
    _bySlug[enriched.slug] = enriched;
    return enriched;
  }

  void toggleWatchlist(String slug) {
    if (watchlistSlugs.contains(slug)) {
      watchlistSlugs.remove(slug);
    } else {
      watchlistSlugs.add(slug);
    }
  }

  List<Movie> get watchlistMovies =>
      watchlistSlugs.map((s) => _bySlug[s]).whereType<Movie>().toList();

  void setLocalOverride(String slug, String path) {
    _bySlug[slug]?.localOverridePath = path;
  }
}
