import 'package:flutter/material.dart';
import '../../core/utils/weather_code_util.dart';
import '../../core/utils/date_util.dart';
import '../../data/models/weather_model.dart';

/// 7天天气预报列表组件
class DailyForecastList extends StatelessWidget {
  final List<DailyWeather> dailyData;

  const DailyForecastList({
    super.key,
    required this.dailyData,
  });

  @override
  Widget build(BuildContext context) {
    if (dailyData.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '未来7天预报',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 0), // 关键：清除顶部默认padding
            itemCount: dailyData.length > 7 ? 7 : dailyData.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
              color: Theme.of(context).dividerColor.withOpacity(0.1),
            ),
            itemBuilder: (context, index) {
              final day = dailyData[index];
              return _DailyItem(day: day, isFirst: index == 0);
            },
          ),
        ),
      ],
    );
  }
}

/// 每日预报单项
class _DailyItem extends StatelessWidget {
  final DailyWeather day;
  final bool isFirst;

  const _DailyItem({
    required this.day,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    final icon = WeatherCodeUtil.getWeatherIcon(day.weatherCode);
    final color = WeatherCodeUtil.getWeatherColor(day.weatherCode);
    final desc = WeatherCodeUtil.getWeatherDescription(day.weatherCode);
    final dateLabel = DateUtil.getRelativeDateString(day.date);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              isFirst ? '今天' : dateLabel,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isFirst ? FontWeight.bold : FontWeight.normal,
                color: isFirst
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            icon,
            size: 24,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              desc,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
          Row(
            children: [
              Text(
                '${day.tempMax.round()}°',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${day.tempMin.round()}°',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
