import 'media_file.dart';

class MediaFolder {
  final String path;
  final String name;
  final List<MediaFile> mediaFiles;
  final MediaType mediaType;

  const MediaFolder({
    required this.path,
    required this.name,
    required this.mediaFiles,
    required this.mediaType,
  });

  int get mediaCount => mediaFiles.length;

  int get totalDuration {
    return mediaFiles.fold(0, (sum, file) => sum + file.duration);
  }

  String get totalDurationFormatted {
    final duration = totalDuration;
    final hours = duration ~/ 3600;
    final minutes = (duration % 3600) ~/ 60;
    
    if (hours > 0) {
      return '$hours 小时 $minutes 分钟';
    }
    return '$minutes 分钟';
  }

  int get totalSize {
    return mediaFiles.fold(0, (sum, file) => sum + file.size);
  }

  String get totalSizeFormatted {
    final size = totalSize;
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

class Artist {
  final String name;
  final List<MediaFile> mediaFiles;
  final String? artistArtPath;

  const Artist({
    required this.name,
    required this.mediaFiles,
    this.artistArtPath,
  });

  int get trackCount => mediaFiles.length;

  int get albumCount {
    final albums = <String>{};
    for (final file in mediaFiles) {
      if (file.album.isNotEmpty) {
        albums.add(file.album);
      }
    }
    return albums.length;
  }

  int get totalDuration {
    return mediaFiles.fold(0, (sum, file) => sum + file.duration);
  }
}

class Album {
  final String name;
  final String artist;
  final List<MediaFile> mediaFiles;
  final String? albumArtPath;

  const Album({
    required this.name,
    required this.artist,
    required this.mediaFiles,
    this.albumArtPath,
  });

  int get trackCount => mediaFiles.length;

  int get totalDuration {
    return mediaFiles.fold(0, (sum, file) => sum + file.duration);
  }
}
