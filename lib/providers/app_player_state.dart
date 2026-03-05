import '../data/models/media_file.dart';
import '../core/constants/playback_state.dart';

class AppPlayerState {
  final MediaFile? currentMedia;
  final PlaybackState playbackState;
  final Duration position;
  final Duration duration;
  final Duration bufferedPosition;
  final double speed;
  final double volume;
  final RepeatMode repeatMode;
  final ShuffleMode shuffleMode;
  final List<MediaFile> playlist;
  final int currentIndex;
  final bool isFullScreen;
  final String? errorMessage;

  const AppPlayerState({
    this.currentMedia,
    this.playbackState = PlaybackState.stopped,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.bufferedPosition = Duration.zero,
    this.speed = 1.0,
    this.volume = 1.0,
    this.repeatMode = RepeatMode.off,
    this.shuffleMode = ShuffleMode.off,
    this.playlist = const [],
    this.currentIndex = -1,
    this.isFullScreen = false,
    this.errorMessage,
  });

  bool get isPlaying => playbackState.isPlaying;
  bool get isPaused => playbackState.isPaused;
  bool get isStopped => playbackState.isStopped;
  bool get isBuffering => playbackState.isBuffering;
  bool get hasError => playbackState.hasError;

  double get progress {
    if (duration.inMilliseconds == 0) return 0;
    return position.inMilliseconds / duration.inMilliseconds;
  }

  double get bufferedProgress {
    if (duration.inMilliseconds == 0) return 0;
    return bufferedPosition.inMilliseconds / duration.inMilliseconds;
  }

  bool get hasNext {
    if (playlist.isEmpty) return false;
    if (shuffleMode == ShuffleMode.on) return true;
    return currentIndex < playlist.length - 1;
  }

  bool get hasPrevious {
    if (playlist.isEmpty) return false;
    if (shuffleMode == ShuffleMode.on) return true;
    return currentIndex > 0;
  }

  String get positionFormatted {
    return _formatDuration(position);
  }

  String get durationFormatted {
    return _formatDuration(duration);
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  AppPlayerState copyWith({
    MediaFile? currentMedia,
    PlaybackState? playbackState,
    Duration? position,
    Duration? duration,
    Duration? bufferedPosition,
    double? speed,
    double? volume,
    RepeatMode? repeatMode,
    ShuffleMode? shuffleMode,
    List<MediaFile>? playlist,
    int? currentIndex,
    bool? isFullScreen,
    String? errorMessage,
    bool clearError = false,
    bool clearMedia = false,
  }) {
    return AppPlayerState(
      currentMedia: clearMedia ? null : (currentMedia ?? this.currentMedia),
      playbackState: playbackState ?? this.playbackState,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      bufferedPosition: bufferedPosition ?? this.bufferedPosition,
      speed: speed ?? this.speed,
      volume: volume ?? this.volume,
      repeatMode: repeatMode ?? this.repeatMode,
      shuffleMode: shuffleMode ?? this.shuffleMode,
      playlist: playlist ?? this.playlist,
      currentIndex: currentIndex ?? this.currentIndex,
      isFullScreen: isFullScreen ?? this.isFullScreen,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  String toString() {
    return 'AppPlayerState(currentMedia: $currentMedia, playbackState: $playbackState, position: $position, duration: $duration)';
  }
}
