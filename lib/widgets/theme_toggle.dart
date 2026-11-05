import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';

/// A compact sun/moon icon button for app bars that flips light⇄dark in one
/// tap. Reads and writes the shared [ThemeProvider].
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeProvider theme = context.watch<ThemeProvider>();
    final bool dark = theme.isDark(context);
    return IconButton(
      tooltip: dark ? 'Switch to light mode' : 'Switch to dark mode',
      onPressed: () => context.read<ThemeProvider>().toggle(context),
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (Widget child, Animation<double> anim) =>
            RotationTransition(
          turns: Tween<double>(begin: 0.6, end: 1).animate(anim),
          child: FadeTransition(opacity: anim, child: child),
        ),
        child: Icon(
          dark ? Icons.dark_mode : Icons.light_mode_outlined,
          key: ValueKey<bool>(dark),
        ),
      ),
    );
  }
}

/// A three-way appearance picker (System / Light / Dark), designed to sit in a
/// settings/profile card.
class ThemeModeSelector extends StatelessWidget {
  const ThemeModeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeProvider theme = context.watch<ThemeProvider>();
    return SegmentedButton<ThemeMode>(
      showSelectedIcon: false,
      segments: const <ButtonSegment<ThemeMode>>[
        ButtonSegment<ThemeMode>(
          value: ThemeMode.system,
          label: Text('System'),
          icon: Icon(Icons.brightness_auto_outlined),
        ),
        ButtonSegment<ThemeMode>(
          value: ThemeMode.light,
          label: Text('Light'),
          icon: Icon(Icons.light_mode_outlined),
        ),
        ButtonSegment<ThemeMode>(
          value: ThemeMode.dark,
          label: Text('Dark'),
          icon: Icon(Icons.dark_mode_outlined),
        ),
      ],
      selected: <ThemeMode>{theme.mode},
      onSelectionChanged: (Set<ThemeMode> s) =>
          context.read<ThemeProvider>().setMode(s.first),
    );
  }
}

/// A full "Appearance" card wrapping [ThemeModeSelector] with a heading — a
/// drop-in block for profile screens.
class AppearanceCard extends StatelessWidget {
  const AppearanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.palette_outlined, size: 20, color: scheme.primary),
                const SizedBox(width: 10),
                Text('Appearance',
                    style: text.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 14),
            const SizedBox(
              width: double.infinity,
              child: ThemeModeSelector(),
            ),
          ],
        ),
      ),
    );
  }
}
