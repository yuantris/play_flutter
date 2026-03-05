import 'media_file.dart';

class Playlist {
  final String id;
  final String name;
  final String? description;
  final String? coverPath;
  final List<String> mediaIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Playlist({
    required this.id,
    required this.name,
    this.description,
    this.coverPath,
    this.mediaIds = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  int get mediaCount => mediaIds.length;

  Playlist copyWith({
    String? id,
    String? name,
    String? description,
    String? coverPath,
    List<String>? mediaIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverPath: coverPath ?? this.coverPath,
      mediaIds: mediaIds ?? this.mediaIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'coverPath': coverPath,
      'mediaIds': mediaIds.join(','),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Playlist.fromMap(Map<String, dynamic> map) {
    return Playlist(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      coverPath: map['coverPath'] as String?,
      mediaIds: map['mediaIds'] != null && (map['mediaIds'] as String).isNotEmpty
          ? (map['mediaIds'] as String).split(',')
          : [],
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Playlist && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class PlaylistWithMedia {
  final Playlist playlist;
  final List<MediaFile> mediaFiles;

  const PlaylistWithMedia({
    required this.playlist,
    required this.mediaFiles,
  });
}
