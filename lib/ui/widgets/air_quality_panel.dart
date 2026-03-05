import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/air_quality_model.dart';

/// 空气质量面板组件
class AirQualityPanel extends StatelessWidget {
  final AirQualityModel? airQuality;

  const AirQualityPanel({
    super.key,
    this.airQuality,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: const Border(),
        collapsedShape: const Border(),
        splashColor: Colors.transparent,
        title: Row(
          children: [
            const Icon(Icons.air_outlined, size: 20),
            const SizedBox(width: 8),
            const Text(
              '空气质量',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (airQuality != null) _buildAqiBadge(airQuality!),
          ],
        ),
        children: [
          if (airQuality != null) _buildAqiDetails(airQuality!),
        ],
      ),
    );
  }

  /// 构建AQI徽章
  Widget _buildAqiBadge(AirQualityModel aqi) {
    final color = Color(aqi.aqiColorValue);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${aqi.europeanAqi}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            aqi.aqiLevel,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建AQI详情
  Widget _buildAqiDetails(AirQualityModel aqi) {
    return Column(
      children: [
        _buildAqiBar(aqi),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildPollutantItem('PM2.5', aqi.pm2_5, 'μg/m³'),
            _buildPollutantItem('PM10', aqi.pm10, 'μg/m³'),
            _buildPollutantItem('O₃', aqi.ozone, 'μg/m³'),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildPollutantItem('NO₂', aqi.nitrogenDioxide, 'μg/m³'),
            _buildPollutantItem('SO₂', aqi.sulphurDioxide, 'μg/m³'),
            _buildPollutantItem('CO', aqi.carbonMonoxide, 'mg/m³'),
          ],
        ),
      ],
    );
  }

  /// 构建AQI进度条
  Widget _buildAqiBar(AirQualityModel aqi) {
    final percentage = (aqi.europeanAqi / 100).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Stack(
                children: [
                  Container(
                    height: 8,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.aqiGood,
                          AppColors.aqiModerate,
                          AppColors.aqiUnhealthy,
                          AppColors.aqiVeryUnhealthy,
                          AppColors.aqiHazardous,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Positioned(
                    left: percentage * constraints.maxWidth,
                    child: Container(
                      width: 3,
                      height: 8,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '优',
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
            Text(
              '良',
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
            Text(
              '轻度',
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
            Text(
              '中度',
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
            Text(
              '重度',
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建污染物项
  Widget _buildPollutantItem(String name, double value, String unit) {
    return Column(
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          unit,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
