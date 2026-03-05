import 'package:flutter/material.dart';

enum PlaybackState {
  stopped,
  playing,
  paused,
  buffering,
  error,
}

enum RepeatMode {
  off,
  all,
  one,
}

enum ShuffleMode {
  off,
  on,
}

extension PlaybackStateExtension on PlaybackState {
  bool get isPlaying => this == PlaybackState.playing;
  bool get isPaused => this == PlaybackState.paused;
  bool get isStopped => this == PlaybackState.stopped;
  bool get isBuffering => this == PlaybackState.buffering;
  bool get hasError => this == PlaybackState.error;
}

extension RepeatModeExtension on RepeatMode {
  RepeatMode get next {
    switch (this) {
      case RepeatMode.off:
        return RepeatMode.all;
      case RepeatMode.all:
        return RepeatMode.one;
      case RepeatMode.one:
        return RepeatMode.off;
    }
  }

  String get displayName {
    switch (this) {
      case RepeatMode.off:
        return '关闭循环';
      case RepeatMode.all:
        return '列表循环';
      case RepeatMode.one:
        return '单曲循环';
    }
  }

  IconData get icon {
    switch (this) {
      case RepeatMode.off:
        return Icons.repeat;
      case RepeatMode.all:
        return Icons.repeat;
      case RepeatMode.one:
        return Icons.repeat_one;
    }
  }
}

extension ShuffleModeExtension on ShuffleMode {
  ShuffleMode get toggle => this == ShuffleMode.off ? ShuffleMode.on : ShuffleMode.off;

  String get displayName {
    switch (this) {
      case ShuffleMode.off:
        return '顺序播放';
      case ShuffleMode.on:
        return '随机播放';
    }
  }
}
