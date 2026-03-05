import 'package:flutter/services.dart';

/// 位置数据模型
class LocationData {
  final double latitude;
  final double longitude;
  final double accuracy;
  final double altitude;
  final double speed;
  final double bearing;
  final int time;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    this.altitude = 0.0,
    this.speed = 0.0,
    this.bearing = 0.0,
    required this.time,
  });

  factory LocationData.fromMap(Map<dynamic, dynamic> map) {
    return LocationData(
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      accuracy: (map['accuracy'] as num).toDouble(),
      altitude: (map['altitude'] as num?)?.toDouble() ?? 0.0,
      speed: (map['speed'] as num?)?.toDouble() ?? 0.0,
      bearing: (map['bearing'] as num?)?.toDouble() ?? 0.0,
      time: map['time'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'altitude': altitude,
      'speed': speed,
      'bearing': bearing,
      'time': time,
    };
  }
}

/// 权限状态枚举
enum PermissionStatus {
  granted,      // 已授予精确位置权限
  coarse,       // 仅授予粗略位置权限
  denied,       // 被拒绝
  deniedPermanently, // 被永久拒绝（需要前往设置）
}

/// 定位服务
/// 通过MethodChannel与原生Android定位功能通信
///
/// 支持功能：
/// 1. 检查/请求位置权限
/// 2. 获取当前位置（带超时处理）
/// 3. 检查 Google Play Services 可用性
/// 4. 打开应用设置页面
class LocationService {
  static const MethodChannel _channel = MethodChannel(
    'com.app.fy.flutter.play_flutter/location',
  );

  LocationService._();

  /// 检查位置权限状态
  /// 返回: PermissionStatus 枚举
  static Future<PermissionStatus> checkPermission() async {
    try {
      final String result = await _channel.invokeMethod('checkPermission');
      return _parsePermissionStatus(result);
    } on PlatformException catch (e) {
      throw LocationException(
        code: e.code,
        message: e.message ?? '检查权限失败',
      );
    }
  }

  /// 请求位置权限
  /// 返回: PermissionStatus 枚举
  static Future<PermissionStatus> requestPermission() async {
    try {
      final String result = await _channel.invokeMethod('requestPermission');
      return _parsePermissionStatus(result);
    } on PlatformException catch (e) {
      throw LocationException(
        code: e.code,
        message: e.message ?? '请求权限失败',
      );
    }
  }

  /// 解析权限状态字符串
  static PermissionStatus _parsePermissionStatus(String status) {
    switch (status) {
      case 'granted':
        return PermissionStatus.granted;
      case 'coarse':
        return PermissionStatus.coarse;
      case 'denied_permanently':
        return PermissionStatus.deniedPermanently;
      case 'denied':
      default:
        return PermissionStatus.denied;
    }
  }

  /// 获取当前位置
  /// 可能抛出的异常：
  /// - PERMISSION_DENIED: 权限未授予
  /// - LOCATION_TIMEOUT: 获取位置超时
  /// - GOOGLE_PLAY_SERVICES_NOT_AVAILABLE: Google Play 服务不可用
  /// - LOCATION_ERROR: 其他定位错误
  static Future<LocationData> getCurrentLocation() async {
    try {
      final Map<dynamic, dynamic> result =
          await _channel.invokeMethod('getCurrentLocation');
      return LocationData.fromMap(result);
    } on PlatformException catch (e) {
      throw LocationException(
        code: e.code,
        message: e.message ?? '获取位置失败',
      );
    }
  }

  /// 检查权限并获取位置
  /// 如果没有权限会自动请求
  ///
  /// 返回 null 表示：
  /// - 权限被拒绝
  /// - 权限被永久拒绝
  /// - 获取位置超时
  /// - Google Play 服务不可用
  static Future<LocationData?> getLocationWithPermission() async {
    try {
      var permission = await checkPermission();

      if (permission == PermissionStatus.denied) {
        permission = await requestPermission();
      }

      // 如果被永久拒绝或仍然拒绝，返回 null
      if (permission == PermissionStatus.denied ||
          permission == PermissionStatus.deniedPermanently) {
        return null;
      }

      return await getCurrentLocation();
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        return null;
      }
      if (e.code == 'LOCATION_TIMEOUT') {
        throw LocationException(
          code: e.code,
          message: '获取位置超时，请检查GPS是否开启',
        );
      }
      if (e.code == 'GOOGLE_PLAY_SERVICES_NOT_AVAILABLE') {
        throw LocationException(
          code: e.code,
          message: 'Google Play 服务不可用',
        );
      }
      rethrow;
    } on LocationException {
      rethrow;
    }
  }

  /// 检查 Google Play Services 是否可用
  static Future<bool> checkGooglePlayServices() async {
    try {
      final bool result =
          await _channel.invokeMethod('checkGooglePlayServices');
      return result;
    } on PlatformException catch (e) {
      throw LocationException(
        code: e.code,
        message: e.message ?? '检查 Google Play Services 失败',
      );
    }
  }

  /// 打开应用设置页面
  /// 用于引导用户手动开启权限
  static Future<void> openAppSettings() async {
    try {
      await _channel.invokeMethod('openAppSettings');
    } on PlatformException catch (e) {
      throw LocationException(
        code: e.code,
        message: e.message ?? '打开设置失败',
      );
    }
  }

  /// 检查权限是否被永久拒绝
  static Future<bool> isPermanentlyDenied() async {
    final status = await checkPermission();
    return status == PermissionStatus.deniedPermanently;
  }

  /// 检查是否有位置权限（包括粗略权限）
  static Future<bool> hasLocationPermission() async {
    final status = await checkPermission();
    return status == PermissionStatus.granted || status == PermissionStatus.coarse;
  }

  /// 使用 Android 原生 Geocoder 根据坐标获取城市名
  /// 
  /// 返回包含以下字段的 Map：
  /// - cityName: 城市名
  /// - country: 国家
  /// - admin1: 省/州
  /// - latitude: 纬度
  /// - longitude: 经度
  /// 
  /// 如果无法获取地址信息，返回 null
  static Future<Map<String, dynamic>?> getCityNameFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final Map<dynamic, dynamic>? result = await _channel.invokeMethod(
        'getCityNameFromCoordinates',
        {
          'latitude': latitude,
          'longitude': longitude,
        },
      );
      
      if (result == null) {
        return null;
      }
      
      return {
        'cityName': result['cityName'] as String,
        'country': result['country'] as String?,
        'admin1': result['admin1'] as String?,
        'latitude': (result['latitude'] as num).toDouble(),
        'longitude': (result['longitude'] as num).toDouble(),
      };
    } on PlatformException catch (e) {
      throw LocationException(
        code: e.code,
        message: e.message ?? '反向地理编码失败',
      );
    }
  }
}

/// 定位异常
class LocationException implements Exception {
  final String code;
  final String message;

  LocationException({required this.code, required this.message});

  @override
  String toString() => 'LocationException: $code - $message';

  /// 是否是权限错误
  bool get isPermissionError =>
      code == 'PERMISSION_DENIED' || code == 'denied' || code == 'denied_permanently';

  /// 是否是超时错误
  bool get isTimeoutError => code == 'LOCATION_TIMEOUT';

  /// 是否是 Google Play Services 错误
  bool get isGooglePlayServicesError => code == 'GOOGLE_PLAY_SERVICES_NOT_AVAILABLE';
}
