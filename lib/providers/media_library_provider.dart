import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import '../data/models/media_file.dart';
import '../data/models/playlist.dart';
import '../data/models/media_folder.dart';
import '../core/services/android_media_scanner.dart';

enum MediaSortType {
  title,
  artist,
  album,
  dateAdded,
  dateModified,
  duration,
  size,
}

class MediaLibraryProvider extends ChangeNotifier {
  final AndroidMediaScanner _mediaScanner = AndroidMediaScanner();
  
  List<MediaFile> _allMedia = [];
  List<MediaFile> _audioFiles = [];
  List<MediaFile> _videoFiles = [];
  final List<Playlist> _playlists = [];
  List<MediaFolder> _folders = [];
  List<Artist> _artists = [];
  List<Album> _albums = [];
  
  bool _isScanning = false;
  String? _scanError;
  MediaSortType _sortType = MediaSortType.title;
  bool _sortAscending = true;
  double _scanProgress = 0.0;

  List<MediaFile> get allMedia => _allMedia;
  List<MediaFile> get audioFiles => _audioFiles;
  List<MediaFile> get videoFiles => _videoFiles;
  List<Playlist> get playlists => _playlists;
  List<MediaFolder> get folders => _folders;
  List<Artist> get artists => _artists;
  List<Album> get albums => _albums;
  
  bool get isScanning => _isScanning;
  String? get scanError => _scanError;
  MediaSortType get sortType => _sortType;
  bool get sortAscending => _sortAscending;
  double get scanProgress => _scanProgress;

  List<MediaFile> get favorites => _allMedia.where((m) => m.isFavorite).toList();
  List<MediaFile> get recentlyPlayed => _allMedia
      .where((m) => m.lastPlayedAt != null)
      .toList()
    ..sort((a, b) => b.lastPlayedAt!.compareTo(a.lastPlayedAt!));

  Future<void> scanMedia() async {
    _isScanning = true;
    _scanError = null;
    _scanProgress = 0.0;
    notifyListeners();

    try {
      debugPrint('[MediaLibraryProvider] Starting media scan...');
      
      final List<MediaFile> scannedMedia = [];
      
      _scanProgress = 0.2;
      notifyListeners();
      
      debugPrint('[MediaLibraryProvider] Scanning audio files...');
      final audioFiles = await _mediaScanner.scanAudioFiles();
      debugPrint('[MediaLibraryProvider] Found ${audioFiles.length} audio files');
      scannedMedia.addAll(audioFiles);
      
      _scanProgress = 0.5;
      notifyListeners();
      
      debugPrint('[MediaLibraryProvider] Scanning video files...');
      final videoFiles = await _mediaScanner.scanVideoFiles();
      debugPrint('[MediaLibraryProvider] Found ${videoFiles.length} video files');
      scannedMedia.addAll(videoFiles);
      
      _scanProgress = 0.8;
      notifyListeners();
      
      if (scannedMedia.isEmpty) {
        debugPrint('[MediaLibraryProvider] No media found via MediaStore, trying fallback scan...');
        await scanMediaFallback();
        return;
      }
      
      _allMedia = scannedMedia;
      _audioFiles = scannedMedia.where((m) => m.isAudio).toList();
      _videoFiles = scannedMedia.where((m) => m.isVideo).toList();
      
      _organizeMedia();
      _sortMedia();
      
      _scanProgress = 1.0;
      _isScanning = false;
      _scanError = null;
      
      debugPrint('[MediaLibraryProvider] Scan complete. Total: ${_allMedia.length}, Audio: ${_audioFiles.length}, Video: ${_videoFiles.length}');
      notifyListeners();
    } catch (e) {
      _isScanning = false;
      _scanError = e.toString();
      debugPrint('[MediaLibraryProvider] Scan error: $e');
      notifyListeners();
    }
  }

