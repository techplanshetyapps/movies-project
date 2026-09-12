class ApiConfig {
  ApiConfig._();

  /// TMDB v4 Bearer read-access token.
  static const String bearerToken = String.fromEnvironment(
    'TMDB_BEARER_TOKEN',
    defaultValue: 'TMDB_BEARER_TOKEN',
  );

  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBase500 = 'https://image.tmdb.org/t/p/w500';
  static const String imageBaseOriginal = 'https://image.tmdb.org/t/p/original';

  static Map<String, String> get headers => {
        'Authorization': 'Bearer $bearerToken',
        'accept': 'application/json',
      };

  static bool get isConfigured =>
      bearerToken.isNotEmpty && bearerToken != 'PASTE_YOUR_TMDB_BEARER_TOKEN_HERE';
}

