import 'dart:io';

class FileUtils {
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  static String formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  static String getFileName(String path) {
    return path.split('/').last.split('\\').last;
  }

  static String getFileExtension(String path) {
    final fileName = getFileName(path);
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  static String getFileNameWithoutExtension(String path) {
    final fileName = getFileName(path);
    final extension = getFileExtension(path);
    if (extension.isNotEmpty) {
      return fileName.substring(0, fileName.length - extension.length - 1);
    }
    return fileName;
  }

  static String getDirectoryName(String path) {
    final normalizedPath = path.replaceAll('\\', '/');
    final lastSlash = normalizedPath.lastIndexOf('/');
    if (lastSlash > 0) {
      return normalizedPath.substring(lastSlash + 1);
    }
    return path;
  }

  static bool isAudioFile(String path) {
    final extension = getFileExtension(path);
    const audioExtensions = ['mp3', 'm4a', 'wav', 'flac', 'aac', 'ogg', 'wma', 'opus'];
    return audioExtensions.contains(extension);
  }

  static bool isVideoFile(String path) {
    final extension = getFileExtension(path);
    const videoExtensions = ['mp4', 'mkv', 'avi', 'mov', 'wmv', 'flv', 'webm', 'm4v'];
    return videoExtensions.contains(extension);
  }

  static bool isMediaFile(String path) {
    return isAudioFile(path) || isVideoFile(path);
  }

  static Future<bool> fileExists(String path) async {
    return await File(path).exists();
  }

  static Future<int> getFileSize(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }
}
