import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/playback_state.dart';
import '../../../data/models/media_file.dart';
import '../../../providers/player_provider.dart';
import '../../../providers/media_library_provider.dart';
import '../../../providers/app_player_state.dart';
import '../../../providers/theme_provider.dart';

class AudioPlayerScreen extends StatefulWidget {
  final MediaFile media;

  const AudioPlayerScreen({super.key, required this.media});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  bool _showLyrics = false;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: Consumer<PlayerProvider>(
            builder: (context, playerProvider, child) {
              final state = playerProvider.state;
              final currentMedia = state.currentMedia ?? widget.media;

              if (state.isPlaying) {
                _rotationController.repeat();
              } else {
                _rotationController.stop();
              }

              return Column(
                children: [
                  _buildHeader(context, currentMedia),
                  Expanded(
                    child: _showLyrics
                        ? _buildLyricsView(context)
                        : _buildAlbumArt(context, currentMedia),
                  ),
                  _buildMediaInfo(context, currentMedia),
                  _buildProgressSlider(context, state),
                  _buildControls(context, playerProvider, state),
                  _buildBottomActions(context),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, MediaFile media) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.keyboard_arrow_down),
            iconSize: 32,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  AppStrings.nowPlaying,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  media.displayTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showMediaOptions(context, media),
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumArt(BuildContext context, MediaFile media) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Center(
          child: AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationController.value * 2 * 3.14159,
                child: child,
              );
            },
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [themeProvider.primaryColor, themeProvider.accentColor],
                ),
                boxShadow: [
                  BoxShadow(
                    color: themeProvider.primaryColor.withValues(alpha: 0.4),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: media.albumArtPath != null && File(media.albumArtPath!).existsSync()
                          ? Image.file(
                              File(media.albumArtPath!),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildDefaultAlbumArt(themeProvider),
                            )
                          : _buildDefaultAlbumArt(themeProvider),
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).scaffoldBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.music_note,
                      color: themeProvider.primaryColor,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDefaultAlbumArt(ThemeProvider themeProvider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            themeProvider.primaryColor.withValues(alpha: 0.8),
            themeProvider.accentColor.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.music_note,
          color: Colors.white,
          size: 80,
        ),
      ),
    );
  }

  Widget _buildLyricsView(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lyrics,
              size: 64,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            const SizedBox(height: 16),
            Text(
              '暂无歌词',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaInfo(BuildContext context, MediaFile media) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Column(
        children: [
          Text(
            media.displayTitle,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            media.displayArtist,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSlider(BuildContext context, AppPlayerState state) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                ),
                child: Slider(
                  value: state.duration.inMilliseconds > 0
                      ? state.position.inMilliseconds.toDouble()
                      : 0,
                  min: 0,
                  max: state.duration.inMilliseconds.toDouble(),
                  activeColor: themeProvider.primaryColor,
                  inactiveColor: Theme.of(context).dividerColor,
                  onChanged: (value) {
                    context.read<PlayerProvider>().seek(
                          Duration(milliseconds: value.toInt()),
                        );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      state.positionFormatted,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      state.durationFormatted,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControls(BuildContext context, PlayerProvider playerProvider, AppPlayerState state) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                context: context,
                themeProvider: themeProvider,
                icon: Icons.shuffle,
                isActive: state.shuffleMode == ShuffleMode.on,
                onPressed: () => playerProvider.toggleShuffleMode(),
                size: 24,
              ),
              _buildControlButton(
                context: context,
                themeProvider: themeProvider,
                icon: Icons.skip_previous,
                onPressed: state.hasPrevious
                    ? () => playerProvider.playPrevious()
                    : null,
                size: 36,
              ),
              _buildPlayButton(context, playerProvider, state, themeProvider),
              _buildControlButton(
                context: context,
                themeProvider: themeProvider,
                icon: Icons.skip_next,
                onPressed: state.hasNext
                    ? () => playerProvider.playNext()
                    : null,
                size: 36,
              ),
              _buildControlButton(
                context: context,
                themeProvider: themeProvider,
                icon: state.repeatMode.icon,
                isActive: state.repeatMode != RepeatMode.off,
                onPressed: () => playerProvider.toggleRepeatMode(),
                size: 24,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlayButton(BuildContext context, PlayerProvider playerProvider, AppPlayerState state, ThemeProvider themeProvider) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [themeProvider.primaryColor, themeProvider.accentColor],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: themeProvider.primaryColor.withValues(alpha: 0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (state.isPlaying) {
              playerProvider.pause();
            } else {
              playerProvider.resume();
            }
          },
          customBorder: const CircleBorder(),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                state.isPlaying ? Icons.pause : Icons.play_arrow,
                key: ValueKey(state.isPlaying),
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required BuildContext context,
    required ThemeProvider themeProvider,
    required IconData icon,
    VoidCallback? onPressed,
    bool isActive = false,
    double size = 24,
  }) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final disabledColor = Theme.of(context).textTheme.bodySmall?.color;
    
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: size,
        color: onPressed == null
            ? disabledColor?.withValues(alpha: 0.5)
            : isActive
                ? themeProvider.primaryColor
                : textColor,
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            context: context,
            icon: Icons.favorite_border,
            label: '收藏',
            onTap: () {
              final media = context.read<PlayerProvider>().state.currentMedia;
              if (media != null) {
                context.read<MediaLibraryProvider>().toggleFavorite(media.id);
              }
            },
          ),
          _buildActionButton(
            context: context,
            icon: Icons.playlist_play,
            label: '播放列表',
            onTap: () => _showPlaylist(context),
          ),
          _buildActionButton(
            context: context,
            icon: Icons.speed,
            label: '速度',
            onTap: () => _showSpeedDialog(context),
          ),
          _buildActionButton(
            context: context,
            icon: _showLyrics ? Icons.lyrics : Icons.lyrics_outlined,
            label: '歌词',
            onTap: () {
              setState(() {
                _showLyrics = !_showLyrics;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    final textColor = Theme.of(context).textTheme.bodySmall?.color;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: textColor, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMediaOptions(BuildContext context, MediaFile media) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
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
                  leading: Icon(Icons.favorite_border, color: themeProvider.accentColor),
                  title: const Text(AppStrings.addToFavorites),
                  onTap: () {
                    context.read<MediaLibraryProvider>().toggleFavorite(media.id);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.share, color: themeProvider.primaryColor),
                  title: const Text(AppStrings.share),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline, color: Colors.blue),
                  title: const Text(AppStrings.info),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showPlaylist(BuildContext context) {
    final playerProvider = context.read<PlayerProvider>();
    final playlist = playerProvider.state.playlist;
    final currentIndex = playerProvider.state.currentIndex;

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '播放列表 (${playlist.length})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: ListView.builder(
                    itemCount: playlist.length,
                    itemBuilder: (context, index) {
                      final media = playlist[index];
                      final isPlaying = index == currentIndex;
                      return ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isPlaying ? themeProvider.primaryColor : Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isPlaying ? Icons.play_arrow : Icons.music_note,
                            color: isPlaying ? Colors.white : Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                        title: Text(
                          media.displayTitle,
                          style: TextStyle(
                            color: isPlaying ? themeProvider.primaryColor : null,
                            fontWeight: isPlaying ? FontWeight.w600 : null,
                          ),
                        ),
                        subtitle: Text(media.displayArtist),
                        onTap: () {
                          playerProvider.playAtIndex(index);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSpeedDialog(BuildContext context) {
    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
    final currentSpeed = context.read<PlayerProvider>().state.speed;

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.playbackSpeed,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: speeds.map((speed) {
                    final isSelected = speed == currentSpeed;
                    return InkWell(
                      onTap: () {
                        context.read<PlayerProvider>().setSpeed(speed);
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? themeProvider.primaryColor : Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${speed}x',
                          style: TextStyle(
                            color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                            fontWeight: isSelected ? FontWeight.w600 : null,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
