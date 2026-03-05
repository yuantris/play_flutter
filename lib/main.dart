import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/network/api_client.dart';
import 'data/services/weather_api_service.dart';
import 'data/repositories/weather_repository.dart';
import 'viewmodels/theme_provider.dart';
import 'viewmodels/hourly_forecast_style_provider.dart';
import 'viewmodels/weather_provider.dart';
import 'viewmodels/city_search_provider.dart';
import 'ui/screens/weather/weather_home_screen.dart';
import 'ui/screens/settings/settings_screen.dart';

/// 应用入口
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化日期格式化的 locale 数据
  await initializeDateFormatting('zh_CN', null);

  // 初始化 API 客户端
  ApiClient().init();

  final prefs = await SharedPreferences.getInstance();
  final apiService = WeatherApiService();
  final repository = WeatherRepository(
    apiService: apiService,
    prefs: prefs,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(prefs: prefs),
        ),
        ChangeNotifierProvider(
          create: (_) => HourlyForecastStyleProvider(prefs: prefs),
        ),
        ChangeNotifierProvider(
          create: (_) => WeatherProvider(repository: repository),
        ),
        ChangeNotifierProvider(
          create: (_) => CitySearchProvider(repository: repository),
        ),
      ],
      child: const WeatherApp(),
    ),
  );
}

/// 天气应用主组件
class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: '天气',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const MainScreen(),
    );
  }
}

/// 主页面（包含底部导航栏）
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    WeatherHomeScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.wb_cloudy_outlined),
              selectedIcon: Icon(Icons.wb_cloudy),
              label: '天气',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: '设置',
            ),
          ],
        ),
      ),
    );
  }
}
