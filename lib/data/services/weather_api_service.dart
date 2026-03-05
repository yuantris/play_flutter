import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/network/base_api_service.dart';
import '../models/weather_model.dart';
import '../models/air_quality_model.dart';
import '../models/location_model.dart';

/// Open-Meteo API 配置
class OpenMeteoConfig {
  static const String baseUrl = 'https://api.open-meteo.com/v1';
  static const String airQualityUrl = 'https://air-quality-api.open-meteo.com/v1';
  static const String geocodingUrl = 'https://geocoding-api.open-meteo.com/v1';

  // 预定义的参数字段
  static const Map<String, List<String>> weatherFields = {
    'current': [
      'temperature_2m',
      'relative_humidity_2m',
      'apparent_temperature',
      'weather_code',
      'wind_speed_10m',
    ],
    'daily': [
      'weather_code',
      'temperature_2m_max',
      'temperature_2m_min',
      'precipitation_sum',
      'wind_speed_10m_max',
    ],
    'hourly': [
      'temperature_2m',
      'weather_code',
      'relative_humidity_2m',
      'wind_speed_10m',
    ],
  };

  static const Map<String, List<String>> airQualityFields = {
    'current': [
      'european_aqi',
      'pm10',
      'pm2_5',
      'carbon_monoxide',
      'nitrogen_dioxide',
      'sulphur_dioxide',
      'ozone',
    ],
  };
}

/// Open-Meteo API 服务
/// 提供天气数据、空气质量、地理编码等接口
class WeatherApiService extends BaseApiService {

  /// 获取天气数据
  Future<WeatherModel> getWeather({
    required double latitude,
    required double longitude,
    int forecastDays = 7,
  }) {
    final queryParams = {
      'latitude': latitude,
      'longitude': longitude,
      'current': OpenMeteoConfig.weatherFields['current']!.join(','),
      'daily': OpenMeteoConfig.weatherFields['daily']!.join(','),
      'hourly': OpenMeteoConfig.weatherFields['hourly']!.join(','),
      'timezone': 'auto',
      'forecast_days': forecastDays,
    };

    return get(
      url: '${OpenMeteoConfig.baseUrl}/forecast',
      queryParameters: queryParams,
      parser: (json) => WeatherModel.fromJson(json),
    );
  }

  /// 获取空气质量
  Future<AirQualityModel> getAirQuality({
    required double latitude,
    required double longitude,
  }) {
    final queryParams = {
      'latitude': latitude,
      'longitude': longitude,
      'current': OpenMeteoConfig.airQualityFields['current']!.join(','),
      'timezone': 'auto',
    };

    return get(
      url: '${OpenMeteoConfig.airQualityUrl}/air-quality',
      queryParameters: queryParams,
      parser: (json) => AirQualityModel.fromJson(json),
    );
  }

  /// 搜索城市
  Future<List<LocationModel>> searchCities(String cityName) async {
    final queryParams = {
      'name': cityName,
      'count': 10,
      'language': 'zh',
      'format': 'json',
    };

    final result = await get(
      url: '${OpenMeteoConfig.geocodingUrl}/search',
      queryParameters: queryParams,
      parser: (json) => json,  // 临时返回原始 JSON
    );

    // 特殊处理，因为返回的是列表
    final results = result['results'] as List?;
    if (results == null || results.isEmpty) {
      return [];
    }

    return results
        .map((json) => LocationModel.fromGeocodingJson(json))
        .toList();
  }

  /// 反向地理编码
  Future<LocationModel?> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    final queryParams = {
      'latitude': latitude,
      'longitude': longitude,
      'language': 'zh',
      'format': 'json',
    };

    try {
      final result = await get(
        url: '${OpenMeteoConfig.geocodingUrl}/reverse',
        queryParameters: queryParams,
        parser: (json) => json,
      );

      final results = result['results'] as List?;
      if (results == null || results.isEmpty) {
        return null;
      }

      return LocationModel.fromGeocodingJson(results.first);
    } on NetworkException catch (e) {
      // 可以在这里处理特定的错误
      if (e.code == 404) {
        return null;  // 没有找到位置
      }
      rethrow;
    }
  }
}

/// 天气API异常
class WeatherApiException implements Exception {
  final String code;
  final String message;

  WeatherApiException({required this.code, required this.message});

  @override
  String toString() => 'WeatherApiException: $code - $message';
}
