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
          tooltip: isDark ? 'Switch to day mode' : 'Switch to night mode',
          onPressed: ThemeController.toggle,
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, animation) => RotationTransition(
              turns: Tween<double>(begin: 0.75, end: 1.0).animate(animation),
              child: ScaleTransition(scale: animation, child: child),
            ),
            child: Icon(
              isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
              key: ValueKey(isDark),
              color: isDark ? const Color(0xFF9DB4FF) : const Color(0xFFFFB300),
            ),
          ),
        );
      },
    );
  }
}