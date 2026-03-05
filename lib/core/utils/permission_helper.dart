import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  static Future<bool> requestStoragePermission() async {
    if (await _checkAndroidVersion()) {
      return await _requestMediaPermissions();
    } else {
      return await _requestLegacyStoragePermission();
    }
  }

  static Future<bool> _checkAndroidVersion() async {
    return true;
  }

  static Future<bool> _requestMediaPermissions() async {
    final audioStatus = await Permission.audio.request();
    final videoStatus = await Permission.videos.request();
    
    return audioStatus.isGranted || videoStatus.isGranted;
  }

  static Future<bool> _requestLegacyStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  static Future<bool> checkStoragePermission() async {
    if (await _checkAndroidVersion()) {
      final audioStatus = await Permission.audio.status;
      final videoStatus = await Permission.videos.status;
      return audioStatus.isGranted || videoStatus.isGranted;
    } else {
      final status = await Permission.storage.status;
      return status.isGranted;
    }
  }

  static Future<bool> openSettings() async {
    return await openAppSettings();
  }

  static Future<void> requestAllPermissions() async {
    await requestStoragePermission();
  }
}
