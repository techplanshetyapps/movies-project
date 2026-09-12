import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../data/genres.dart';
import '../data/movie_repository.dart';
import '../models/movie.dart';
import '../widgets/app_scaffold.dart';
import 'movie_scene_screen.dart';

const int _kPageSize = 20;

class MoviesTableScreen extends StatefulWidget {
  const MoviesTableScreen({super.key});

  @override
  State<MoviesTableScreen> createState() => _MoviesTableScreenState();
}

class _MoviesTableScreenState extends State<MoviesTableScreen> {
  final _repo = MovieRepository.instance;

  List<Movie> _all = [];
  bool _loading = true;
  String? _error;

  int? _genreFilter;
  String _languageFilter = '';
  double _minScore = 0;
  int _minVotes = 0;
  RangeValues _runtimeRange = const RangeValues(0, 240);
  String _keywordQuery = '';

  int _page = 0;

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
    setState(() => _loading = true);
    try {
      // 6 pages * 20 = 120 movies, comfortably over the "100+" requirement.
      final movies = await _repo.loadDiscoverPool(pages: 6, genreId: _genreFilter);
      setState(() {
        _all = movies;
        _loading = false;
        _page = 0;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Could not load movies: $e';
      });
    }
  }

  List<Movie> get _filtered {
    return _all.where((m) {
      if (_languageFilter.isNotEmpty &&
          !m.originalLanguage.toLowerCase().contains(_languageFilter.toLowerCase())) {
        return false;
      }
      if (m.voteAverage < _minScore) return false;
      if (m.voteCount < _minVotes) return false;
      if (_keywordQuery.isNotEmpty &&
          !m.title.toLowerCase().contains(_keywordQuery.toLowerCase()) &&
          !m.keywords.any((k) => k.toLowerCase().contains(_keywordQuery.toLowerCase()))) {
        return false;
      }
      return true;
    }).toList();
  }

  int get _pageCount {
    final total = _filtered.length;
    return total == 0 ? 1 : ((total - 1) ~/ _kPageSize) + 1;
  }

  List<Movie> get _pageItems {
    final list = _filtered;
    final start = _page * _kPageSize;
    if (start >= list.length) return [];
    final end = (start + _kPageSize).clamp(0, list.length);
    return list.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'All Movies (${_filtered.length})',
      currentRouteLabel: 'All Movies',
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_error!)))
              : Column(
                  children: [
                    _FilterBar(
                      genreFilter: _genreFilter,
                      languageFilter: _languageFilter,
                      minScore: _minScore,
                      minVotes: _minVotes,
                      runtimeRange: _runtimeRange,
                      keywordQuery: _keywordQuery,
                      onGenreChanged: (g) {
                        setState(() => _genreFilter = g);
                        _load();
                      },
                      onLanguageChanged: (v) => setState(() { _languageFilter = v; _page = 0; }),
                      onMinScoreChanged: (v) => setState(() { _minScore = v; _page = 0; }),
                      onMinVotesChanged: (v) => setState(() { _minVotes = v; _page = 0; }),
                      onRuntimeChanged: (v) => setState(() { _runtimeRange = v; _page = 0; }),
                      onKeywordChanged: (v) => setState(() { _keywordQuery = v; _page = 0; }),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: _MovieDataTable(movies: _pageItems)),
                          _VerticalPaginator(
                            pageCount: _pageCount,
                            currentPage: _page,
                            onSelect: (p) => setState(() => _page = p),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final int? genreFilter;
  final String languageFilter;
  final double minScore;
  final int minVotes;
  final RangeValues runtimeRange;
  final String keywordQuery;
  final ValueChanged<int?> onGenreChanged;
  final ValueChanged<String> onLanguageChanged;
  final ValueChanged<double> onMinScoreChanged;
  final ValueChanged<int> onMinVotesChanged;
  final ValueChanged<RangeValues> onRuntimeChanged;
  final ValueChanged<String> onKeywordChanged;

  const _FilterBar({
    required this.genreFilter,
    required this.languageFilter,
    required this.minScore,
    required this.minVotes,
    required this.runtimeRange,
    required this.keywordQuery,
    required this.onGenreChanged,
    required this.onLanguageChanged,
    required this.onMinScoreChanged,
    required this.onMinVotesChanged,
    required this.onRuntimeChanged,
    required this.onKeywordChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ChoiceChip(
                  label: const Text('All genres'),
                  selected: genreFilter == null,
                  onSelected: (_) => onGenreChanged(null),
                ),
                const SizedBox(width: 6),
                for (final g in kGenres) ...[
                  ChoiceChip(
                    label: Text(g.name),
                    selected: genreFilter == g.id,
                    onSelected: (_) => onGenreChanged(g.id),
                  ),
                  const SizedBox(width: 6),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 140,
                child: TextField(
                  decoration: const InputDecoration(labelText: 'Language (e.g. en)', isDense: true),
                  onChanged: onLanguageChanged,
                ),
              ),
              SizedBox(
                width: 220,
                child: TextField(
                  decoration: const InputDecoration(labelText: 'Keyword or title', isDense: true),
                  onChanged: onKeywordChanged,
                ),
              ),
              SizedBox(
                width: 220,
                child: Row(
                  children: [
                    const Text('Min score', style: TextStyle(fontSize: 12)),
                    Expanded(
                      child: Slider(
                        value: minScore,
                        min: 0,
                        max: 10,
                        divisions: 20,
                        label: minScore.toStringAsFixed(1),
                        onChanged: onMinScoreChanged,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 160,
                child: TextField(
                  decoration: const InputDecoration(labelText: 'Min votes', isDense: true),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => onMinVotesChanged(int.tryParse(v) ?? 0),
                ),
              ),
              SizedBox(
                width: 260,
                child: Row(
                  children: [
                    const Text('Runtime', style: TextStyle(fontSize: 12)),
                    Expanded(
                      child: RangeSlider(
                        values: runtimeRange,
                        min: 0,
                        max: 240,
                        divisions: 24,
                        labels: RangeLabels(
                          '${runtimeRange.start.round()}m',
                          '${runtimeRange.end.round()}m',
                        ),
                        onChanged: onRuntimeChanged,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MovieDataTable extends StatelessWidget {
  final List<Movie> movies;
  const _MovieDataTable({required this.movies});

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return const Center(child: Text('No movies match these filters.'));
    }
    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Title')),
            DataColumn(label: Text('Genre')),
            DataColumn(label: Text('Language')),
            DataColumn(label: Text('Score'), numeric: true),
            DataColumn(label: Text('Votes'), numeric: true),
            DataColumn(label: Text('Runtime')),
          ],
          rows: [
            for (final m in movies)
              DataRow(
                onSelectChanged: (_) => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => MovieSceneScreen(slug: m.slug)),
                ),
                cells: [
                  DataCell(SizedBox(width: 220, child: Text(m.title, overflow: TextOverflow.ellipsis))),
                  DataCell(Text(m.primaryGenreName)),
                  DataCell(Text(m.originalLanguage.toUpperCase())),
                  DataCell(Text(m.voteAverage.toStringAsFixed(1))),
                  DataCell(Text('${m.voteCount}')),
                  DataCell(Text(m.runtimeMinutes > 0 ? '${m.runtimeMinutes}m' : '—')),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Modern vertical pagination rail: a slim column of page dots/numbers the
/// user scrolls or taps through, rather than a classic bottom page-bar.
class _VerticalPaginator extends StatelessWidget {
  final int pageCount;
  final int currentPage;
  final ValueChanged<int> onSelect;

  const _VerticalPaginator({required this.pageCount, required this.currentPage, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 56,
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Column(
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_up_rounded),
            onPressed: currentPage > 0 ? () => onSelect(currentPage - 1) : null,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: pageCount,
              itemBuilder: (context, index) {
                final selected = index == currentPage;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => onSelect(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected ? scheme.primary : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(color: selected ? scheme.primary : scheme.outlineVariant),
                      ),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: selected ? scheme.onPrimary : scheme.onSurface,
                          fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            onPressed: currentPage < pageCount - 1 ? () => onSelect(currentPage + 1) : null,
          ),
        ],
      ),
    );
  }
}
