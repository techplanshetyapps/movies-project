import 'package:flutter/material.dart';
import '../theme/theme_controller.dart';

class DayNightToggle extends StatelessWidget {
  const DayNightToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.mode,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;
        return IconButton(
          onPressed: ThemeController.toggle,
          tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return RotationTransition(
                turns: Tween<double>(begin: 0.5, end: 1.0).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: Icon(
              isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round_sharp,
              key: ValueKey<bool>(isDark),
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        );
      },
    );
  }
}