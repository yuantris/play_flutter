import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/weather_code_util.dart';
import '../../data/models/weather_model.dart';

/// 今日天气卡片组件
/// 显示当前温度、天气状况、湿度和风速等信息
class WeatherCard extends StatelessWidget {
  final CurrentWeather weather;

  const WeatherCard({
    super.key,
    required this.weather,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final weatherDesc = WeatherCodeUtil.getWeatherDescription(weather.weatherCode);
    final weatherIcon = WeatherCodeUtil.getWeatherIcon(weather.weatherCode);
    final weatherColor = WeatherCodeUtil.getWeatherColor(weather.weatherCode);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: _getGradient(weather.weatherCode, isDark),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: weatherColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${weather.temperature.round()}°',
                      style: TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      weatherDesc,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '体感 ${weather.apparentTemperature.round()}°',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  weatherIcon,
                  size: 64,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildWeatherDetails(weather),
        ],
      ),
    );
  }

  /// 构建天气详情行
  Widget _buildWeatherDetails(CurrentWeather weather) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildDetailItem(
            icon: Icons.water_drop_outlined,
            label: '湿度',
            value: '${weather.relativeHumidity}%',
          ),
          _buildDivider(),
          _buildDetailItem(
            icon: Icons.air,
            label: '风速',
            value: '${weather.windSpeed.round()} km/h',
          ),
          _buildDivider(),
          _buildDetailItem(
            icon: Icons.thermostat_outlined,
            label: '体感',
            value: '${weather.apparentTemperature.round()}°',
          ),
        ],
      ),
    );
  }

  /// 构建详情项
  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.white.withOpacity(0.9),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  /// 构建分隔线
  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.white.withOpacity(0.3),
    );
  }

  /// 根据天气代码获取渐变色
  LinearGradient _getGradient(int code, bool isDark) {
    if (isDark) {
      return AppColors.nightGradient;
    }

    if (code == 0 || code == 1) {
      return AppColors.sunnyGradient;
    } else if (code == 2 || code == 3) {
      return AppColors.cloudyGradient;
    } else if (code >= 51 && code <= 67) {
      return AppColors.rainyGradient;
    } else if (code >= 71 && code <= 86) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFB3E5FC), Color(0xFF81D4FA)],
      );
    } else {
      return AppColors.rainyGradient;
    }
  }
}
