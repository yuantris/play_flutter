import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/player_provider.dart';
import '../screens/player/audio_player_screen.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, playerProvider, child) {
        final state = playerProvider.state;
        final media = state.currentMedia;

        if (media == null || state.isStopped) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AudioPlayerScreen(media: media),
              ),
            );
          },
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.surfaceDark,
                  AppColors.cardDark,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildProgressBar(state),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        _buildThumbnail(media),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMediaInfo(context, media),
                        ),
                        _buildControls(context, playerProvider, state),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressBar(state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Container(
              height: 2,
              width: double.infinity,
              color: AppColors.progressBackground,
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              height: 2,
              width: constraints.maxWidth * state.progress,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildThumbnail(media) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: media.isAudio
              ? [AppColors.primary, AppColors.primaryDark]
              : [AppColors.accent, AppColors.accentDark],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        media.isAudio ? Icons.music_note : Icons.videocam,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Widget _buildMediaInfo(BuildContext context, media) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          media.displayTitle,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          media.displayArtist,
          style: Theme.of(context).textTheme.bodySmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildControls(BuildContext context, PlayerProvider playerProvider, state) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: state.hasPrevious
              ? () => playerProvider.playPrevious()
              : null,
          icon: const Icon(Icons.skip_previous),
          iconSize: 28,
          color: AppColors.textPrimaryDark,
        ),
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: () {
              if (state.isPlaying) {
                playerProvider.pause();
              } else {
                playerProvider.resume();
              }
            },
            icon: Icon(
              state.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            iconSize: 24,
          ),
        ),
        IconButton(
          onPressed: state.hasNext
              ? () => playerProvider.playNext()
              : null,
          icon: const Icon(Icons.skip_next),
          iconSize: 28,
          color: AppColors.textPrimaryDark,
        ),
      ],
    );
  }
}
