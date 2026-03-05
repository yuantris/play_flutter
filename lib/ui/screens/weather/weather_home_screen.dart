import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/weather_provider.dart';
import '../../../viewmodels/hourly_forecast_style_provider.dart';
import '../../widgets/weather_card.dart';
import '../../widgets/hourly_forecast_list.dart';
import '../../widgets/hourly_forecast_chart.dart';
import '../../widgets/daily_forecast_list.dart';
import '../../widgets/air_quality_panel.dart';
import '../../widgets/life_index_panel.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/temperature_chart.dart';
import '../city_search/city_search_screen.dart';

/// 天气主页
class WeatherHomeScreen extends StatefulWidget {
  const WeatherHomeScreen({super.key});

  @override
  State<WeatherHomeScreen> createState() => _WeatherHomeScreenState();
}

class _WeatherHomeScreenState extends State<WeatherHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<WeatherProvider>(
        builder: (context, provider, child) {
          return RefreshIndicator(
            onRefresh: provider.refresh,
            child: _buildBody(provider),
          );
        },
      ),
    );
  }

  /// 构建页面主体
  Widget _buildBody(WeatherProvider provider) {
    // 根据状态构建不同的UI
    switch (provider.status) {
      case WeatherLoadStatus.initial:
      case WeatherLoadStatus.loadingLocation:
        return _buildLoadingLocation();
      case WeatherLoadStatus.loading:
        return const LoadingWidget();
      case WeatherLoadStatus.permissionDenied:
        return _buildPermissionDenied(provider);
      case WeatherLoadStatus.permissionPermanentlyDenied:
        return _buildPermissionPermanentlyDenied(provider);
      case WeatherLoadStatus.locationTimeout:
        return _buildLocationTimeout(provider);
      case WeatherLoadStatus.googlePlayServicesNotAvailable:
        return _buildGooglePlayServicesError(provider);
      case WeatherLoadStatus.error:
        return _buildError(provider);
      case WeatherLoadStatus.success:
        return _buildContent(provider);
    }
  }

  /// 构建内容
  Widget _buildContent(WeatherProvider provider) {
    final weather = provider.weather;
    final airQuality = provider.airQuality;
    final location = provider.currentLocation;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          snap: true,
          expandedHeight: 80,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          ),
          flexibleSpace: FlexibleSpaceBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on, size: 18),
                const SizedBox(width: 4),
                Text(
                  location?.cityName ?? '未知位置',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            centerTitle: true,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _navigateToSearch,
              tooltip: '搜索城市',
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: provider.refresh,
              tooltip: '刷新',
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (weather?.current != null) ...[
                  WeatherCard(weather: weather!.current!),
                  const SizedBox(height: 24),
                ],
                if (weather?.hourly.isNotEmpty ?? false) ...[
                  Consumer<HourlyForecastStyleProvider>(
                    builder: (context, styleProvider, child) {
                      if (styleProvider.isChartStyle) {
                        return HourlyForecastChart(hourlyData: weather!.hourly);
                      }
                      return HourlyForecastList(hourlyData: weather!.hourly);
                    },
                  ),
                  const SizedBox(height: 24),
                ],
                // 24小时温度折线图
                if (weather?.hourly.isNotEmpty ?? false) ...[
                  TemperatureChart(
                    hourlyData: weather!.hourly,
                    chartType: TemperatureChartType.hourly,
                    height: 200,
                  ),
                  const SizedBox(height: 24),
                ],
                // 7天温度折线图
                if (weather?.daily.isNotEmpty ?? false) ...[
                  TemperatureChart(
                    dailyData: weather!.daily,
                    chartType: TemperatureChartType.daily,
                    height: 200,
                  ),
                  const SizedBox(height: 24),
                ],
                if (weather?.daily.isNotEmpty ?? false) ...[
                  DailyForecastList(dailyData: weather!.daily),
                  const SizedBox(height: 24),
                ],
                AirQualityPanel(airQuality: airQuality),
                const SizedBox(height: 16),
                LifeIndexPanel(weather: weather),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 构建定位中状态
  Widget _buildLoadingLocation() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            '正在获取位置...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => _navigateToSearch(),
            icon: const Icon(Icons.search),
            label: const Text('手动选择城市'),
          ),
        ],
      ),
    );
  }

  /// 构建权限被拒绝状态
  Widget _buildPermissionDenied(WeatherProvider provider) {
    return _buildErrorCard(
      icon: Icons.location_disabled,
      title: '位置权限被拒绝',
      message: provider.errorMessage ?? '需要位置权限才能获取当前位置',
      primaryButton: ElevatedButton.icon(
        onPressed: () => provider.requestLocationPermission(),
        icon: const Icon(Icons.location_on),
        label: const Text('授予权限'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      secondaryButton: TextButton.icon(
        onPressed: () => _navigateToSearch(),
        icon: const Icon(Icons.search),
        label: const Text('手动选择城市'),
      ),
    );
  }

  /// 构建权限被永久拒绝状态
  Widget _buildPermissionPermanentlyDenied(WeatherProvider provider) {
    return _buildErrorCard(
      icon: Icons.settings,
      title: '需要位置权限',
      message: provider.errorMessage ?? '位置权限被永久拒绝，请前往设置手动开启',
      primaryButton: ElevatedButton.icon(
        onPressed: () => provider.openAppSettings(),
        icon: const Icon(Icons.open_in_new),
        label: const Text('前往设置'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      secondaryButton: TextButton.icon(
        onPressed: () => _navigateToSearch(),
        icon: const Icon(Icons.search),
        label: const Text('手动选择城市'),
      ),
    );
  }

  /// 构建定位超时状态
  Widget _buildLocationTimeout(WeatherProvider provider) {
    return _buildErrorCard(
      icon: Icons.timer_off,
      title: '获取位置超时',
      message: provider.errorMessage ?? '无法获取位置，请检查GPS是否开启',
      primaryButton: ElevatedButton.icon(
        onPressed: () => provider.retryLocation(),
        icon: const Icon(Icons.refresh),
        label: const Text('重试定位'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      secondaryButton: TextButton.icon(
        onPressed: () => _navigateToSearch(),
        icon: const Icon(Icons.search),
        label: const Text('手动选择城市'),
      ),
    );
  }

  /// 构建 Google Play 服务不可用状态
  Widget _buildGooglePlayServicesError(WeatherProvider provider) {
    return _buildErrorCard(
      icon: Icons.error_outline,
      title: 'Google Play 服务不可用',
      message: provider.errorMessage ?? '请安装或更新 Google Play 服务',
      primaryButton: ElevatedButton.icon(
        onPressed: () => _navigateToSearch(),
        icon: const Icon(Icons.search),
        label: const Text('手动选择城市'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      secondaryButton: null,
    );
  }

  /// 构建通用错误状态
  Widget _buildError(WeatherProvider provider) {
    return _buildErrorCard(
      icon: Icons.error_outline,
      title: '加载失败',
      message: provider.errorMessage ?? '发生未知错误',
      primaryButton: ElevatedButton.icon(
        onPressed: () => provider.retry(),
        icon: const Icon(Icons.refresh),
        label: const Text('重试'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      secondaryButton: TextButton.icon(
        onPressed: () => _navigateToSearch(),
        icon: const Icon(Icons.search),
        label: const Text('选择城市'),
      ),
    );
  }

  /// 构建错误卡片
  Widget _buildErrorCard({
    required IconData icon,
    required String title,
    required String message,
    required Widget primaryButton,
    Widget? secondaryButton,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            primaryButton,
            if (secondaryButton != null) ...[
              const SizedBox(height: 12),
              secondaryButton,
            ],
          ],
        ),
      ),
    );
  }

  /// 导航到搜索页面
  void _navigateToSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CitySearchScreen(),
      ),
    );
  }
}
