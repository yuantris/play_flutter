import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/media_library_provider.dart';
import '../../../ui/themes/dynamic_app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildSectionTitle('外观'),
              _buildThemeSection(),
              const SizedBox(height: 24),
              _buildSectionTitle('播放'),
              _buildPlaybackSection(),
              const SizedBox(height: 24),
              _buildSectionTitle('存储'),
              _buildStorageSection(),
              const SizedBox(height: 24),
              _buildSectionTitle(AppStrings.about),
              _buildAboutSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Text(
            AppStrings.settings,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: themeProvider.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        );
      },
    );
  }

  Widget _buildThemeSection() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildThemeModeTile(themeProvider),
              _buildDivider(),
              _buildColorPickerTile(context, themeProvider),
              _buildDivider(),
              _buildAccentColorPickerTile(context, themeProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeModeTile(ThemeProvider themeProvider) {
    String currentModeName;
    IconData currentModeIcon;
    
    switch (themeProvider.themeMode) {
      case AppThemeMode.system:
        currentModeName = '跟随系统';
        currentModeIcon = Icons.brightness_auto;
        break;
      case AppThemeMode.light:
        currentModeName = '浅色模式';
        currentModeIcon = Icons.light_mode;
        break;
      case AppThemeMode.dark:
        currentModeName = '深色模式';
        currentModeIcon = Icons.dark_mode;
        break;
    }
    
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: themeProvider.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(currentModeIcon, color: themeProvider.primaryColor, size: 20),
      ),
      title: const Text('主题模式'),
      subtitle: Text(currentModeName),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showThemeModeDialog(themeProvider),
    );
  }

  Widget _buildColorPickerTile(BuildContext context, ThemeProvider themeProvider) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: themeProvider.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.palette, color: themeProvider.primaryColor, size: 20),
      ),
      title: const Text('主题颜色'),
      trailing: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: themeProvider.primaryColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: themeProvider.primaryColor.withValues(alpha: 0.4),
              blurRadius: 8,
            ),
          ],
        ),
      ),
      onTap: () => _showColorPickerDialog(context, themeProvider, isPrimary: true),
    );
  }

  Widget _buildAccentColorPickerTile(BuildContext context, ThemeProvider themeProvider) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: themeProvider.accentColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.color_lens, color: themeProvider.accentColor, size: 20),
      ),
      title: const Text('强调颜色'),
      trailing: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: themeProvider.accentColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: themeProvider.accentColor.withValues(alpha: 0.4),
              blurRadius: 8,
            ),
          ],
        ),
      ),
      onTap: () => _showColorPickerDialog(context, themeProvider, isPrimary: false),
    );
  }

  Widget _buildPlaybackSection() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildSettingsTile(
                icon: Icons.skip_next,
                title: '自动播放下一首',
                trailing: Switch(
                  value: true,
                  onChanged: (value) {},
                  activeColor: themeProvider.primaryColor,
                ),
                primaryColor: themeProvider.primaryColor,
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.speed,
                title: '默认播放速度',
                trailing: const Text('1.0x'),
                onTap: () => _showSpeedDialog(),
                primaryColor: themeProvider.primaryColor,
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.equalizer,
                title: AppStrings.equalizer,
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
                primaryColor: themeProvider.primaryColor,
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.bedtime,
                title: AppStrings.sleepTimer,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showSleepTimerDialog(),
                primaryColor: themeProvider.primaryColor,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStorageSection() {
    return Consumer2<MediaLibraryProvider, ThemeProvider>(
      builder: (context, mediaLibrary, themeProvider, child) {
        final audioCount = mediaLibrary.audioFiles.length;
        final videoCount = mediaLibrary.videoFiles.length;

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildSettingsTile(
                icon: Icons.music_note,
                title: '音频文件',
                trailing: Text('$audioCount 个'),
                primaryColor: themeProvider.primaryColor,
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.videocam,
                title: '视频文件',
                trailing: Text('$videoCount 个'),
                primaryColor: themeProvider.primaryColor,
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.refresh,
                title: '重新扫描媒体',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  mediaLibrary.scanMedia();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('正在扫描媒体文件...'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                primaryColor: themeProvider.primaryColor,
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.delete_outline,
                title: '清除缓存',
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showClearCacheDialog(),
                primaryColor: themeProvider.primaryColor,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAboutSection() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildSettingsTile(
                icon: Icons.info_outline,
                title: AppStrings.about,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showAboutDialog(),
                primaryColor: themeProvider.primaryColor,
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.star_outline,
                title: AppStrings.rate,
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
                primaryColor: themeProvider.primaryColor,
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.feedback_outlined,
                title: AppStrings.feedback,
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
                primaryColor: themeProvider.primaryColor,
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: AppStrings.privacyPolicy,
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
                primaryColor: themeProvider.primaryColor,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    required Color primaryColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: primaryColor, size: 20),
      ),
      title: Text(title),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Theme.of(context).dividerColor,
      height: 1,
      indent: 56,
      endIndent: 16,
    );
  }

  void _showThemeModeDialog(ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('主题模式'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeModeOption(
              themeProvider,
              AppThemeMode.system,
              '跟随系统',
              Icons.brightness_auto,
            ),
            _buildThemeModeOption(
              themeProvider,
              AppThemeMode.light,
              '浅色模式',
              Icons.light_mode,
            ),
            _buildThemeModeOption(
              themeProvider,
              AppThemeMode.dark,
              '深色模式',
              Icons.dark_mode,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeModeOption(
    ThemeProvider themeProvider,
    AppThemeMode mode,
    String name,
    IconData icon,
  ) {
    final isSelected = themeProvider.themeMode == mode;
    
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? themeProvider.primaryColor : null,
      ),
      title: Text(name),
      trailing: isSelected
          ? Icon(Icons.check, color: themeProvider.primaryColor)
          : null,
      onTap: () {
        themeProvider.setThemeMode(mode);
        Navigator.pop(context);
      },
    );
  }

  void _showColorPickerDialog(BuildContext context, ThemeProvider themeProvider, {required bool isPrimary}) {
    final colors = isPrimary ? themeProvider.availablePrimaryColors : themeProvider.availableAccentColors;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(isPrimary ? '选择主题颜色' : '选择强调颜色'),
        content: SizedBox(
          width: 280,
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 4,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: colors.map((color) {
              final isSelected = isPrimary
                  ? themeProvider.primaryColor == color
                  : themeProvider.accentColor == color;
              
              return InkWell(
                onTap: () {
                  if (isPrimary) {
                    themeProvider.setPrimaryColor(color);
                  } else {
                    themeProvider.setAccentColor(color);
                  }
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 8,
                      ),
                    ],
                    border: isSelected
                        ? Border.all(color: Colors.white, width: 3)
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white)
                      : null,
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
        ],
      ),
    );
  }

  void _showSpeedDialog() {
    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('默认播放速度'),
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: speeds.map((speed) {
            return InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: speed == 1.0 ? Theme.of(context).colorScheme.primary : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${speed}x',
                  style: TextStyle(
                    color: speed == 1.0 ? Colors.white : null,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
        ],
      ),
    );
  }

  void _showSleepTimerDialog() {
    final options = ['关闭', '15分钟', '30分钟', '45分钟', '1小时', '自定义'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text(AppStrings.sleepTimer),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((option) {
            return ListTile(
              title: Text(option),
              onTap: () => Navigator.pop(context),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('清除缓存'),
        content: const Text('确定要清除所有缓存数据吗？这不会删除您的媒体文件。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('缓存已清除'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DynamicAppColors.error,
            ),
            child: const Text(AppStrings.confirm),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: AppStrings.appName,
      applicationVersion: '1.0.0',
      applicationIcon: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [themeProvider.primaryColor, themeProvider.accentColor],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.play_circle_fill,
              color: Colors.white,
              size: 48,
            ),
          );
        },
      ),
      children: [
        const Text('一款功能强大的综合媒体播放器'),
        const SizedBox(height: 8),
        const Text('支持音频和视频播放'),
      ],
    );
  }
}
