
# Movies Explorer

<div align="center">
<p>
<img src="https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white" />
<img src="https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white" />
<img src="https://img.shields.io/badge/Material_Design-757575?style=for-the-badge&logo=material-design&logoColor=white" />
<img src="https://img.shields.io/badge/TMDB-01b4e4?style=for-the-badge&logo=themoviedatabase&logoColor=white" />
</p>
</div>

---

A Material 3 Flutter app built against [The Movie Database (TMDB) API](https://developer.themoviedb.org/docs/authentication-application).

---

## Setup

1. Install dependencies:
   ```bash
   flutter pub get
   ```
2. Provide your **new** TMDB v4 Bearer token at run time (preferred — keeps it
   out of source):
   ```bash
   flutter run --dart-define=TMDB_BEARER_TOKEN=your_new_token_here
   ```
   Or, for quick local testing only, paste it directly into
   `lib/config/api_config.dart` (do not commit this).

---

## What's included

- **Home** — the 20 most popular Animation movies as an animated carousel
  (stretch-then-bounce entrance) plus a 2-column grid; each grid tile has an
  upload icon to swap in a custom local scene image.
- **Movie scene page** — full detail view resolved by slug
  (`/movie/<slug>`), with lazily-fetched runtime and keywords.
- **All Movies** — a 120+ movie discover table across all 17 requested
  genres, filterable by genre, language, minimum score, minimum votes,
  runtime range, and keyword/title — with a vertical page-number rail
  instead of classic bottom pagination. Reachable from every screen via the
  drawer and the persistent table icon in the app bar.
- **Genres, Search, Trending, Top Rated, Upcoming, Watchlist, About, Contact**
  — ten additional pages, all sharing the same persistent navigation shell.
- **Contact** page with LinkedIn, Vimeo, and GitHub links, shown with plain
  Material icons and a text label under each (swap the placeholder URLs for
  your own).
- Material 3 theme tuned for strong, accessible contrast.

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  http: ^1.2.2
  url_launcher: ^6.3.1
  image_picker: ^1.1.2
```

`font_awesome_flutter` was intentionally left out: some Flutter/Dart SDK
builds treat `IconData` as a `final` class, which breaks that package's
internal subclassing and fails the web build. Brand icons for the Contact
page use plain `Icons.*` glyphs with text labels instead.

---

## Known limitation: image upload on web

The "upload a custom scene image" button on the Home grid uses
`image_picker`. On web, the picked file returns as a blob URL, and
`Image.asset()` (used for the override) expects a bundled asset path, not a
URL — so on web builds the override image won't render correctly as-is. If
you need this working on web, switch that widget to read the picked file as
bytes and render with `Image.memory()` instead.

---

## Structure

```
lib/
  config/api_config.dart        TMDB auth + base URLs
  data/genres.dart              17 genres mapped to TMDB ids
  data/movie_repository.dart    slug <-> movie registry, watchlist, enrichment
  models/movie.dart             Movie model + slugify()
  services/tmdb_api_service.dart  raw TMDB HTTP calls (Bearer auth)
  theme/app_theme.dart          Material 3 dark, high-contrast theme
  widgets/animated_movie_carousel.dart  stretch + bounce carousel
  widgets/app_scaffold.dart     drawer + persistent "All Movies" access
  widgets/social_icon_button.dart
  widgets/simple_movie_grid.dart
  screens/*.dart                one file per page
  main.dart
```