  Future<void> scanMediaFallback() async {
    debugPrint('[MediaLibraryProvider] Starting fallback file system scan...');
    
    _scanProgress = 0.0;
    notifyListeners();

    try {
      final List<MediaFile> scannedMedia = [];
      
      final audioExtensions = ['.mp3', '.m4a', '.wav', '.flac', '.aac', '.ogg', '.wma'];
      final videoExtensions = ['.mp4', '.mkv', '.avi', '.mov', '.wmv', '.flv', '.webm'];
      
      final directories = await _getMediaDirectories();
      debugPrint('[MediaLibraryProvider] Scanning ${directories.length} directories');
      
      int totalDirs = directories.length;
      int processedDirs = 0;
      
      for (final dir in directories) {
        if (await dir.exists()) {
          debugPrint('[MediaLibraryProvider] Scanning directory: ${dir.path}');
          try {
            await for (final entity in dir.list(recursive: true)) {
              if (entity is File) {
                final path = entity.path.toLowerCase();
                final isAudio = audioExtensions.any((ext) => path.endsWith(ext));
                final isVideo = videoExtensions.any((ext) => path.endsWith(ext));
                
                if (isAudio || isVideo) {
                  final mediaFile = await _createMediaFile(entity, isAudio);
                  scannedMedia.add(mediaFile);
                }
              }
            }
          } catch (e) {
            debugPrint('[MediaLibraryProvider] Error scanning directory ${dir.path}: $e');
          }
        }
        processedDirs++;
        _scanProgress = 0.5 + (processedDirs / totalDirs) * 0.4;
        notifyListeners();
      }

      _allMedia = scannedMedia;
      _audioFiles = scannedMedia.where((m) => m.isAudio).toList();
      _videoFiles = scannedMedia.where((m) => m.isVideo).toList();
      
      _organizeMedia();
      _sortMedia();
      
      _scanProgress = 1.0;
      _isScanning = false;
      _scanError = null;
      
      debugPrint('[MediaLibraryProvider] Fallback scan complete. Total: ${_allMedia.length}, Audio: ${_audioFiles.length}, Video: ${_videoFiles.length}');
      notifyListeners();
    } catch (e) {
      _isScanning = false;
      _scanError = e.toString();
      debugPrint('[MediaLibraryProvider] Fallback scan error: $e');
      notifyListeners();
    }
  }

  Future<List<Directory>> _getMediaDirectories() async {
    final directories = <Directory>[];
    
    if (Platform.isAndroid) {
      directories.add(Directory('/storage/emulated/0/Music'));
      directories.add(Directory('/storage/emulated/0/Download'));
      directories.add(Directory('/storage/emulated/0/Movies'));
      directories.add(Directory('/storage/emulated/0/DCIM'));
      directories.add(Directory('/storage/emulated/0/Video'));
      directories.add(Directory('/storage/emulated/0/Notifications'));
      directories.add(Directory('/storage/emulated/0/Ringtones'));
      directories.add(Directory('/storage/emulated/0/Alarms'));
      directories.add(Directory('/storage/emulated/0/Podcasts'));
      
      try {
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          directories.add(externalDir);
        }
      } catch (e) {
        debugPrint('[MediaLibraryProvider] Error getting external storage directory: $e');
      }
    }
    
