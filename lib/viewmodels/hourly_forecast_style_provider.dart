import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 小时预报显示样式提供者
/// 管理小时预报的显示样式（列表样式/折线样式）
class HourlyForecastStyleProvider extends ChangeNotifier {
  static const String _keyHourlyStyle = 'hourly_forecast_style';

  final SharedPreferences _prefs;
  HourlyForecastStyle _style;

  HourlyForecastStyleProvider({required SharedPreferences prefs})
      : _prefs = prefs,
        _style = HourlyForecastStyle.list {
    _loadStyle();
  }

  /// 获取当前显示样式
  HourlyForecastStyle get style => _style;

  /// 是否是折线样式
  bool get isChartStyle => _style == HourlyForecastStyle.chart;

  /// 设置显示样式
  void setStyle(HourlyForecastStyle style) {
    if (_style == style) return;
    _style = style;
    _saveStyle();
    notifyListeners();
  }

  /// 切换显示样式
  void toggleStyle() {
    _style = _style == HourlyForecastStyle.list
        ? HourlyForecastStyle.chart
        : HourlyForecastStyle.list;
    _saveStyle();
    notifyListeners();
  }

  /// 从本地存储加载样式设置
  void _loadStyle() {
    final savedStyle = _prefs.getString(_keyHourlyStyle);
    if (savedStyle != null) {
      _style = HourlyForecastStyle.values.firstWhere(
        (s) => s.name == savedStyle,
        orElse: () => HourlyForecastStyle.list,
      );
    }
  }

  /// 保存样式设置到本地存储
  Future<void> _saveStyle() async {
    await _prefs.setString(_keyHourlyStyle, _style.name);
  }
}

/// 小时预报显示样式
enum HourlyForecastStyle {
  /// 列表样式（横向滚动列表）
  list,
  /// 折线图表样式
  chart,
}
