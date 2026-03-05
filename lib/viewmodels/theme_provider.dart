import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 主题状态管理
/// 管理应用的深色/浅色模式切换
class ThemeProvider extends ChangeNotifier {
  static const String _keyThemeMode = 'theme_mode';

  final SharedPreferences _prefs;
  ThemeMode _themeMode;

  ThemeProvider({required SharedPreferences prefs})
      : _prefs = prefs,
        _themeMode = ThemeMode.system {
    _loadThemeMode();
  }

  /// 获取当前主题模式
  ThemeMode get themeMode => _themeMode;

  /// 是否是深色模式
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// 切换主题模式
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _saveThemeMode();
    notifyListeners();
  }

  /// 设置主题模式
  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    _saveThemeMode();
    notifyListeners();
  }

  /// 设置跟随系统
  void setSystemMode() {
    _themeMode = ThemeMode.system;
    _saveThemeMode();
    notifyListeners();
  }

  /// 从本地存储加载主题设置
  void _loadThemeMode() {
    final savedMode = _prefs.getString(_keyThemeMode);
    if (savedMode != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.name == savedMode,
        orElse: () => ThemeMode.system,
      );
    }
  }

  /// 保存主题设置到本地存储
  Future<void> _saveThemeMode() async {
    await _prefs.setString(_keyThemeMode, _themeMode.name);
  }
}
