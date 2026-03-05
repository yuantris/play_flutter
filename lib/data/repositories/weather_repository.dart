import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';
import '../models/air_quality_model.dart';
import '../models/location_model.dart';
import '../services/weather_api_service.dart';
import '../services/location_service.dart';

/// 天气数据仓库
/// 负责数据的获取、缓存和管理
class WeatherRepository {
  static const String _cacheKeyWeather = 'cache_weather';
  static const String _cacheKeyAirQuality = 'cache_air_quality';
  static const String _cacheKeyLocation = 'cache_location';
  static const Duration _cacheExpiry = Duration(hours: 1);

  final WeatherApiService _apiService;
  final SharedPreferences _prefs;

  WeatherRepository({
    required WeatherApiService apiService,
    required SharedPreferences prefs,
  })  : _apiService = apiService,
        _prefs = prefs;

  /// 获取天气数据（优先使用缓存）
  Future<WeatherModel> getWeather({
    required double latitude,
    required double longitude,
    bool forceRefresh = false,
  }) async {
    final cacheKey = '${_cacheKeyWeather}_${latitude}_${longitude}';

    if (!forceRefresh) {
      final cached = _getCachedWeather(cacheKey);
      if (cached != null) {
        return cached;
      }
    }

    final weather = await _apiService.getWeather(
      latitude: latitude,
      longitude: longitude,
    );

    _cacheWeather(cacheKey, weather);
    return weather;
  }

  /// 获取空气质量数据（优先使用缓存）
  Future<AirQualityModel> getAirQuality({
    required double latitude,
    required double longitude,
    bool forceRefresh = false,
  }) async {
    final cacheKey = '${_cacheKeyAirQuality}_${latitude}_${longitude}';

    if (!forceRefresh) {
      final cached = _getCachedAirQuality(cacheKey);
      if (cached != null) {
        return cached;
      }
    }

    final airQuality = await _apiService.getAirQuality(
      latitude: latitude,
      longitude: longitude,
    );

    _cacheAirQuality(cacheKey, airQuality);
    return airQuality;
  }

  /// 搜索城市
  Future<List<LocationModel>> searchCities(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }
    return await _apiService.searchCities(query);
  }

  /// 根据坐标获取城市名
  /// 
  /// 优先使用 Android 原生 Geocoder，失败时使用 API
  Future<LocationModel?> getCityName(double latitude, double longitude) async {
    // 1. 首先尝试使用 Android 原生 Geocoder（离线，不需要网络）
    try {
      debugPrint('尝试使用 Android 原生 Geocoder...');
      final nativeResult = await LocationService.getCityNameFromCoordinates(
        latitude: latitude,
        longitude: longitude,
      );
      
      if (nativeResult != null) {
        debugPrint('原生 Geocoder 成功: ${nativeResult['cityName']}');
        return LocationModel(
          latitude: nativeResult['latitude'],
          longitude: nativeResult['longitude'],
          cityName: nativeResult['cityName'] as String,
          country: nativeResult['country'] as String?,
          admin1: nativeResult['admin1'] as String?,
        );
      }
    } catch (e) {
      debugPrint('原生 Geocoder 失败: $e');
    }
    
    // 2. 原生 Geocoder 失败，使用 API 获取
    debugPrint('使用 API 进行反向地理编码...');
    return await _apiService.reverseGeocode(
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// 获取当前位置并解析城市名
  ///
  /// 返回 null 表示定位失败或权限被拒绝
  /// 抛出 LocationException 表示具体的定位错误
  Future<LocationModel?> getCurrentLocationWithCity() async {
    try {
      final locationData = await LocationService.getLocationWithPermission();
      if (locationData == null) {
        return null;
      }

      // 尝试获取城市名，失败不影响定位结果
      try {
        final cityInfo = await getCityName(
          locationData.latitude,
          locationData.longitude,
        );

        if (cityInfo != null) {
          return LocationModel(
            latitude: locationData.latitude,
            longitude: locationData.longitude,
            cityName: cityInfo.cityName,
            country: cityInfo.country,
            admin1: cityInfo.admin1,
          );
        }
      } catch (e) {
        // 反向地理编码失败，使用默认城市名
        debugPrint('反向地理编码失败: $e');
      }

      // 返回位置信息，使用默认城市名
      return LocationModel(
        latitude: locationData.latitude,
        longitude: locationData.longitude,
        cityName: '当前位置',
      );
    } on LocationException {
      // 向上传递 LocationException，让调用者处理具体的错误类型
      rethrow;
    } catch (e) {
      // 其他未知错误返回 null
      return null;
    }
  }

  /// 检查位置权限状态
  Future<PermissionStatus> checkLocationPermission() async {
    return await LocationService.checkPermission();
  }

  /// 请求位置权限
  Future<PermissionStatus> requestLocationPermission() async {
    return await LocationService.requestPermission();
  }

  /// 打开应用设置页面
  Future<void> openAppSettings() async {
    await LocationService.openAppSettings();
  }

  /// 保存选中的位置
  Future<void> saveSelectedLocation(LocationModel location) async {
    await _prefs.setString(_cacheKeyLocation, jsonEncode(location.toJson()));
  }

  /// 获取保存的位置
  LocationModel? getSavedLocation() {
    final json = _prefs.getString(_cacheKeyLocation);
    if (json == null) return null;

    try {
      return LocationModel.fromJson(jsonDecode(json));
    } catch (e) {
      return null;
    }
  }

  /// 缓存天气数据
  void _cacheWeather(String key, WeatherModel weather) {
    final data = {
      'weather': weather.toJson(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    _prefs.setString(key, jsonEncode(data));
  }

  /// 获取缓存的天气数据
  WeatherModel? _getCachedWeather(String key) {
    final json = _prefs.getString(key);
    if (json == null) return null;

    try {
      final data = jsonDecode(json) as Map<String, dynamic>;
      final timestamp = data['timestamp'] as int;
      final now = DateTime.now().millisecondsSinceEpoch;

      if (now - timestamp > _cacheExpiry.inMilliseconds) {
        return null;
      }

      return WeatherModel.fromJson(data['weather'] as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  /// 缓存空气质量数据
  void _cacheAirQuality(String key, AirQualityModel airQuality) {
    final data = {
      'airQuality': airQuality.toJson(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    _prefs.setString(key, jsonEncode(data));
  }

  /// 获取缓存的空气质量数据
  AirQualityModel? _getCachedAirQuality(String key) {
    final jsonString = _prefs.getString(key);

    // 检查空值、空字符串、"0" 等无效值
    if (jsonString == null || jsonString.isEmpty || jsonString == '0') {
      return null;
    }

    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      final timestamp = data['timestamp'] as int?;

      // 验证必需字段
      if (timestamp == null) {
        return null;
      }

      final now = DateTime.now().millisecondsSinceEpoch;

      if (now - timestamp > _cacheExpiry.inMilliseconds) {
        return null;
      }

      final airQualityJson = data['airQuality'] as Map<String, dynamic>?;

      if (airQualityJson == null) {
        return null;
      }

      final airQuality = AirQualityModel.fromJson(airQualityJson);

      // 验证 AQI 是否有效（如果是 0，可能是无效数据）
      if (airQuality.europeanAqi == 0 && airQuality.pm2_5 == 0) {
        return null;
      }

      return airQuality;
    } catch (e) {
      return null;
    }
  }

  /// 清除所有缓存
  Future<void> clearCache() async {
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_cacheKeyWeather) ||
          key.startsWith(_cacheKeyAirQuality)) {
        await _prefs.remove(key);
      }
    }
  }
}
