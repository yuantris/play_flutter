import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/media_file.dart';
import '../../../providers/media_library_provider.dart';
import '../../../providers/player_provider.dart';
import '../../../providers/theme_provider.dart';
import '../player/audio_player_screen.dart';
import '../player/video_player_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<MediaFile> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
      _searchResults = context.read<MediaLibraryProvider>().searchMedia(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildSearchHeader(),
              Expanded(
                child: _isSearching
                    ? _buildSearchResults()
                    : _buildSearchSuggestions(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
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
        child: TextField(
          controller: _searchController,
          onChanged: _onSearch,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: '搜索歌曲、艺术家、专辑...',
            hintStyle: Theme.of(context).textTheme.bodySmall,
            prefixIcon: Icon(
              Icons.search,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      _onSearch('');
                    },
                    icon: Icon(
                      Icons.clear,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    return Consumer<MediaLibraryProvider>(
      builder: (context, mediaLibrary, child) {
        final recentlyPlayed = mediaLibrary.recentlyPlayed.take(10).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (recentlyPlayed.isNotEmpty) ...[
                Text(
                  AppStrings.recentlyPlayed,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                ...recentlyPlayed.map((media) => _buildMediaItem(media)),
              ],
              const SizedBox(height: 24),
              Text(
                '快速筛选',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _buildQuickFilters(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickFilters() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildFilterChip('音频', Icons.audiotrack, MediaType.audio, themeProvider),
            _buildFilterChip('视频', Icons.videocam, MediaType.video, themeProvider),
            _buildFilterChip('收藏', Icons.favorite, null, themeProvider),
          ],
        );
      },
    );
  }

  Widget _buildFilterChip(String label, IconData icon, MediaType? type, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: type == MediaType.audio
                ? themeProvider.primaryColor
                : type == MediaType.video
                    ? themeProvider.accentColor
                    : Theme.of(context).textTheme.bodySmall?.color,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
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
                Icons.search_off,
                size: 64,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '未找到相关结果',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '请尝试其他关键词',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '找到 ${_searchResults.length} 个结果',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final media = _searchResults[index];
              return _buildMediaItem(media);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMediaItem(MediaFile media) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: media.isAudio
                      ? [themeProvider.primaryColor, themeProvider.primaryColor.withValues(alpha: 0.7)]
                      : [themeProvider.accentColor, themeProvider.accentColor.withValues(alpha: 0.7)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                media.isAudio ? Icons.music_note : Icons.videocam,
                color: Colors.white,
                size: 24,
              ),
            ),
            title: Text(
              media.displayTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            subtitle: Text(
              media.isAudio
                  ? '${media.displayArtist} · ${media.durationFormatted}'
                  : '${media.durationFormatted} · ${media.sizeFormatted}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.play_circle_outline),
              color: Theme.of(context).textTheme.bodySmall?.color,
              onPressed: () => _playMedia(media),
            ),
            onTap: () => _playMedia(media),
          ),
        );
      },
    );
  }

  void _playMedia(MediaFile media) {
    final playerProvider = context.read<PlayerProvider>();
    playerProvider.play(media);

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
}
