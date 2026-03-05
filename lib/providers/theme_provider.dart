import 'package:flutter/material.dart';

enum AppThemeMode {
  system,
  light,
  dark,
}

class ThemeProvider extends ChangeNotifier {
  AppThemeMode _themeMode = AppThemeMode.system;
  Color _primaryColor = const Color(0xFF6C63FF);
  Color _accentColor = const Color(0xFFFF6B6B);
  
  AppThemeMode get themeMode => _themeMode;
  Color get primaryColor => _primaryColor;
  Color get accentColor => _accentColor;
  
  ThemeMode get flutterThemeMode {
    switch (_themeMode) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }
  
  bool get isDarkMode {
    if (_themeMode == AppThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
    return _themeMode == AppThemeMode.dark;
  }
  
  void setThemeMode(AppThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
  
  void toggleThemeMode() {
    if (_themeMode == AppThemeMode.dark) {
      _themeMode = AppThemeMode.light;
    } else {
      _themeMode = AppThemeMode.dark;
    }
    notifyListeners();
  }
  
  void setPrimaryColor(Color color) {
    _primaryColor = color;
    notifyListeners();
  }
  
  void setAccentColor(Color color) {
    _accentColor = color;
    notifyListeners();
  }
  
  List<Color> get availablePrimaryColors => [
    const Color(0xFF6C63FF),
    const Color(0xFFFF6B6B),
    const Color(0xFF4CAF50),
    const Color(0xFF2196F3),
    const Color(0xFFFF9800),
    const Color(0xFF9C27B0),
    const Color(0xFF00BCD4),
    const Color(0xFFE91E63),
  ];
  
  List<Color> get availableAccentColors => [
    const Color(0xFFFF6B6B),
    const Color(0xFF6C63FF),
    const Color(0xFF4CAF50),
    const Color(0xFF2196F3),
    const Color(0xFFFF9800),
    const Color(0xFF9C27B0),
    const Color(0xFF00BCD4),
    const Color(0xFFE91E63),
  ];
}
