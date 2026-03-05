import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/media_file.dart';

class AndroidMediaScanner {
  static const MethodChannel _channel = MethodChannel('com.playflutter/media_scanner');
  
  static final AndroidMediaScanner _instance = AndroidMediaScanner._internal();
  factory AndroidMediaScanner() => _instance;
  AndroidMediaScanner._internal();

  Future<List<MediaFile>> scanAudioFiles() async {
    if (!defaultTargetPlatform.isAndroid) {
      debugPrint('[AndroidMediaScanner] Not Android platform, returning empty list');
      return [];
    }
    
    try {
      debugPrint('[AndroidMediaScanner] Starting audio scan via MethodChannel...');
      final List<dynamic>? result = await _channel.invokeMethod('scanAudioFiles');
      
      if (result == null) {
        debugPrint('[AndroidMediaScanner] Audio scan result is null');
        return [];
      }
      
      debugPrint('[AndroidMediaScanner] Received ${result.length} audio files from native');
      
      final files = result.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        return MediaFile(
          id: const Uuid().v4(),
          path: map['path'] as String? ?? '',
          title: map['title'] as String? ?? '',
          artist: map['artist'] as String? ?? '',
          album: map['album'] as String? ?? '',
          albumArtPath: map['albumArt'] as String?,
          type: MediaType.audio,
          duration: (map['duration'] as int? ?? 0) ~/ 1000,
          size: map['size'] as int? ?? 0,
          bitrate: map['bitrate'] as int?,
          format: _getExtension(map['path'] as String? ?? ''),
          dateAdded: DateTime.fromMillisecondsSinceEpoch(map['dateAdded'] as int? ?? 0),
          dateModified: DateTime.fromMillisecondsSinceEpoch(map['dateModified'] as int? ?? 0),
        );
      }).toList();
      
      debugPrint('[AndroidMediaScanner] Parsed ${files.length} audio files');
      return files;
    } on PlatformException catch (e) {
      debugPrint('[AndroidMediaScanner] PlatformException: ${e.code} - ${e.message}');
      debugPrint('[AndroidMediaScanner] Details: ${e.details}');
      return [];
    } catch (e) {
      debugPrint('[AndroidMediaScanner] Unexpected error: $e');
      return [];
    }
  }

  Future<List<MediaFile>> scanVideoFiles() async {
    if (!defaultTargetPlatform.isAndroid) {
      debugPrint('[AndroidMediaScanner] Not Android platform, returning empty list');
      return [];
    }
    
    try {
      debugPrint('[AndroidMediaScanner] Starting video scan via MethodChannel...');
      final List<dynamic>? result = await _channel.invokeMethod('scanVideoFiles');
      
      if (result == null) {
        debugPrint('[AndroidMediaScanner] Video scan result is null');
        return [];
      }
      
      debugPrint('[AndroidMediaScanner] Received ${result.length} video files from native');
      
      final files = result.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        return MediaFile(
          id: const Uuid().v4(),
          path: map['path'] as String? ?? '',
          title: map['title'] as String? ?? '',
          artist: map['artist'] as String? ?? '',
          album: map['album'] as String? ?? '',
          albumArtPath: map['thumbnail'] as String?,
          type: MediaType.video,
          duration: (map['duration'] as int? ?? 0) ~/ 1000,
          size: map['size'] as int? ?? 0,
          bitrate: map['bitrate'] as int?,
          format: _getExtension(map['path'] as String? ?? ''),
          dateAdded: DateTime.fromMillisecondsSinceEpoch(map['dateAdded'] as int? ?? 0),
          dateModified: DateTime.fromMillisecondsSinceEpoch(map['dateModified'] as int? ?? 0),
        );
      }).toList();
      
      debugPrint('[AndroidMediaScanner] Parsed ${files.length} video files');
      return files;
    } on PlatformException catch (e) {
      debugPrint('[AndroidMediaScanner] PlatformException: ${e.code} - ${e.message}');
      debugPrint('[AndroidMediaScanner] Details: ${e.details}');
      return [];
    } catch (e) {
      debugPrint('[AndroidMediaScanner] Unexpected error: $e');
      return [];
    }
  }

  Future<List<MediaFile>> scanAllMediaFiles() async {
    final audioFiles = await scanAudioFiles();
    final videoFiles = await scanVideoFiles();
    
    return [...audioFiles, ...videoFiles];
  }

  String _getExtension(String path) {
    final parts = path.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }
}

extension on TargetPlatform {
  bool get isAndroid => this == TargetPlatform.android;
}
