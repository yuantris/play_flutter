import 'package:flutter/material.dart';

/// 天气代码工具类
/// 根据 Open-Meteo API 的 weather_code 字段映射天气图标和描述
class WeatherCodeUtil {
  WeatherCodeUtil._();

  /// 获取天气描述文字
  static String getWeatherDescription(int code) {
    switch (code) {
      case 0:
        return '晴';
      case 1:
        return '大部晴朗';
      case 2:
        return '多云';
      case 3:
        return '阴';
      case 45:
        return '雾';
      case 48:
        return '雾凇';
      case 51:
        return '小毛毛雨';
      case 53:
        return '中毛毛雨';
      case 55:
        return '大毛毛雨';
      case 56:
        return '冻毛毛雨';
      case 57:
        return '强冻毛毛雨';
      case 61:
        return '小雨';
      case 63:
        return '中雨';
      case 65:
        return '大雨';
      case 66:
        return '冻雨';
      case 67:
        return '强冻雨';
      case 71:
        return '小雪';
      case 73:
        return '中雪';
      case 75:
        return '大雪';
      case 77:
        return '雪粒';
      case 80:
        return '小阵雨';
      case 81:
        return '中阵雨';
      case 82:
        return '大阵雨';
      case 85:
        return '小阵雪';
      case 86:
        return '大阵雪';
      case 95:
        return '雷暴';
      case 96:
        return '雷暴伴小冰雹';
      case 99:
        return '雷暴伴大冰雹';
      default:
        return '未知';
    }
  }

  /// 获取天气图标 (使用 Material Icons)
  static IconData getWeatherIcon(int code, {bool isNight = false}) {
    switch (code) {
      case 0:
        return isNight ? Icons.nightlight_round : Icons.wb_sunny;
      case 1:
        return isNight ? Icons.nightlight_round : Icons.wb_sunny;
      case 2:
        return Icons.cloud;
      case 3:
        return Icons.cloud;
      case 45:
      case 48:
        return Icons.foggy;
      case 51:
      case 53:
      case 55:
        return Icons.grain;
      case 56:
      case 57:
        return Icons.ac_unit;
      case 61:
      case 63:
      case 65:
        return Icons.water_drop;
      case 66:
      case 67:
        return Icons.ac_unit;
      case 71:
      case 73:
      case 75:
      case 77:
        return Icons.ac_unit;
      case 80:
      case 81:
      case 82:
        return Icons.thunderstorm;
      case 85:
      case 86:
        return Icons.ac_unit;
      case 95:
      case 96:
      case 99:
        return Icons.thunderstorm;
      default:
        return Icons.help_outline;
    }
  }

  /// 获取天气图标颜色
  static Color getWeatherColor(int code) {
    if (code == 0 || code == 1) {
      return const Color(0xFFFFA726);
    } else if (code == 2 || code == 3) {
      return const Color(0xFF78909C);
    } else if (code >= 51 && code <= 67) {
      return const Color(0xFF42A5F5);
    } else if (code >= 71 && code <= 86) {
      return const Color(0xFF90CAF9);
    } else if (code >= 95) {
      return const Color(0xFF5C6BC0);
    }
    return const Color(0xFF78909C);
  }

  /// 判断是否是夜晚
  static bool isNightTime(int hour) {
    return hour < 6 || hour >= 18;
  }
}
