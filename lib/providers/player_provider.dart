import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../data/models/media_file.dart';
import 'app_player_state.dart';
import '../core/constants/playback_state.dart';

class PlayerProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  AppPlayerState _state = const AppPlayerState();
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration>? _bufferedPositionSubscription;
  StreamSubscription<int?>? _currentIndexSubscription;

  AppPlayerState get state => _state;
  AudioPlayer get audioPlayer => _audioPlayer;

  PlayerProvider() {
    _initListeners();
  }

  void _initListeners() {
    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      _state = _state.copyWith(position: position);
      notifyListeners();
    });

    _durationSubscription = _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        _state = _state.copyWith(duration: duration);
        notifyListeners();
      }
    });

    _playerStateSubscription = _audioPlayer.playerStateStream.listen((playerState) {
      final playbackState = _mapPlaybackState(playerState);
      _state = _state.copyWith(playbackState: playbackState);
      notifyListeners();
    });

    _bufferedPositionSubscription = _audioPlayer.bufferedPositionStream.listen((position) {
      _state = _state.copyWith(bufferedPosition: position);
      notifyListeners();
    });

    _currentIndexSubscription = _audioPlayer.currentIndexStream.listen((index) {
      if (index != null && index != _state.currentIndex) {
        _state = _state.copyWith(currentIndex: index);
        notifyListeners();
      }
    });
  }

  PlaybackState _mapPlaybackState(PlayerState playerState) {
    if (playerState.playing) {
      return PlaybackState.playing;
    } else if (playerState.processingState == ProcessingState.buffering) {
      return PlaybackState.buffering;
    } else if (playerState.processingState == ProcessingState.completed) {
      return PlaybackState.stopped;
    } else if (playerState.processingState == ProcessingState.idle) {
      return PlaybackState.stopped;
    } else {
      return PlaybackState.paused;
    }
  }

  Future<void> play(MediaFile media, {List<MediaFile>? playlist, int? index}) async {
    try {
      _state = _state.copyWith(
        playbackState: PlaybackState.buffering,
        clearError: true,
      );
      notifyListeners();

      await _audioPlayer.setFilePath(media.path);
      
      if (playlist != null) {
        _state = _state.copyWith(
          currentMedia: media,
          playlist: playlist,
          currentIndex: index ?? playlist.indexOf(media),
          playbackState: PlaybackState.playing,
        );
      } else {
        _state = _state.copyWith(
          currentMedia: media,
          playlist: [media],
          currentIndex: 0,
          playbackState: PlaybackState.playing,
        );
      }

      await _audioPlayer.play();
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(
        playbackState: PlaybackState.error,
        errorMessage: e.toString(),
      );
      notifyListeners();
    }
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
    _state = _state.copyWith(playbackState: PlaybackState.paused);
    notifyListeners();
  }

  Future<void> resume() async {
    await _audioPlayer.play();
    _state = _state.copyWith(playbackState: PlaybackState.playing);
    notifyListeners();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    _state = _state.copyWith(
      playbackState: PlaybackState.stopped,
      position: Duration.zero,
    );
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
    _state = _state.copyWith(position: position);
    notifyListeners();
  }

  Future<void> seekRelative(Duration offset) async {
    final newPosition = _state.position + offset;
    await seek(newPosition);
  }

  Future<void> setSpeed(double speed) async {
    await _audioPlayer.setSpeed(speed);
    _state = _state.copyWith(speed: speed);
    notifyListeners();
  }

  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume);
    _state = _state.copyWith(volume: volume);
    notifyListeners();
  }

  void toggleRepeatMode() {
    _state = _state.copyWith(repeatMode: _state.repeatMode.next);
    notifyListeners();
  }

  void toggleShuffleMode() {
    _state = _state.copyWith(shuffleMode: _state.shuffleMode.toggle);
    notifyListeners();
  }

  Future<void> playNext() async {
    if (!_state.hasNext) return;

    int nextIndex;
    if (_state.shuffleMode == ShuffleMode.on) {
      final random = Random();
      nextIndex = random.nextInt(_state.playlist.length);
    } else {
      nextIndex = _state.currentIndex + 1;
    }

    final nextMedia = _state.playlist[nextIndex];
    await play(nextMedia, playlist: _state.playlist, index: nextIndex);
  }

  Future<void> playPrevious() async {
    if (!_state.hasPrevious) return;

    int prevIndex;
    if (_state.shuffleMode == ShuffleMode.on) {
      final random = Random();
      prevIndex = random.nextInt(_state.playlist.length);
    } else {
      prevIndex = _state.currentIndex - 1;
    }

    final prevMedia = _state.playlist[prevIndex];
    await play(prevMedia, playlist: _state.playlist, index: prevIndex);
  }

  Future<void> playAtIndex(int index) async {
    if (index < 0 || index >= _state.playlist.length) return;
    final media = _state.playlist[index];
    await play(media, playlist: _state.playlist, index: index);
  }

  void toggleFullScreen() {
    _state = _state.copyWith(isFullScreen: !_state.isFullScreen);
    notifyListeners();
  }

  void setFullScreen(bool isFullScreen) {
    _state = _state.copyWith(isFullScreen: isFullScreen);
    notifyListeners();
  }

  void addToQueue(MediaFile media) {
    _state = _state.copyWith(playlist: [..._state.playlist, media]);
    notifyListeners();
  }

  void removeFromQueue(int index) {
    if (index < 0 || index >= _state.playlist.length) return;
    final newPlaylist = List<MediaFile>.from(_state.playlist)..removeAt(index);
    
    int newIndex = _state.currentIndex;
    if (index < _state.currentIndex) {
      newIndex--;
    } else if (index == _state.currentIndex) {
      if (newPlaylist.isEmpty) {
        stop();
        return;
      }
      newIndex = newIndex.clamp(0, newPlaylist.length - 1);
    }
    
    _state = _state.copyWith(
      playlist: newPlaylist,
      currentIndex: newIndex,
    );
    notifyListeners();
  }

  void clearQueue() {
    stop();
    _state = _state.copyWith(
      playlist: [],
      currentIndex: -1,
      clearMedia: true,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _bufferedPositionSubscription?.cancel();
    _currentIndexSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}
