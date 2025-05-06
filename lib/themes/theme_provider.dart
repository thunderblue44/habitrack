import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  final SharedPreferences _prefs;
  final String _themePreferenceKey = 'theme_preference';

  ThemeProvider(this._prefs) {
    _loadThemePreference();
  }

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _saveThemePreference();
    notifyListeners();
  }

  void setThemeMode(ThemeMode themeMode) {
    _themeMode = themeMode;
    _saveThemePreference();
    notifyListeners();
  }

  // Get the current theme data
  ThemeData get themeData {
    if (_themeMode == ThemeMode.dark) {
      return AppTheme.darkTheme;
    }
    return AppTheme.lightTheme;
  }

  void _loadThemePreference() {
    final themeString = _prefs.getString(_themePreferenceKey);
    if (themeString != null) {
      _themeMode = _themeModeFromString(themeString);
      notifyListeners();
    }
  }

  Future<void> _saveThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themePreferenceKey, _themeModeToString(_themeMode));
  }

  String _themeModeToString(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.system:
        return 'system';
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
    }
  }

  ThemeMode _themeModeFromString(String themeString) {
    switch (themeString) {
      case 'system':
        return ThemeMode.system;
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
