import 'package:flutter/material.dart';

class GenreDef {
  final int id;
  final String name;
  final IconData icon;
  const GenreDef(this.id, this.name, this.icon);
}

/// The 17 genres requested, mapped to their real TMDB genre ids so the
/// discover/table screen can filter directly against the API.
const List<GenreDef> kGenres = [
  GenreDef(28, 'Action', Icons.local_fire_department_rounded),
  GenreDef(12, 'Adventure', Icons.terrain_rounded),
  GenreDef(16, 'Animation', Icons.brush_rounded),
  GenreDef(35, 'Comedy', Icons.sentiment_very_satisfied_rounded),
  GenreDef(80, 'Crime', Icons.local_police_rounded),
  GenreDef(99, 'Documentary', Icons.videocam_rounded),
  GenreDef(18, 'Drama', Icons.theater_comedy_rounded),
  GenreDef(10751, 'Family', Icons.family_restroom_rounded),
  GenreDef(14, 'Fantasy', Icons.auto_fix_high_rounded),
  GenreDef(36, 'History', Icons.account_balance_rounded),
  GenreDef(27, 'Horror', Icons.dark_mode_rounded),
  GenreDef(10402, 'Music', Icons.music_note_rounded),
  GenreDef(9648, 'Mystery', Icons.search_rounded),
  GenreDef(10749, 'Romance', Icons.favorite_rounded),
  GenreDef(878, 'Science Fiction', Icons.rocket_launch_rounded),
  GenreDef(10770, 'TV Movie', Icons.tv_rounded),
  GenreDef(37, 'Western', Icons.landscape_rounded),
];

String genreNameForId(int id) =>
    kGenres.firstWhere((g) => g.id == id, orElse: () => const GenreDef(0, 'Unknown', Icons.movie_rounded)).name;