    return directories;
  }

  Future<MediaFile> _createMediaFile(File file, bool isAudio) async {
    final stat = await file.stat();
    final fileName = file.path.split('/').last.split('\\').last;
    final title = fileName.replaceAll(RegExp(r'\.[^.]+$'), '');
    final extension = fileName.split('.').last.toLowerCase();
    
    return MediaFile(
      id: const Uuid().v4(),
      path: file.path,
      title: title,
      type: isAudio ? MediaType.audio : MediaType.video,
      duration: 0,
      size: stat.size,
      format: extension,
      dateAdded: stat.changed,
      dateModified: stat.modified,
    );
  }

  void _organizeMedia() {
    _folders = _organizeByFolder();
    _artists = _organizeByArtist();
    _albums = _organizeByAlbum();
  }

  List<MediaFolder> _organizeByFolder() {
    final folderMap = <String, List<MediaFile>>{};
    
    for (final media in _allMedia) {
      final separator = media.path.contains('\\') ? '\\' : '/';
      final lastSep = media.path.lastIndexOf(separator);
      final dir = lastSep > 0 ? media.path.substring(0, lastSep) : media.path;
      folderMap.putIfAbsent(dir, () => []).add(media);
    }
    
    return folderMap.entries.map((entry) {
      final name = entry.key.split(entry.key.contains('\\') ? '\\' : '/').last;
      final mediaType = entry.value.first.type;
      return MediaFolder(
        path: entry.key,
        name: name,
        mediaFiles: entry.value,
        mediaType: mediaType,
      );
    }).toList();
  }

  List<Artist> _organizeByArtist() {
    final artistMap = <String, List<MediaFile>>{};
    
    for (final media in _audioFiles) {
      final artist = media.artist.isNotEmpty ? media.artist : '未知艺术家';
      artistMap.putIfAbsent(artist, () => []).add(media);
    }
    
    return artistMap.entries.map((entry) {
      return Artist(
        name: entry.key,
        mediaFiles: entry.value,
      );
    }).toList();
  }

  List<Album> _organizeByAlbum() {
    final albumMap = <String, List<MediaFile>>{};
    
    for (final media in _audioFiles) {
      final albumKey = '${media.album}_${media.artist}';
      albumMap.putIfAbsent(albumKey, () => []).add(media);
    }
    
    return albumMap.entries.map((entry) {
      final firstMedia = entry.value.first;
      return Album(
        name: firstMedia.album.isNotEmpty ? firstMedia.album : '未知专辑',
        artist: firstMedia.artist,
        mediaFiles: entry.value,
        albumArtPath: firstMedia.albumArtPath,
      );
    }).toList();
  }

  void setSortType(MediaSortType sortType) {
    if (_sortType == sortType) {
      _sortAscending = !_sortAscending;
    } else {
      _sortType = sortType;
      _sortAscending = true;
    }
    _sortMedia();
    notifyListeners();
  }

  void _sortMedia() {
    int compare(MediaFile a, MediaFile b) {
      int result;
      switch (_sortType) {
        case MediaSortType.title:
          result = a.displayTitle.compareTo(b.displayTitle);
          break;
        case MediaSortType.artist:
          result = a.displayArtist.compareTo(b.displayArtist);
          break;
        case MediaSortType.album:
          result = a.displayAlbum.compareTo(b.displayAlbum);
          break;
        case MediaSortType.dateAdded:
          result = a.dateAdded.compareTo(b.dateAdded);
          break;
        case MediaSortType.dateModified:
          result = a.dateModified.compareTo(b.dateModified);
          break;
        case MediaSortType.duration:
          result = a.duration.compareTo(b.duration);
          break;
        case MediaSortType.size:
          result = a.size.compareTo(b.size);
          break;
      }
      return _sortAscending ? result : -result;
    }

    _allMedia.sort(compare);
    _audioFiles.sort(compare);
    _videoFiles.sort(compare);
  }

  void toggleFavorite(String mediaId) {
    final index = _allMedia.indexWhere((m) => m.id == mediaId);
    if (index != -1) {
      final media = _allMedia[index];
      _allMedia[index] = media.copyWith(isFavorite: !media.isFavorite);
      
      final audioIndex = _audioFiles.indexWhere((m) => m.id == mediaId);
      if (audioIndex != -1) {
        _audioFiles[audioIndex] = _allMedia[index];
      }
      
      final videoIndex = _videoFiles.indexWhere((m) => m.id == mediaId);
      if (videoIndex != -1) {
        _videoFiles[videoIndex] = _allMedia[index];
      }
      
      notifyListeners();
    }
  }

  Future<void> createPlaylist(String name, {String? description}) async {
    final playlist = Playlist(
      id: const Uuid().v4(),
      name: name,
      description: description,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _playlists.add(playlist);
    notifyListeners();
  }

  Future<void> addToPlaylist(String playlistId, String mediaId) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      final playlist = _playlists[index];
      if (!playlist.mediaIds.contains(mediaId)) {
        _playlists[index] = playlist.copyWith(
          mediaIds: [...playlist.mediaIds, mediaId],
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }
    }
  }

  Future<void> removeFromPlaylist(String playlistId, String mediaId) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      final playlist = _playlists[index];
      _playlists[index] = playlist.copyWith(
        mediaIds: playlist.mediaIds.where((id) => id != mediaId).toList(),
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  Future<void> deletePlaylist(String playlistId) async {
    _playlists.removeWhere((p) => p.id == playlistId);
    notifyListeners();
  }

  PlaylistWithMedia? getPlaylistWithMedia(String playlistId) {
    final playlist = _playlists.where((p) => p.id == playlistId).firstOrNull;
    if (playlist == null) return null;
    
    final mediaFiles = playlist.mediaIds
        .map((id) => _allMedia.where((m) => m.id == id).firstOrNull)
        .whereType<MediaFile>()
        .toList();
    
    return PlaylistWithMedia(playlist: playlist, mediaFiles: mediaFiles);
  }

  List<MediaFile> searchMedia(String query) {
    if (query.isEmpty) return [];
    final lowerQuery = query.toLowerCase();
    return _allMedia.where((media) {
      return media.title.toLowerCase().contains(lowerQuery) ||
          media.artist.toLowerCase().contains(lowerQuery) ||
          media.album.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  void updateMediaPlayInfo(String mediaId) {
    final index = _allMedia.indexWhere((m) => m.id == mediaId);
    if (index != -1) {
      final media = _allMedia[index];
      _allMedia[index] = media.copyWith(
        playCount: media.playCount + 1,
        lastPlayedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }
}
