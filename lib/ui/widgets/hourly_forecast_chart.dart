import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/utils/weather_code_util.dart';
import '../../core/utils/date_util.dart';
import '../../data/models/weather_model.dart';

/// 小时预报折线图表组件
/// 以折线图形式展示24小时天气变化，支持水平滑动
/// 温度文字通过垂直辅助线标签显示
class HourlyForecastChart extends StatelessWidget {
  final List<HourlyWeather> hourlyData;

  const HourlyForecastChart({
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final horizontalPadding = 24.0;
        final itemWidth = 60.0;
        final chartWidth = screenWidth > displayData.length * itemWidth 
            ? screenWidth 
            : displayData.length * itemWidth + horizontalPadding;

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
            Container(
              height: 220,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: chartWidth,
                  height: 220,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(horizontalPadding, 8, horizontalPadding, 8),
                    child: _buildChart(context, displayData),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 构建折线图
  Widget _buildChart(BuildContext context, List<HourlyWeather> data) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final temperatures = data.map((h) => h.temperature).toList();
    final minTemp = temperatures.reduce(math.min);
    final maxTemp = temperatures.reduce(math.max);

    final spots = <FlSpot>[];
    for (int i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[i].temperature));
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              interval: 2,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= data.length) {
                  return const SizedBox();
                }
                final hourData = data[index];
                return _buildBottomLabel(context, hourData);
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (data.length - 1).toDouble(),
        minY: minTemp - 2,
        maxY: maxTemp + 2,
        extraLinesData: ExtraLinesData(
          verticalLines: _buildVerticalLines(data),
        ),
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) =>
                isDark ? Colors.grey[800]! : Colors.grey[200]!,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                if (index < 0 || index >= data.length) {
                  return null;
                }
                final hourData = data[index];
                return LineTooltipItem(
                  '${DateUtil.formatTime(hourData.time)}\n${hourData.temperature.toInt()}°C',
                  TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: Colors.orange,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                final hourData = data[index];
                final color = WeatherCodeUtil.getWeatherColor(hourData.weatherCode);
                return FlDotCirclePainter(
                  radius: 5,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: color,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.orange.withValues(alpha: 0.3),
                  Colors.orange.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建垂直温度标签线
  List<VerticalLine> _buildVerticalLines(List<HourlyWeather> data) {
    final lines = <VerticalLine>[];
    
    for (int i = 0; i < data.length; i += 2) {
      final color = WeatherCodeUtil.getWeatherColor(data[i].weatherCode);
      lines.add(
        VerticalLine(
          x: i.toDouble(),
          color: Colors.transparent,
          label: VerticalLineLabel(
            show: true,
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.only(bottom: 2),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            labelResolver: (line) => '${data[i].temperature.round()}°',
          ),
        ),
      );
    }
    return lines;
  }

  /// 构建底部标签（显示天气图标和时间）
  Widget _buildBottomLabel(BuildContext context, HourlyWeather hourData) {
    final isNow = _isNow(hourData.time);
    final isNight = WeatherCodeUtil.isNightTime(hourData.time.hour);
    final icon = WeatherCodeUtil.getWeatherIcon(hourData.weatherCode, isNight: isNight);
    final color = WeatherCodeUtil.getWeatherColor(hourData.weatherCode);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: color,
          ),
          const SizedBox(height: 4),
          Text(
            _getTimeLabel(hourData.time),
            style: TextStyle(
              fontSize: 10,
              fontWeight: isNow ? FontWeight.bold : FontWeight.normal,
              color: isNow
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).textTheme.bodySmall?.color,
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
