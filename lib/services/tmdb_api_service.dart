import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/movie.dart';

/// Thin wrapper around the TMDB v3 REST API, authenticated with the
/// "Authorization: Bearer <token>" scheme from
/// https://developer.themoviedb.org/docs/authentication-application
class TmdbApiService {
  Uri _u(String path, [Map<String, dynamic>? query]) {
    final q = <String, String>{
      'language': 'en-US',
      ...?query?.map((k, v) => MapEntry(k, '$v')),
    };
    return Uri.parse('${ApiConfig.baseUrl}$path').replace(queryParameters: q);
  }

  Future<Map<String, dynamic>> _get(Uri uri) async {
    final res = await http.get(uri, headers: ApiConfig.headers);
    if (res.statusCode != 200) {
      throw Exception('TMDB request failed (${res.statusCode}): ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// Most popular movies for a given genre id, `pages` pages of 20 each.
  Future<List<Movie>> discoverByGenre(int genreId, {int pages = 1}) async {
    final results = <Movie>[];
    for (var page = 1; page <= pages; page++) {
      final json = await _get(_u('/discover/movie', {
        'with_genres': genreId,
        'sort_by': 'popularity.desc',
        'page': page,
      }));
      final list = (json['results'] as List? ?? const []);
      results.addAll(list.map((e) => Movie.fromJson(e as Map<String, dynamic>)));
    }
    return results;
  }

  /// Broad discover call spanning many genres, used to build the 100+ row table.
  Future<List<Movie>> discoverMixed({int pages = 1, int? genreId}) async {
    final results = <Movie>[];
    for (var page = 1; page <= pages; page++) {
      final json = await _get(_u('/discover/movie', {
        'sort_by': 'popularity.desc',
        'page': page,
        if (genreId != null) 'with_genres': genreId,
      }));
      final list = (json['results'] as List? ?? const []);
      results.addAll(list.map((e) => Movie.fromJson(e as Map<String, dynamic>)));
    }
    return results;
  }

  Future<List<Movie>> trending({String window = 'week'}) async {
    final json = await _get(_u('/trending/movie/$window'));
    final list = (json['results'] as List? ?? const []);
    return list.map((e) => Movie.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Movie>> topRated({int pages = 1}) async {
    final results = <Movie>[];
    for (var page = 1; page <= pages; page++) {
      final json = await _get(_u('/movie/top_rated', {'page': page}));
      final list = (json['results'] as List? ?? const []);
      results.addAll(list.map((e) => Movie.fromJson(e as Map<String, dynamic>)));
    }
    return results;
  }

  Future<List<Movie>> upcoming({int pages = 1}) async {
    final results = <Movie>[];
    for (var page = 1; page <= pages; page++) {
      final json = await _get(_u('/movie/upcoming', {'page': page}));
      final list = (json['results'] as List? ?? const []);
      results.addAll(list.map((e) => Movie.fromJson(e as Map<String, dynamic>)));
    }
    return results;
  }

  Future<List<Movie>> search(String query) async {
    if (query.trim().isEmpty) return [];
    final json = await _get(_u('/search/movie', {'query': query}));
    final list = (json['results'] as List? ?? const []);
    return list.map((e) => Movie.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<int> fetchRuntime(int movieId) async {
    final json = await _get(_u('/movie/$movieId'));
    return (json['runtime'] ?? 0) as int;
  }

  Future<List<String>> fetchKeywords(int movieId) async {
    final json = await _get(_u('/movie/$movieId/keywords'));
    final list = (json['keywords'] as List? ?? const []);
    return list.map((e) => (e as Map<String, dynamic>)['name'] as String).toList();
  }
}
