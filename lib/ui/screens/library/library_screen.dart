import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/media_file.dart';
import '../../../data/models/playlist.dart';
import '../../../data/models/media_folder.dart';
import '../../../providers/media_library_provider.dart';
import '../../../providers/theme_provider.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
          color: Theme.of(context).scaffoldBackgroundColor,
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
                    _buildPlaylistsTab(),
                    _buildArtistsTab(),
                    _buildAlbumsTab(),
                    _buildFoldersTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return FloatingActionButton.extended(
            onPressed: () => _createPlaylist(),
            backgroundColor: themeProvider.primaryColor,
            icon: const Icon(Icons.add),
            label: const Text('新建播放列表'),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(
            AppStrings.library,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.sort),
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).cardColor,
            ),
          ),
        ],
      ),
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
              fontSize: 12,
            ),
            tabs: const [
              Tab(text: AppStrings.playlists),
              Tab(text: AppStrings.artists),
              Tab(text: AppStrings.albums),
              Tab(text: AppStrings.folders),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlaylistsTab() {
    return Consumer<MediaLibraryProvider>(
      builder: (context, mediaLibrary, child) {
        final playlists = mediaLibrary.playlists;
        final favorites = mediaLibrary.favorites;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildFavoritesCard(favorites),
            const SizedBox(height: 16),
            if (playlists.isEmpty)
              _buildEmptyPlaylists()
            else
              ...playlists.map((playlist) => _buildPlaylistCard(playlist, mediaLibrary)),
          ],
        );
      },
    );
  }

  Widget _buildFavoritesCard(List<MediaFile> favorites) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                themeProvider.accentColor.withValues(alpha: 0.8),
                themeProvider.accentColor.withValues(alpha: 0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: themeProvider.accentColor.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            AppStrings.favorites,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${favorites.length} 首歌曲',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: Colors.white,
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

  Widget _buildEmptyPlaylists() {
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
              Icons.playlist_add,
              size: 64,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '暂无播放列表',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '点击下方按钮创建播放列表',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistCard(Playlist playlist, MediaLibraryProvider mediaLibrary) {
    final playlistWithMedia = mediaLibrary.getPlaylistWithMedia(playlist.id);
    final mediaCount = playlistWithMedia?.mediaFiles.length ?? 0;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [themeProvider.primaryColor, themeProvider.accentColor],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.queue_music,
                color: Colors.white,
                size: 28,
              ),
            ),
            title: Text(
              playlist.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            subtitle: Text(
              '$mediaCount 首歌曲',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              color: Theme.of(context).textTheme.bodySmall?.color,
              onPressed: () => _showPlaylistOptions(playlist.id),
            ),
            onTap: () {},
          ),
        );
      },
    );
  }

  Widget _buildArtistsTab() {
    return Consumer<MediaLibraryProvider>(
      builder: (context, mediaLibrary, child) {
        final artists = mediaLibrary.artists;

        if (artists.isEmpty) {
          return _buildEmptyState('暂无艺术家', Icons.person_outline);
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.85,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: artists.length,
          itemBuilder: (context, index) {
            final artist = artists[index];
            return _buildArtistCard(artist);
          },
        );
      },
    );
  }

  Widget _buildArtistCard(Artist artist) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            themeProvider.primaryColor.withValues(alpha: 0.8),
                            themeProvider.accentColor.withValues(alpha: 0.8),
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      artist.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${artist.trackCount} 首歌曲',
                      style: Theme.of(context).textTheme.bodySmall,
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

  Widget _buildAlbumsTab() {
    return Consumer<MediaLibraryProvider>(
      builder: (context, mediaLibrary, child) {
        final albums = mediaLibrary.albums;

        if (albums.isEmpty) {
          return _buildEmptyState('暂无专辑', Icons.album_outlined);
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.85,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: albums.length,
          itemBuilder: (context, index) {
            final album = albums[index];
            return _buildAlbumCard(album);
          },
        );
      },
    );
  }

  Widget _buildAlbumCard(Album album) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            themeProvider.accentColor.withValues(alpha: 0.8),
                            themeProvider.primaryColor.withValues(alpha: 0.8),
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.album,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      album.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      album.artist,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildFoldersTab() {
    return Consumer<MediaLibraryProvider>(
      builder: (context, mediaLibrary, child) {
        final folders = mediaLibrary.folders;

        if (folders.isEmpty) {
          return _buildEmptyState('暂无文件夹', Icons.folder_outlined);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: folders.length,
          itemBuilder: (context, index) {
            final folder = folders[index];
            return _buildFolderCard(folder);
          },
        );
      },
    );
  }

  Widget _buildFolderCard(MediaFolder folder) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: folder.mediaType == MediaType.audio
                    ? themeProvider.primaryColor.withValues(alpha: 0.2)
                    : themeProvider.accentColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                folder.mediaType == MediaType.audio ? Icons.music_note : Icons.videocam,
                color: folder.mediaType == MediaType.audio ? themeProvider.primaryColor : themeProvider.accentColor,
                size: 28,
              ),
            ),
            title: Text(
              folder.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            subtitle: Text(
              '${folder.mediaCount} 个文件 · ${folder.totalSizeFormatted}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            onTap: () {},
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
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
        ],
      ),
    );
  }

  void _createPlaylist() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('新建播放列表'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: '输入播放列表名称',
            filled: true,
            fillColor: Theme.of(context).scaffoldBackgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return ElevatedButton(
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    context.read<MediaLibraryProvider>().createPlaylist(controller.text);
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeProvider.primaryColor,
                ),
                child: const Text(AppStrings.confirm),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showPlaylistOptions(String playlistId) {
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
                  leading: Icon(Icons.edit, color: themeProvider.primaryColor),
                  title: const Text(AppStrings.rename),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(AppStrings.delete),
                  onTap: () {
                    context.read<MediaLibraryProvider>().deletePlaylist(playlistId);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
