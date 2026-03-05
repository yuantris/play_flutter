import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../data/models/location_model.dart';
import '../../../viewmodels/city_search_provider.dart';
import '../../../viewmodels/weather_provider.dart';

/// 城市搜索页面
class CitySearchScreen extends StatefulWidget {
  const CitySearchScreen({super.key});

  @override
  State<CitySearchScreen> createState() => _CitySearchScreenState();
}

class _CitySearchScreenState extends State<CitySearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('搜索城市'),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  /// 构建搜索栏
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: '输入城市名称',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<CitySearchProvider>().clear();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
        ),
        onChanged: _onSearchChanged,
        textInputAction: TextInputAction.search,
        onSubmitted: _onSearch,
      ),
    );
  }

  /// 构建搜索结果列表
  Widget _buildSearchResults() {
    return Consumer<CitySearchProvider>(
      builder: (context, provider, child) {
        if (provider.status == SearchStatus.loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.status == SearchStatus.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  provider.errorMessage ?? '搜索失败',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        if (provider.searchResults.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_city,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  provider.lastQuery.isEmpty ? '搜索城市' : '未找到匹配的城市',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: provider.searchResults.length,
          itemBuilder: (context, index) {
            final location = provider.searchResults[index];
            return _buildLocationItem(location);
          },
        );
      },
    );
  }

  /// 构建位置列表项
  Widget _buildLocationItem(LocationModel location) {
    return ListTile(
      leading: const Icon(Icons.location_on_outlined),
      title: Text(
        location.cityName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(location.displayName),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _selectCity(location),
    );
  }

  /// 搜索内容变化回调
  void _onSearchChanged(String query) {
    setState(() {});
    if (query.isEmpty) {
      context.read<CitySearchProvider>().clear();
    }
  }

  /// 执行搜索
  void _onSearch(String query) {
    if (query.trim().isNotEmpty) {
      context.read<CitySearchProvider>().search(query);
    }
  }

  /// 选择城市
  void _selectCity(LocationModel location) {
    context.read<WeatherProvider>().selectCity(location);
    Navigator.pop(context);
  }
}
