import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Owns the app's light/dark/system preference and persists it across launches
/// with [SharedPreferences], so the choice survives app restarts.
class ThemeProvider extends ChangeNotifier {
  ThemeProvider() {
    _load();
  }

  static const String _prefsKey = 'theme_mode';

  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  /// Convenience for toggle UIs: resolves `system` against the device setting
  /// so a simple light⇄dark switch does the intuitive thing.
  bool isDark(BuildContext context) => switch (_mode) {
        ThemeMode.dark => true,
        ThemeMode.light => false,
        ThemeMode.system =>
          MediaQuery.platformBrightnessOf(context) == Brightness.dark,
      };

  Future<void> _load() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? saved = prefs.getString(_prefsKey);
      if (saved != null) {
        _mode = ThemeMode.values.firstWhere(
          (ThemeMode m) => m.name == saved,
          orElse: () => ThemeMode.system,
        );
        notifyListeners();
      }
    } catch (_) {
      // Preferences unavailable (e.g. first run / platform quirk): keep system.
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    if (mode == _mode) return;
    _mode = mode;
    notifyListeners();
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, mode.name);
    } catch (_) {
      // Best-effort persistence; the in-memory choice still applies.
    }
  }

  /// Flip between light and dark, treating the current effective brightness as
  /// the starting point (so one tap always visibly changes the theme).
  Future<void> toggle(BuildContext context) =>
      setMode(isDark(context) ? ThemeMode.light : ThemeMode.dark);
}
