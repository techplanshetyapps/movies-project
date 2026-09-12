import '../data/genres.dart';

/// Turns a movie title + id into a stable, URL-friendly slug, e.g.
/// "Spider-Man: Into the Spider-Verse" (id 324857) -> "spider-man-into-the-spider-verse-324857"
String slugify(String title, int id) {
  final base = title
      .toLowerCase()
      .replaceAll(RegExp(r"[^a-z0-9\s-]"), '')
      .trim()
      .replaceAll(RegExp(r"\s+"), '-');
  return '$base-$id';
}

class Movie {
  final int id;
  final String slug;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final List<int> genreIds;
  final String originalLanguage;
  final double voteAverage;
  final int voteCount;
  final int runtimeMinutes; // 0 if not fetched yet (list endpoints omit runtime)
  final String releaseDate;
  final List<String> keywords;

  /// Optional locally-uploaded image overriding the poster (per the
  /// "upload this particular scene" requirement). Kept purely client-side.
  String? localOverridePath;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.genreIds,
    required this.originalLanguage,
    required this.voteAverage,
    required this.voteCount,
    this.runtimeMinutes = 0,
    required this.releaseDate,
    this.keywords = const [],
    this.localOverridePath,
  }) : slug = slugify(title, id);

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] as int,
      title: (json['title'] ?? json['name'] ?? 'Untitled') as String,
      overview: (json['overview'] ?? '') as String,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      genreIds: ((json['genre_ids'] as List?) ?? const []).cast<int>(),
      originalLanguage: (json['original_language'] ?? 'en') as String,
      voteAverage: ((json['vote_average'] ?? 0) as num).toDouble(),
      voteCount: (json['vote_count'] ?? 0) as int,
      runtimeMinutes: (json['runtime'] ?? 0) as int,
      releaseDate: (json['release_date'] ?? '') as String,
    );
  }

  Movie copyWith({int? runtimeMinutes, List<String>? keywords, String? localOverridePath}) {
    final m = Movie(
      id: id,
      title: title,
      overview: overview,
      posterPath: posterPath,
      backdropPath: backdropPath,
      genreIds: genreIds,
      originalLanguage: originalLanguage,
      voteAverage: voteAverage,
      voteCount: voteCount,
      runtimeMinutes: runtimeMinutes ?? this.runtimeMinutes,
      releaseDate: releaseDate,
      keywords: keywords ?? this.keywords,
      localOverridePath: localOverridePath ?? this.localOverridePath,
    );
    return m;
  }

  String get primaryGenreName => genreIds.isEmpty ? '—' : genreNameForId(genreIds.first);

  String get genreNames => genreIds.map(genreNameForId).join(', ');
}
