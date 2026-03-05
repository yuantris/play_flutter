import 'package:flutter/material.dart';
import '../data/models/weather_model.dart';
import '../data/models/air_quality_model.dart';
import '../data/models/location_model.dart';
import '../data/repositories/weather_repository.dart';
import '../data/services/location_service.dart';

/// 天气数据加载状态
enum WeatherLoadStatus {
  initial,
  loading,
  loadingLocation, // 正在获取位置
  success,
  error,
  permissionDenied, // 权限被拒绝
  permissionPermanentlyDenied, // 权限被永久拒绝
  locationTimeout, // 定位超时
  googlePlayServicesNotAvailable, // Google Play 服务不可用
}

/// 天气状态管理
/// 管理天气数据、位置信息和加载状态
class WeatherProvider extends ChangeNotifier {
  final WeatherRepository _repository;

  WeatherLoadStatus _status = WeatherLoadStatus.initial;
  WeatherModel? _weather;
  AirQualityModel? _airQuality;
  LocationModel? _currentLocation;
  String? _errorMessage;
  bool _isLoadingLocation = false;

  WeatherProvider({required WeatherRepository repository})
      : _repository = repository;

  /// 获取当前加载状态
  WeatherLoadStatus get status => _status;

  /// 获取天气数据
  WeatherModel? get weather => _weather;

  /// 获取空气质量数据
  AirQualityModel? get airQuality => _airQuality;

  /// 获取当前位置
  LocationModel? get currentLocation => _currentLocation;

  /// 获取错误信息
  String? get errorMessage => _errorMessage;

  /// 是否正在加载位置
  bool get isLoadingLocation => _isLoadingLocation;

  /// 是否有数据
  bool get hasData => _weather != null;

  /// 是否显示定位按钮
  bool get showLocationButton =>
      _status == WeatherLoadStatus.permissionDenied ||
      _status == WeatherLoadStatus.permissionPermanentlyDenied ||
      _status == WeatherLoadStatus.locationTimeout;

  /// 初始化
  /// 尝试加载保存的位置或获取当前位置
  Future<void> initialize() async {
    final savedLocation = _repository.getSavedLocation();
    if (savedLocation != null) {
      _currentLocation = savedLocation;
      await loadWeatherData();
    } else {
      await loadCurrentLocation();
    }
  }

  /// 加载当前位置
  Future<void> loadCurrentLocation() async {
    _isLoadingLocation = true;
    _errorMessage = null;
    _status = WeatherLoadStatus.loadingLocation;
    notifyListeners();

    try {
      // 先检查权限状态
      final permissionStatus = await _repository.checkLocationPermission();

      if (permissionStatus == PermissionStatus.deniedPermanently) {
        _status = WeatherLoadStatus.permissionPermanentlyDenied;
        _errorMessage = '位置权限被永久拒绝\n请前往设置手动开启位置权限';
        _isLoadingLocation = false;
        notifyListeners();
        return;
      }

      final location = await _repository.getCurrentLocationWithCity();
      if (location != null) {
        _currentLocation = location;
        await _repository.saveSelectedLocation(location);
        await loadWeatherData();
      } else {
        // 权限被拒绝
        if (permissionStatus == PermissionStatus.denied) {
          _status = WeatherLoadStatus.permissionDenied;
          _errorMessage = '位置权限被拒绝\n请点击"选择城市"手动选择位置';
        } else {
          _status = WeatherLoadStatus.error;
          _errorMessage = '无法获取位置信息\n请检查GPS是否开启';
        }
        _isLoadingLocation = false;
        notifyListeners();
      }
    } on LocationException catch (e) {
      _handleLocationException(e);
    } catch (e) {
      _errorMessage = '定位失败: ${e.toString()}';
      _status = WeatherLoadStatus.error;
      _isLoadingLocation = false;
      notifyListeners();
    }
  }

