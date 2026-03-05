import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/theme_provider.dart';
import '../../../viewmodels/hourly_forecast_style_provider.dart';
import '../../../core/constants/app_strings.dart';

/// 设置页面
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settings),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        ),
      ),
      body: ListView(
        children: [
          _buildHourlyForecastSection(context),
          const Divider(),
          _buildThemeSection(context),
          const Divider(),
          _buildAboutSection(context),
        ],
      ),
    );
  }

  /// 构建主题设置区域
  Widget _buildThemeSection(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                '外观',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                themeProvider.isDarkMode
                    ? Icons.dark_mode
                    : Icons.light_mode,
              ),
              title: const Text(AppStrings.darkMode),
              subtitle: Text(_getThemeModeDescription(themeProvider.themeMode)),
              trailing: Switch(
                value: themeProvider.isDarkMode,
                onChanged: (_) => themeProvider.toggleTheme(),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.brightness_auto),
              title: const Text('跟随系统'),
              trailing: Radio<ThemeMode>(
                value: ThemeMode.system,
                groupValue: themeProvider.themeMode,
                onChanged: (mode) {
                  if (mode != null) {
                    themeProvider.setThemeMode(mode);
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// 获取主题模式描述
  String _getThemeModeDescription(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return '跟随系统设置';
      case ThemeMode.light:
        return '浅色模式';
      case ThemeMode.dark:
        return '深色模式';
    }
  }

  /// 构建关于区域
  Widget _buildAboutSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            AppStrings.about,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('版本'),
          subtitle: const Text('1.0.0'),
        ),
        ListTile(
          leading: const Icon(Icons.code),
          title: const Text('数据来源'),
          subtitle: const Text('Open-Meteo API'),
          onTap: () {
            showAboutDialog(
              context: context,
              applicationName: '天气',
              applicationVersion: '1.0.0',
              applicationLegalese: '© 2026',
              children: [
                const SizedBox(height: 16),
                const Text(
                  '天气数据由 Open-Meteo 提供\n'
                  'https://open-meteo.com/',
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  /// 构建小时预报样式设置区域
  Widget _buildHourlyForecastSection(BuildContext context) {
    return Consumer<HourlyForecastStyleProvider>(
      builder: (context, styleProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                '小时预报',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                styleProvider.isChartStyle ? Icons.show_chart : Icons.list,
              ),
              title: const Text('折线图表样式'),
              subtitle: Text(styleProvider.isChartStyle ? '折线图表展示' : '横向列表展示'),
              trailing: Switch(
                value: styleProvider.isChartStyle,
                onChanged: (_) => styleProvider.toggleStyle(),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('当前样式'),
              subtitle: const Text('横向滚动列表'),
              trailing: Radio<HourlyForecastStyle>(
                value: HourlyForecastStyle.list,
                groupValue: styleProvider.style,
                onChanged: (style) {
                  if (style != null) {
                    styleProvider.setStyle(style);
                  }
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.show_chart),
              title: const Text('折线样式'),
              subtitle: const Text('折线图表展示'),
              trailing: Radio<HourlyForecastStyle>(
                value: HourlyForecastStyle.chart,
                groupValue: styleProvider.style,
                onChanged: (style) {
                  if (style != null) {
                    styleProvider.setStyle(style);
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
