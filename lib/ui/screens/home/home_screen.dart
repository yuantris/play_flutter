import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/media_file.dart';
import '../../../providers/media_library_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/player_provider.dart';
import '../../../core/services/permission_service.dart';
import '../player/audio_player_screen.dart';
import '../player/video_player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _checkPermissionAndScan();
  }

  Future<void> _checkPermissionAndScan() async {
    final hasPermission = await checkAndRequestPermission(context);
    if (hasPermission && mounted) {
      final mediaLibrary = context.read<MediaLibraryProvider>();
      if (mediaLibrary.allMedia.isEmpty && !mediaLibrary.isScanning) {
        await mediaLibrary.scanMedia();
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAllMediaTab(),
                    _buildAudioTab(),
                    _buildVideoTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      themeProvider.primaryColor,
                      themeProvider.accentColor
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: themeProvider.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.play_circle_fill,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.appName,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    Text(
                      '综合媒体播放器',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showScanDialog(),
                icon: const Icon(Icons.refresh),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).cardColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabBar() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              gradient: LinearGradient(
                colors: [themeProvider.primaryColor, themeProvider.accentColor],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            indicatorPadding: const EdgeInsets.all(4),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelColor: Colors.white,
            unselectedLabelColor: Theme.of(context).textTheme.bodySmall?.color,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            tabs: const [
              Tab(text: AppStrings.all),
              Tab(text: AppStrings.audio),
              Tab(text: AppStrings.video),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAllMediaTab() {
    return Consumer<MediaLibraryProvider>(
      builder: (context, mediaLibrary, child) {
        if (mediaLibrary.isScanning) {
          return _buildScanningIndicator(mediaLibrary);
        }

        if (mediaLibrary.allMedia.isEmpty) {
          return _buildEmptyState();
        }

        return _buildMediaList(mediaLibrary.allMedia);
      },
    );
  }

  Widget _buildAudioTab() {
    return Consumer<MediaLibraryProvider>(
      builder: (context, mediaLibrary, child) {
        if (mediaLibrary.isScanning) {
          return _buildScanningIndicator(mediaLibrary);
        }

        if (mediaLibrary.audioFiles.isEmpty) {
          return _buildEmptyState(type: MediaType.audio);
        }

        return _buildMediaList(mediaLibrary.audioFiles);
      },
    );
  }

  Widget _buildVideoTab() {
    return Consumer<MediaLibraryProvider>(
      builder: (context, mediaLibrary, child) {
        if (mediaLibrary.isScanning) {
          return _buildScanningIndicator(mediaLibrary);
        }

        if (mediaLibrary.videoFiles.isEmpty) {
          return _buildEmptyState(type: MediaType.video);
        }

        return _buildMediaList(mediaLibrary.videoFiles);
      },
    );
  }

  Widget _buildScanningIndicator(MediaLibraryProvider mediaLibrary) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              value: mediaLibrary.scanProgress,
              backgroundColor: Theme.of(context).dividerColor,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            AppStrings.scanning,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '${(mediaLibrary.scanProgress * 100).toInt()}%',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({MediaType? type}) {
    String message = AppStrings.noMediaFound;
    IconData icon = Icons.library_music;

    if (type == MediaType.audio) {
      message = '暂无音频文件';
      icon = Icons.audiotrack;
    } else if (type == MediaType.video) {
      message = '暂无视频文件';
      icon = Icons.videocam;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              icon,
              size: 64,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.noMediaHint,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return ElevatedButton.icon(
                onPressed: () => _showScanDialog(),
                icon: const Icon(Icons.refresh),
                label: const Text(AppStrings.scanMedia),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeProvider.primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMediaList(List<MediaFile> mediaFiles) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mediaFiles.length,
      itemBuilder: (context, index) {
        final media = mediaFiles[index];
        return _MediaListItem(
          media: media,
          onTap: () => _playMedia(media, mediaFiles, index),
          onMoreTap: () => _showMediaOptions(media),
        );
      },
    );
  }

  void _playMedia(MediaFile media, List<MediaFile> playlist, int index) {
    final playerProvider = context.read<PlayerProvider>();
    playerProvider.play(media, playlist: playlist, index: index);

    if (media.isVideo) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPlayerScreen(media: media),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AudioPlayerScreen(media: media),
        ),
      );
    }
  }

  void _showMediaOptions(MediaFile media) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _MediaOptionsSheet(media: media),
    );
  }

  void _showScanDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text(AppStrings.scanMedia),
        content: const Text('确定要扫描本地媒体文件吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final hasPermission =
                      await checkAndRequestPermission(context);
                  if (hasPermission && context.mounted) {
                    context.read<MediaLibraryProvider>().scanMedia();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeProvider.primaryColor,
                ),
                child: const Text(AppStrings.confirm,
                    style: TextStyle(color: Colors.white)),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MediaListItem extends StatelessWidget {
  final MediaFile media;
  final VoidCallback onTap;
  final VoidCallback onMoreTap;

  const _MediaListItem({
    required this.media,
    required this.onTap,
    required this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    _buildMediaThumbnail(themeProvider),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            media.displayTitle,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            media.isAudio
                                ? '${media.displayArtist} · ${media.durationFormatted}'
                                : '${media.durationFormatted} · ${media.sizeFormatted}',
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: onMoreTap,
                      icon: const Icon(Icons.more_vert),
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMediaThumbnail(ThemeProvider themeProvider) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: media.isAudio
              ? [
                  themeProvider.primaryColor,
                  themeProvider.primaryColor.withValues(alpha: 0.7)
                ]
              : [
                  themeProvider.accentColor,
                  themeProvider.accentColor.withValues(alpha: 0.7)
                ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        media.isAudio ? Icons.music_note : Icons.play_circle_outline,
        color: Colors.white,
        size: 28,
      ),
    );
  }
}

class _MediaOptionsSheet extends StatelessWidget {
  final MediaFile media;

  const _MediaOptionsSheet({required this.media});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: themeProvider.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.favorite_border,
                      color: themeProvider.primaryColor),
                ),
                title: const Text(AppStrings.addToFavorites),
                onTap: () {
                  context.read<MediaLibraryProvider>().toggleFavorite(media.id);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: themeProvider.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.playlist_add,
                      color: themeProvider.primaryColor),
                ),
                title: const Text(AppStrings.addToPlaylist),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.info_outline, color: Colors.blue),
                ),
                title: const Text(AppStrings.info),
                onTap: () {
                  Navigator.pop(context);
                  _showMediaInfo(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMediaInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(media.displayTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(AppStrings.duration, media.durationFormatted),
            _buildInfoRow(AppStrings.size, media.sizeFormatted),
            if (media.format != null)
              _buildInfoRow(AppStrings.format, media.format!),
            if (media.bitrate != null)
              _buildInfoRow(AppStrings.bitrate, '${media.bitrate} kbps'),
            _buildInfoRow(AppStrings.path, media.path, maxLines: 2),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.confirm),
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
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
