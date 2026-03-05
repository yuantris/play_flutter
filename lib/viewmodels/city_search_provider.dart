import 'package:flutter/material.dart';
import '../data/models/location_model.dart';
import '../data/repositories/weather_repository.dart';

/// 城市搜索状态
enum SearchStatus {
  initial,
  loading,
  success,
  error,
}

/// 城市搜索状态管理
class CitySearchProvider extends ChangeNotifier {
  final WeatherRepository _repository;

  SearchStatus _status = SearchStatus.initial;
  List<LocationModel> _searchResults = [];
  String? _errorMessage;
  String _lastQuery = '';

  CitySearchProvider({required WeatherRepository repository})
      : _repository = repository;

  /// 获取搜索状态
  SearchStatus get status => _status;

  /// 获取搜索结果
  List<LocationModel> get searchResults => _searchResults;

  /// 获取错误信息
  String? get errorMessage => _errorMessage;

  /// 获取最后搜索关键词
  String get lastQuery => _lastQuery;

  /// 搜索城市
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      _status = SearchStatus.initial;
      notifyListeners();
      return;
    }

    _lastQuery = query;
    _status = SearchStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _searchResults = await _repository.searchCities(query);
      _status = SearchStatus.success;

      if (_searchResults.isEmpty) {
        _errorMessage = '未找到匹配的城市';
      }
    } catch (e) {
      _errorMessage = '搜索失败: ${e.toString()}';
      _status = SearchStatus.error;
    }

    notifyListeners();
  }

  /// 清除搜索结果
  void clear() {
    _searchResults = [];
    _status = SearchStatus.initial;
    _errorMessage = null;
    _lastQuery = '';
    notifyListeners();
  }
}
