import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/media_file.dart';
import '../../../providers/theme_provider.dart';

class VideoPlayerScreen extends StatefulWidget {
  final MediaFile media;

  const VideoPlayerScreen({super.key, required this.media});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final Player _player;
  late final VideoController _controller;
  bool _controlsVisible = true;
  bool _isInitialized = false;
  bool _isLocked = false;
  double _speed = 1.0;
  double _volume = 1.0;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _controller = VideoController(_player);
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      await _player.open(Media(widget.media.path));
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
      _player.stream.position.listen((position) {
        if (mounted) setState(() {});
      });
      _player.stream.playing.listen((playing) {
        if (mounted) setState(() {});
      });
    } catch (e) {
      debugPrint('Error initializing video player: $e');
    }
  }

  @override
  void dispose() {
    _player.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void _toggleControls() {
    if (!_isLocked) {
      setState(() {
        _controlsVisible = !_controlsVisible;
      });
    }
  }

  void _toggleLock() {
    setState(() {
      _isLocked = !_isLocked;
      if (_isLocked) {
        _controlsVisible = false;
      } else {
        _controlsVisible = true;
      }
    });
  }

  void _toggleFullScreen() {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    
    if (isPortrait) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  void _seekRelative(Duration offset) {
    final newPosition = _player.state.position + offset;
    final duration = _player.state.duration;
    final clampedPosition = Duration(
      milliseconds: newPosition.inMilliseconds.clamp(0, duration.inMilliseconds),
    );
    _player.seek(clampedPosition);
    setState(() {});
  }

  void _showSpeedDialog() {
    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.playbackSpeed,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: speeds.map((speed) {
                final isSelected = speed == _speed;
                return InkWell(
                  onTap: () {
                    _player.setRate(speed);
                    setState(() => _speed = speed);
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${speed}x',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontWeight: isSelected ? FontWeight.w600 : null,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showVolumeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('音量', style: TextStyle(color: Colors.white)),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.volume_down, color: Colors.white),
                    Expanded(
                      child: Slider(
                        value: _volume,
                        min: 0,
                        max: 1,
                        activeColor: Theme.of(context).colorScheme.primary,
                        onChanged: (value) {
                          _player.setVolume(value);
                          setState(() => _volume = value);
                          this.setState(() => _volume = value);
                        },
                      ),
                    ),
                    const Icon(Icons.volume_up, color: Colors.white),
                  ],
                ),
                Text('${(_volume * 100).toInt()}%', style: const TextStyle(color: Colors.white)),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.speed, color: themeProvider.primaryColor),
                  title: const Text('播放速度', style: TextStyle(color: Colors.white)),
                  trailing: Text('${_speed}x', style: const TextStyle(color: Colors.white70)),
                  onTap: () {
                    Navigator.pop(context);
                    _showSpeedDialog();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.volume_up, color: themeProvider.primaryColor),
                  title: const Text('音量调节', style: TextStyle(color: Colors.white)),
                  trailing: Text('${(_volume * 100).toInt()}%', style: const TextStyle(color: Colors.white70)),
                  onTap: () {
                    Navigator.pop(context);
                    _showVolumeDialog();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.info_outline, color: themeProvider.primaryColor),
                  title: const Text(AppStrings.info, style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    _showMediaInfo();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showMediaInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(widget.media.displayTitle, style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('时长', widget.media.durationFormatted),
            _buildInfoRow('大小', widget.media.sizeFormatted),
            if (widget.media.format != null) _buildInfoRow('格式', widget.media.format!),
            _buildInfoRow('路径', widget.media.path, maxLines: 2),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _toggleControls,
            onDoubleTap: () {
              if (!_isLocked) {
                if (_player.state.playing) {
                  _player.pause();
                } else {
                  _player.play();
                }
              }
            },
            onHorizontalDragEnd: (details) {
              if (!_isLocked) {
                if (details.primaryVelocity! > 0) {
                  _seekRelative(const Duration(seconds: -10));
                } else {
                  _seekRelative(const Duration(seconds: 10));
                }
              }
            },
            child: Center(
              child: _isInitialized
                  ? Video(controller: _controller)
                  : const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
            ),
          ),
          if (_controlsVisible && !_isLocked) _buildControls(),
          if (_isLocked) _buildLockOverlay(),
        ],
      ),
    );
  }

  Widget _buildLockOverlay() {
    return Positioned(
      left: 16,
      top: MediaQuery.of(context).size.height / 2 - 28,
      child: SafeArea(
        child: IconButton(
          onPressed: _toggleLock,
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.lock, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.7),
              Colors.transparent,
              Colors.transparent,
              Colors.black.withValues(alpha: 0.7),
            ],
            stops: const [0.0, 0.2, 0.8, 1.0],
          ),
        ),
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _toggleControls,
                child: _buildCenterControls(),
              ),
            ),
            _buildProgressBar(),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            Expanded(
              child: Text(
                widget.media.displayTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              onPressed: _showVolumeDialog,
              icon: Icon(
                _volume == 0 ? Icons.volume_off : Icons.volume_up,
                color: Colors.white,
              ),
            ),
            IconButton(
              onPressed: _showMoreOptions,
              icon: const Icon(Icons.more_vert, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () => _seekRelative(const Duration(seconds: -10)),
          icon: const Icon(Icons.replay_10, color: Colors.white, size: 36),
        ),
        const SizedBox(width: 32),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: () {
              if (_player.state.playing) {
                _player.pause();
              } else {
                _player.play();
              }
              setState(() {});
            },
            icon: Icon(
              _player.state.playing ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 36,
            ),
          ),
        ),
        const SizedBox(width: 32),
        IconButton(
          onPressed: () => _seekRelative(const Duration(seconds: 10)),
          icon: const Icon(Icons.forward_10, color: Colors.white, size: 36),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    final position = _player.state.position;
    final duration = _player.state.duration;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            ),
            child: Slider(
              value: duration.inMilliseconds > 0
                  ? position.inMilliseconds.toDouble().clamp(0, duration.inMilliseconds.toDouble())
                  : 0,
              min: 0,
              max: duration.inMilliseconds > 0 ? duration.inMilliseconds.toDouble() : 1,
              activeColor: Theme.of(context).colorScheme.primary,
              inactiveColor: Colors.white30,
              onChanged: (value) {
                _player.seek(Duration(milliseconds: value.toInt()));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(position),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                Text(
                  _formatDuration(duration),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: _toggleLock,
              icon: const Icon(Icons.lock_open, color: Colors.white),
            ),
            IconButton(
              onPressed: () => _seekRelative(const Duration(minutes: -1)),
              icon: const Icon(Icons.fast_rewind, color: Colors.white, size: 28),
            ),
            IconButton(
              onPressed: () => _seekRelative(const Duration(minutes: 1)),
              icon: const Icon(Icons.fast_forward, color: Colors.white, size: 28),
            ),
            IconButton(
              onPressed: _showSpeedDialog,
              icon: Text(
                '${_speed}x',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              onPressed: _toggleFullScreen,
              icon: const Icon(Icons.fullscreen, color: Colors.white),
            ),
          ],
        ),
      ),
    );
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
}
