import 'package:flutter/material.dart';
import '../../core/utils/weather_code_util.dart';
import '../../core/utils/date_util.dart';
import '../../data/models/weather_model.dart';

/// 小时预报横向列表组件
class HourlyForecastList extends StatelessWidget {
  final List<HourlyWeather> hourlyData;

  const HourlyForecastList({
    super.key,
    required this.hourlyData,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final displayData = hourlyData.where((h) {
      return h.time.isAfter(now.subtract(const Duration(hours: 1)));
    }).take(24).toList();

    if (displayData.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '今日小时预报',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: displayData.length,
            itemBuilder: (context, index) {
              final hour = displayData[index];
              return _HourlyItem(hour: hour);
            },
          ),
        ),
      ],
    );
  }
}

/// 小时预报单项
class _HourlyItem extends StatelessWidget {
  final HourlyWeather hour;

  const _HourlyItem({required this.hour});

  @override
  Widget build(BuildContext context) {
    final isNow = _isNow(hour.time);
    final isNight = WeatherCodeUtil.isNightTime(hour.time.hour);
    final icon = WeatherCodeUtil.getWeatherIcon(hour.weatherCode, isNight: isNight);
    final color = WeatherCodeUtil.getWeatherColor(hour.weatherCode);

    return Container(
      width: 70,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isNow
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: isNow
            ? Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _getTimeLabel(hour.time),
            style: TextStyle(
              fontSize: 12,
              fontWeight: isNow ? FontWeight.bold : FontWeight.normal,
              color: isNow
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          Icon(
            icon,
            size: 28,
            color: color,
          ),
          Text(
            '${hour.temperature.round()}°',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  /// 判断是否是当前小时
  bool _isNow(DateTime time) {
    final now = DateTime.now();
    return time.year == now.year &&
        time.month == now.month &&
        time.day == now.day &&
        time.hour == now.hour;
  }

  /// 获取时间标签
  String _getTimeLabel(DateTime time) {
    final now = DateTime.now();
    if (time.year == now.year &&
        time.month == now.month &&
        time.day == now.day &&
        time.hour == now.hour) {
      return '现在';
    }
    return DateUtil.formatTime(time);
  }
}
