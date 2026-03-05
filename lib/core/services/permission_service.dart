import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  Future<bool> requestStoragePermission() async {
    if (await _isAndroid13OrAbove()) {
      return await _requestMediaPermissions();
    } else {
      return await _requestLegacyStoragePermission();
    }
  }

  Future<bool> _isAndroid13OrAbove() async {
    return true;
  }

  Future<bool> _requestMediaPermissions() async {
    final audioStatus = await Permission.audio.request();
    final videoStatus = await Permission.videos.request();
    
    return audioStatus.isGranted || videoStatus.isGranted;
  }

  Future<bool> _requestLegacyStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  Future<bool> checkStoragePermission() async {
    if (await _isAndroid13OrAbove()) {
      final audioStatus = await Permission.audio.status;
      final videoStatus = await Permission.videos.status;
      return audioStatus.isGranted || videoStatus.isGranted;
    } else {
      final status = await Permission.storage.status;
      return status.isGranted;
    }
  }

  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<bool> checkMicrophonePermission() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }

  Future<bool> openAppSettings() async {
    return await openAppSettings();
  }

  Future<Map<String, bool>> requestAllPermissions() async {
    final results = <String, bool>{};
    
    results['storage'] = await requestStoragePermission();
    
    return results;
  }

  Future<PermissionStatus> getStoragePermissionStatus() async {
    if (await _isAndroid13OrAbove()) {
      final audioStatus = await Permission.audio.status;
      final videoStatus = await Permission.videos.status;
      
      if (audioStatus.isGranted || videoStatus.isGranted) {
        return PermissionStatus.granted;
      } else if (audioStatus.isPermanentlyDenied || videoStatus.isPermanentlyDenied) {
        return PermissionStatus.permanentlyDenied;
      } else {
        return PermissionStatus.denied;
      }
    } else {
      return await Permission.storage.status;
    }
  }

  bool isGranted(PermissionStatus status) {
    return status == PermissionStatus.granted;
  }

  bool isDenied(PermissionStatus status) {
    return status == PermissionStatus.denied;
  }

  bool isPermanentlyDenied(PermissionStatus status) {
    return status == PermissionStatus.permanentlyDenied;
  }
}

Future<void> showPermissionDialog(BuildContext context, {
  required String title,
  required String message,
  required VoidCallback onGranted,
  VoidCallback? onDenied,
}) async {
  final permissionService = PermissionService();
  
  final status = await permissionService.getStoragePermissionStatus();
  
  if (permissionService.isGranted(status)) {
    onGranted();
    return;
  }
  
  if (permissionService.isPermanentlyDenied(status)) {
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text('$message\n\n请在设置中手动授予权限。'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onDenied?.call();
              },
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                openAppSettings();
              },
              child: const Text('打开设置'),
            ),
          ],
        ),
      );
    }
    return;
  }
  
  final granted = await permissionService.requestStoragePermission();
  
  if (granted) {
    onGranted();
  } else {
    onDenied?.call();
  }
}

Future<bool> checkAndRequestPermission(BuildContext context) async {
  final permissionService = PermissionService();
  
  final status = await permissionService.getStoragePermissionStatus();
  
  if (permissionService.isGranted(status)) {
    return true;
  }
  
  if (permissionService.isPermanentlyDenied(status)) {
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('需要存储权限'),
          content: const Text('应用需要存储权限来扫描和播放媒体文件。\n\n请在设置中手动授予权限。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                openAppSettings();
              },
              child: const Text('打开设置'),
            ),
          ],
        ),
      );
    }
    return false;
  }
  
  final granted = await permissionService.requestStoragePermission();
  
  if (!granted && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('存储权限被拒绝，无法扫描媒体文件'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  return granted;
}