  /// 处理定位异常
  void _handleLocationException(LocationException e) {
    _isLoadingLocation = false;

    if (e.isPermissionError) {
      if (e.code == 'denied_permanently') {
        _status = WeatherLoadStatus.permissionPermanentlyDenied;
        _errorMessage = '位置权限被永久拒绝\n请前往设置手动开启位置权限';
      } else {
        _status = WeatherLoadStatus.permissionDenied;
        _errorMessage = '位置权限被拒绝\n请点击"选择城市"手动选择位置';
      }
    } else if (e.isTimeoutError) {
      _status = WeatherLoadStatus.locationTimeout;
      _errorMessage = '获取位置超时\n请检查GPS是否开启，或手动选择城市';
    } else if (e.isGooglePlayServicesError) {
      _status = WeatherLoadStatus.googlePlayServicesNotAvailable;
      _errorMessage = 'Google Play 服务不可用\n请安装或更新 Google Play 服务';
    } else {
      _status = WeatherLoadStatus.error;
      _errorMessage = '定位失败: ${e.message}';
    }

    notifyListeners();
  }

  /// 请求位置权限
  Future<void> requestLocationPermission() async {
    _isLoadingLocation = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final status = await _repository.requestLocationPermission();

      if (status == PermissionStatus.granted || status == PermissionStatus.coarse) {
        // 权限已授予，重新获取位置
        await loadCurrentLocation();
      } else if (status == PermissionStatus.deniedPermanently) {
        _status = WeatherLoadStatus.permissionPermanentlyDenied;
        _errorMessage = '位置权限被永久拒绝\n请前往设置手动开启位置权限';
        _isLoadingLocation = false;
        notifyListeners();
      } else {
        _status = WeatherLoadStatus.permissionDenied;
        _errorMessage = '位置权限被拒绝\n请点击"选择城市"手动选择位置';
        _isLoadingLocation = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = '请求权限失败: ${e.toString()}';
      _status = WeatherLoadStatus.error;
      _isLoadingLocation = false;
      notifyListeners();
    }
  }

  /// 打开应用设置页面
  Future<void> openAppSettings() async {
    try {
      await _repository.openAppSettings();
    } catch (e) {
      _errorMessage = '无法打开设置: ${e.toString()}';
      notifyListeners();
    }
  }

  /// 选择城市
  Future<void> selectCity(LocationModel location) async {
    _currentLocation = location;
    await _repository.saveSelectedLocation(location);
    await loadWeatherData();
  }

  /// 加载天气数据
  Future<void> loadWeatherData({bool forceRefresh = false}) async {
    if (_currentLocation == null) {
      _errorMessage = '请先选择位置';
      _status = WeatherLoadStatus.error;
      notifyListeners();
      return;
    }

    _status = WeatherLoadStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // 先获取天气数据
      debugPrint('🌤️ 开始获取天气...');
      _weather = await _repository.getWeather(
        latitude: _currentLocation!.latitude,
        longitude: _currentLocation!.longitude,
        forceRefresh: forceRefresh,
      );
      debugPrint('✅ 天气获取成功：${_weather?.current?.temperature}');

      // 尝试获取空气质量，失败不影响天气显示
      try {
        debugPrint('🔍 开始获取空气质量...');
        _airQuality = await _repository.getAirQuality(
          latitude: _currentLocation!.latitude,
          longitude: _currentLocation!.longitude,
          forceRefresh: forceRefresh,
        );
        debugPrint('✅ 空气质量获取成功：${_airQuality?.europeanAqi}');
      } catch (e) {
        debugPrint('❌ 空气质量获取失败：$e');
        // 空气质量获取失败，设为null但不影响整体显示
        _airQuality = null;
      }
      debugPrint('✨ 设置状态为 success');
      _status = WeatherLoadStatus.success;
    } catch (e) {
      _errorMessage = '加载天气数据失败: ${e.toString()}';
      _status = WeatherLoadStatus.error;
    }

    _isLoadingLocation = false;
    notifyListeners();
  }

  /// 刷新数据
  Future<void> refresh() async {
    await loadWeatherData(forceRefresh: true);
  }

  /// 重试加载
  Future<void> retry() async {
    if (_currentLocation != null) {
      await loadWeatherData();
    } else {
      await loadCurrentLocation();
    }
  }

  /// 重试定位
  Future<void> retryLocation() async {
    await loadCurrentLocation();
  }
}
