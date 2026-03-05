enum MediaType {
  audio,
  video,
}

enum MediaSortType {
  title,
  artist,
  album,
  dateAdded,
  dateModified,
  duration,
  size,
}

class MediaFile {
  final String id;
  final String path;
  final String title;
  final String artist;
  final String album;
  final String? albumArtPath;
  final MediaType type;
  final int duration;
  final int size;
  final int? bitrate;
  final int? sampleRate;
  final String? format;
  final DateTime dateAdded;
  final DateTime dateModified;
  final bool isFavorite;
  final int playCount;
  final DateTime? lastPlayedAt;

  const MediaFile({
    required this.id,
    required this.path,
    required this.title,
    this.artist = '',
    this.album = '',
    this.albumArtPath,
    required this.type,
    required this.duration,
    required this.size,
    this.bitrate,
    this.sampleRate,
    this.format,
    required this.dateAdded,
    required this.dateModified,
    this.isFavorite = false,
    this.playCount = 0,
    this.lastPlayedAt,
  });

  String get durationFormatted {
    final hours = duration ~/ 3600;
    final minutes = (duration % 3600) ~/ 60;
    final seconds = duration % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get sizeFormatted {
    if (size < 1024) {
      return '$size B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)} KB';
    } else if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  String get displayTitle {
    if (title.isNotEmpty) return title;
    final fileName = path.split('/').last.split('\\').last;
    return fileName.replaceAll(RegExp(r'\.[^.]+$'), '');
  }

  String get displayArtist {
    return artist.isNotEmpty ? artist : '未知艺术家';
  }

  String get displayAlbum {
    return album.isNotEmpty ? album : '未知专辑';
  }

  bool get isAudio => type == MediaType.audio;
  bool get isVideo => type == MediaType.video;

  MediaFile copyWith({
    String? id,
    String? path,
    String? title,
    String? artist,
    String? album,
    String? albumArtPath,
    MediaType? type,
    int? duration,
    int? size,
    int? bitrate,
    int? sampleRate,
    String? format,
    DateTime? dateAdded,
    DateTime? dateModified,
    bool? isFavorite,
    int? playCount,
    DateTime? lastPlayedAt,
  }) {
    return MediaFile(
      id: id ?? this.id,
      path: path ?? this.path,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      albumArtPath: albumArtPath ?? this.albumArtPath,
      type: type ?? this.type,
      duration: duration ?? this.duration,
      size: size ?? this.size,
      bitrate: bitrate ?? this.bitrate,
      sampleRate: sampleRate ?? this.sampleRate,
      format: format ?? this.format,
      dateAdded: dateAdded ?? this.dateAdded,
      dateModified: dateModified ?? this.dateModified,
      isFavorite: isFavorite ?? this.isFavorite,
      playCount: playCount ?? this.playCount,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'path': path,
      'title': title,
      'artist': artist,
      'album': album,
      'albumArtPath': albumArtPath,
      'type': type.index,
      'duration': duration,
      'size': size,
      'bitrate': bitrate,
      'sampleRate': sampleRate,
      'format': format,
      'dateAdded': dateAdded.toIso8601String(),
      'dateModified': dateModified.toIso8601String(),
      'isFavorite': isFavorite ? 1 : 0,
      'playCount': playCount,
      'lastPlayedAt': lastPlayedAt?.toIso8601String(),
    };
  }

  factory MediaFile.fromMap(Map<String, dynamic> map) {
    return MediaFile(
      id: map['id'] as String,
      path: map['path'] as String,
      title: map['title'] as String? ?? '',
      artist: map['artist'] as String? ?? '',
      album: map['album'] as String? ?? '',
      albumArtPath: map['albumArtPath'] as String?,
      type: MediaType.values[map['type'] as int],
      duration: map['duration'] as int,
      size: map['size'] as int,
      bitrate: map['bitrate'] as int?,
      sampleRate: map['sampleRate'] as int?,
      format: map['format'] as String?,
      dateAdded: DateTime.parse(map['dateAdded'] as String),
      dateModified: DateTime.parse(map['dateModified'] as String),
      isFavorite: map['isFavorite'] == 1,
      playCount: map['playCount'] as int? ?? 0,
      lastPlayedAt: map['lastPlayedAt'] != null
          ? DateTime.parse(map['lastPlayedAt'] as String)
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MediaFile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
