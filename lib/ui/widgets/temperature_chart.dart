import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/weather_model.dart';

/// 温度折线图组件
/// 显示24小时或7天的温度变化趋势
class TemperatureChart extends StatelessWidget {
  /// 小时天气数据列表
  final List<HourlyWeather> hourlyData;
  
  /// 每日天气数据列表
  final List<DailyWeather> dailyData;
  
  /// 图表类型
  final TemperatureChartType chartType;
  
  /// 图表高度
  final double height;

  const TemperatureChart({
    super.key,
    this.hourlyData = const [],
    this.dailyData = const [],
    this.chartType = TemperatureChartType.hourly,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(context),
          const SizedBox(height: 16),
          Expanded(
            child: chartType == TemperatureChartType.hourly
                ? _buildHourlyChart(context, isDark)
                : _buildDailyChart(context, isDark),
          ),
        ],
      ),
    );
  }

  /// 构建标题
  Widget _buildTitle(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.show_chart,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          chartType == TemperatureChartType.hourly ? '24小时温度趋势' : '7天温度趋势',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// 构建24小时温度折线图
  Widget _buildHourlyChart(BuildContext context, bool isDark) {
    if (hourlyData.isEmpty) {
      return _buildEmptyState();
    }

    // 取接下来24小时的数据
    final now = DateTime.now();
    final next24Hours = hourlyData.where((h) => 
      h.time.isAfter(now.subtract(const Duration(hours: 1))) &&
      h.time.isBefore(now.add(const Duration(hours: 24)))
    ).toList();

    if (next24Hours.isEmpty) {
      return _buildEmptyState();
    }

    final spots = <FlSpot>[];
    final temperatures = next24Hours.map((h) => h.temperature).toList();
    final minTemp = temperatures.reduce(math.min);
    final maxTemp = temperatures.reduce(math.max);
    final tempRange = maxTemp - minTemp;

    for (int i = 0; i < next24Hours.length; i++) {
      spots.add(FlSpot(i.toDouble(), next24Hours[i].temperature));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: tempRange > 10 ? 5 : 2,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              strokeWidth: 1,
            );
          },
        ),
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
              reservedSize: 30,
              interval: 4,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= next24Hours.length) {
                  return const SizedBox();
                }
                final hour = next24Hours[index].time.hour;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${hour}时',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: tempRange > 10 ? 5 : 2,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}°',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (next24Hours.length - 1).toDouble(),
        minY: minTemp - 2,
        maxY: maxTemp + 2,
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => 
              isDark ? Colors.grey[800]! : Colors.grey[200]!,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                if (index < 0 || index >= next24Hours.length) {
                  return null;
                }
                final data = next24Hours[index];
                return LineTooltipItem(
                  '${data.temperature.toInt()}°C',
                  TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
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
              show: false,
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

  /// 构建7天温度折线图
  Widget _buildDailyChart(BuildContext context, bool isDark) {
    if (dailyData.isEmpty) {
      return _buildEmptyState();
    }

    // 取7天数据
    final weekData = dailyData.take(7).toList();
    
    final maxSpots = <FlSpot>[];
    final minSpots = <FlSpot>[];
    
    final allTemps = <double>[];
    for (final d in weekData) {
      allTemps.add(d.tempMax);
      allTemps.add(d.tempMin);
    }
    final minTemp = allTemps.reduce(math.min);
    final maxTemp = allTemps.reduce(math.max);

    for (int i = 0; i < weekData.length; i++) {
      maxSpots.add(FlSpot(i.toDouble(), weekData[i].tempMax));
      minSpots.add(FlSpot(i.toDouble(), weekData[i].tempMin));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              strokeWidth: 1,
            );
          },
        ),
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
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= weekData.length) {
                  return const SizedBox();
                }
                final date = weekData[index].date;
                final weekday = DateFormat('E', 'zh_CN').format(date);
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    index == 0 ? '今天' : weekday,
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 5,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}°',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (weekData.length - 1).toDouble(),
        minY: minTemp - 2,
        maxY: maxTemp + 2,
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => 
              isDark ? Colors.grey[800]! : Colors.grey[200]!,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final isMax = spot.barIndex == 0;
                return LineTooltipItem(
                  '${isMax ? '最高' : '最低'}: ${spot.y.toInt()}°C',
                  TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          // 最高温度线
          LineChartBarData(
            spots: maxSpots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: Colors.red,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.red,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(show: false),
          ),
          // 最低温度线
          LineChartBarData(
            spots: minSpots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.blue,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            '暂无温度数据',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

/// 温度图表类型
enum TemperatureChartType {
  /// 24小时
  hourly,
  /// 7天
  daily,
}
