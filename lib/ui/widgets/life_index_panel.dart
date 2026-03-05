import 'package:flutter/material.dart';
import '../../data/models/weather_model.dart';

/// 生活建议面板组件
class LifeIndexPanel extends StatelessWidget {
  final WeatherModel? weather;

  const LifeIndexPanel({
    super.key,
    this.weather,
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
        title: const Row(
          children: [
            Icon(Icons.tips_and_updates_outlined, size: 20),
            SizedBox(width: 8),
            Text(
              '生活建议',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        children: [
          _buildLifeIndexGrid(context),
        ],
      ),
    );
  }

  /// 构建生活指数网格
  Widget _buildLifeIndexGrid(BuildContext context) {
    final current = weather?.current;
    final indices = _getLifeIndices(current);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 0), // 关键：清除顶部默认padding
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: indices.length,
      itemBuilder: (context, index) {
        return _buildIndexItem(context, indices[index]);
      },
    );
  }

  /// 获取生活指数列表
  List<LifeIndex> _getLifeIndices(CurrentWeather? current) {
    final indices = <LifeIndex>[];

    if (current != null) {
      indices.add(LifeIndex(
        icon: Icons.directions_run,
        title: '运动',
        level: _getExerciseLevel(current),
        description: _getExerciseAdvice(current),
      ));

      indices.add(LifeIndex(
        icon: Icons.umbrella,
        title: '雨伞',
        level: _getUmbrellaLevel(current.weatherCode),
        description: _getUmbrellaAdvice(current.weatherCode),
      ));

      indices.add(LifeIndex(
        icon: Icons.checkroom,
        title: '穿衣',
        level: _getClothingLevel(current.temperature),
        description: _getClothingAdvice(current.temperature),
      ));

      indices.add(LifeIndex(
        icon: Icons.wb_sunny,
        title: '紫外线',
        level: _getUvLevel(current.weatherCode),
        description: _getUvAdvice(current.weatherCode),
      ));

      indices.add(LifeIndex(
        icon: Icons.air,
        title: '通风',
        level: _getVentilationLevel(current.windSpeed),
        description: _getVentilationAdvice(current.windSpeed),
      ));

      indices.add(LifeIndex(
        icon: Icons.local_florist,
        title: '花粉',
        level: '中等',
        description: '易过敏人群注意防护',
      ));
    }

    return indices;
  }

  /// 构建指数项
  Widget _buildIndexItem(BuildContext context, LifeIndex index) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            index.icon,
            size: 24,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 4),
          Text(
            index.title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          Text(
            index.level,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getExerciseLevel(CurrentWeather weather) {
    if (weather.temperature > 35 || weather.temperature < -10) return '不宜';
    if (weather.weatherCode >= 61) return '不宜';
    if (weather.windSpeed > 30) return '不宜';
    return '适宜';
  }

  String _getExerciseAdvice(CurrentWeather weather) {
    if (weather.temperature > 35) return '高温天气，避免户外运动';
    if (weather.temperature < -10) return '天气寒冷，注意保暖';
    if (weather.weatherCode >= 61) return '有降水，不宜户外运动';
    if (weather.windSpeed > 30) return '风力较大，不宜户外运动';
    return '天气不错，适合户外运动';
  }

  String _getUmbrellaLevel(int code) {
    if (code >= 61 && code <= 82) return '需要';
    if (code >= 51 && code <= 57) return '建议携带';
    return '不需要';
  }

  String _getUmbrellaAdvice(int code) {
    if (code >= 61 && code <= 82) return '有降水，请携带雨具';
    if (code >= 51 && code <= 57) return '可能有雨，建议携带';
    return '无需携带雨具';
  }

  String _getClothingLevel(double temp) {
    if (temp >= 30) return '炎热';
    if (temp >= 20) return '舒适';
    if (temp >= 10) return '微凉';
    if (temp >= 0) return '寒冷';
    return '严寒';
  }

  String _getClothingAdvice(double temp) {
    if (temp >= 30) return '穿短袖、短裤等夏季服装';
    if (temp >= 20) return '穿长袖、薄外套等春秋装';
    if (temp >= 10) return '穿毛衣、外套等保暖衣物';
    if (temp >= 0) return '穿棉衣、羽绒服等冬装';
    return '穿厚羽绒服，注意防寒';
  }

  String _getUvLevel(int code) {
    if (code == 0 || code == 1) return '强';
    if (code == 2) return '中等';
    return '弱';
  }

  String _getUvAdvice(int code) {
    if (code == 0 || code == 1) return '紫外线强，注意防晒';
    if (code == 2) return '紫外线中等，适当防护';
    return '紫外线弱，无需特别防护';
  }

  String _getVentilationLevel(double windSpeed) {
    if (windSpeed > 20) return '极佳';
    if (windSpeed > 10) return '良好';
    return '一般';
  }

  String _getVentilationAdvice(double windSpeed) {
    if (windSpeed > 20) return '风力较大，适合通风';
    if (windSpeed > 10) return '有风，可开窗通风';
    return '风力较小，适当通风';
  }
}

/// 生活指数数据类
class LifeIndex {
  final IconData icon;
  final String title;
  final String level;
  final String description;

  LifeIndex({
    required this.icon,
    required this.title,
    required this.level,
    required this.description,
  });
}
