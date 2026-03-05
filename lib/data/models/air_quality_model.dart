/// 空气质量数据模型
class AirQualityModel {
  final int europeanAqi;
  final double pm10;
  final double pm2_5;
  final double carbonMonoxide;
  final double nitrogenDioxide;
  final double sulphurDioxide;
  final double ozone;
  final DateTime time;

  AirQualityModel({
    required this.europeanAqi,
    required this.pm10,
    required this.pm2_5,
    required this.carbonMonoxide,
    required this.nitrogenDioxide,
    required this.sulphurDioxide,
    required this.ozone,
    required this.time,
  });

  factory AirQualityModel.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>?;
    return AirQualityModel(
      europeanAqi: current?['european_aqi'] as int? ?? 0,
      pm10: (current?['pm10'] as num?)?.toDouble() ?? 0.0,
      pm2_5: (current?['pm2_5'] as num?)?.toDouble() ?? 0.0,
      carbonMonoxide: (current?['carbon_monoxide'] as num?)?.toDouble() ?? 0.0,
      nitrogenDioxide: (current?['nitrogen_dioxide'] as num?)?.toDouble() ?? 0.0,
      sulphurDioxide: (current?['sulphur_dioxide'] as num?)?.toDouble() ?? 0.0,
      ozone: (current?['ozone'] as num?)?.toDouble() ?? 0.0,
      time: current?['time'] != null
          ? DateTime.parse(current!['time'] as String)
          : DateTime.now(),
    );
  }

  /// 获取AQI等级描述
  String get aqiLevel {
    if (europeanAqi <= 20) return '优';
    if (europeanAqi <= 40) return '良';
    if (europeanAqi <= 60) return '轻度污染';
    if (europeanAqi <= 80) return '中度污染';
    if (europeanAqi <= 100) return '重度污染';
    return '严重污染';
  }

  /// 获取AQI颜色
  int get aqiColorValue {
    if (europeanAqi <= 20) return 0xFF4CAF50;
    if (europeanAqi <= 40) return 0xFFFFEB3B;
    if (europeanAqi <= 60) return 0xFFFF9800;
    if (europeanAqi <= 80) return 0xFFF44336;
    return 0xFF9C27B0;
  }

  Map<String, dynamic> toJson() {
    return {
      'european_aqi': europeanAqi,
      'pm10': pm10,
      'pm2_5': pm2_5,
      'carbon_monoxide': carbonMonoxide,
      'nitrogen_dioxide': nitrogenDioxide,
      'sulphur_dioxide': sulphurDioxide,
      'ozone': ozone,
      'time': time.toIso8601String(),
    };
  }
}
