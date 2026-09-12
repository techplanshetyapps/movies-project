import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/genres_screen.dart';
import '../screens/movies_table_screen.dart';
import '../screens/search_screen.dart';
import '../screens/trending_screen.dart';
import '../screens/top_rated_screen.dart';
import '../screens/upcoming_screen.dart';
import '../screens/watchlist_screen.dart';
import '../screens/about_screen.dart';
import '../screens/contact_screen.dart';
import 'day_night_toggle.dart';

class _NavItem {
  final String label;
  final IconData icon;
  final WidgetBuilder builder;
  const _NavItem(this.label, this.icon, this.builder);
}

final List<_NavItem> _navItems = [
  _NavItem('Home', Icons.home_rounded, (_) => const HomeScreen()),
  _NavItem('Genres', Icons.category_rounded, (_) => const GenresScreen()),
  _NavItem('All Movies', Icons.table_rows_rounded, (_) => const MoviesTableScreen()),
  _NavItem('Search', Icons.search_rounded, (_) => const SearchScreen()),
  _NavItem('Trending', Icons.local_fire_department_rounded, (_) => const TrendingScreen()),
  _NavItem('Top Rated', Icons.star_rounded, (_) => const TopRatedScreen()),
  _NavItem('Upcoming', Icons.upcoming_rounded, (_) => const UpcomingScreen()),
  _NavItem('Watchlist', Icons.bookmark_rounded, (_) => const WatchlistScreen()),
  _NavItem('About', Icons.info_rounded, (_) => const AboutScreen()),
  _NavItem('Contact', Icons.alternate_email_rounded, (_) => const ContactScreen()),
];

/// Wraps every screen's content so that:
///  - a drawer links to all ten+ pages from anywhere in the app
///  - a persistent AppBar action always jumps straight to the 100+ movie
///    discover table, satisfying "a separate page accessible from every
///    page of the site".
class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? extraActions;
  final Widget? floatingActionButton;
  final String currentRouteLabel;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    required this.currentRouteLabel,
    this.extraActions,
    this.floatingActionButton,
  });

  void _go(BuildContext context, WidgetBuilder builder, String label) {
    Navigator.of(context).pop(); // close drawer if open
    if (label == currentRouteLabel) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: builder),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          ...?extraActions,
          const DayNightToggle(),
          IconButton(
            tooltip: 'Browse all 100+ movies',
            icon: const Icon(Icons.table_rows_rounded),
            onPressed: currentRouteLabel == 'All Movies'
                ? null
                : () => _go(context, (_) => const MoviesTableScreen(), 'All Movies'),
          ),
        ],
      ),
      drawer: NavigationDrawer(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 16, 12),
            child: Row(
              children: [
                Icon(Icons.movie_creation_rounded, color: scheme.secondary, size: 26),
                const SizedBox(width: 10),
                Text('Movie Explorer',
                    style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
          ),
          const Divider(height: 1),
          for (final item in _navItems)
            NavigationDrawerDestination(
              icon: Icon(item.icon),
              label: Text(item.label),
            ),
        ],
        onDestinationSelected: (index) => _go(context, _navItems[index].builder, _navItems[index].label),
        selectedIndex: _navItems.indexWhere((n) => n.label == currentRouteLabel).clamp(0, _navItems.length - 1),
      ),
      body: SafeArea(child: body),
      floatingActionButton: floatingActionButton,
    );
  }
}