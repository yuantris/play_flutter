import 'package:flutter/material.dart';

/// 应用颜色常量定义
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color accent = Color(0xFF03A9F4);

  static const Color sunny = Color(0xFFFFA726);
  static const Color cloudy = Color(0xFF78909C);
  static const Color rainy = Color(0xFF42A5F5);
  static const Color snowy = Color(0xFF90CAF9);
  static const Color thunderstorm = Color(0xFF5C6BC0);

  static const Color aqiGood = Color(0xFF4CAF50);
  static const Color aqiModerate = Color(0xFFFFEB3B);
  static const Color aqiUnhealthy = Color(0xFFFF9800);
  static const Color aqiVeryUnhealthy = Color(0xFFF44336);
  static const Color aqiHazardous = Color(0xFF9C27B0);

  static const LinearGradient sunnyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6)],
  );

  static const LinearGradient cloudyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF90A4AE), Color(0xFF78909C)],
  );

  static const LinearGradient rainyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5C6BC0), Color(0xFF3F51B5)],
  );

  static const LinearGradient nightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3949AB), Color(0xFF1A237E)],
  );
}
