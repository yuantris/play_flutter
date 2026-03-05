import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  static ApiClient? _instance;
  static Dio? _dio;

  factory ApiClient() {
    _instance ??= ApiClient._internal();
    return _instance!;
  }

  ApiClient._internal();

  Dio get dio {
    if (_dio == null) {
      throw Exception('ApiClient 未初始化，请先调用 init() 方法');
    }
    return _dio!;
  }

  void init() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // 添加拦截器
    _dio!.interceptors.addAll([_loggingInterceptor(), _errorInterceptor()]);
  }

  Interceptor _loggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        debugPrint('🌐 API Request: ${options.method} ${options.path}');
        debugPrint('📤 Query: ${options.queryParameters}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint(
          '📥 API Response: ${response.statusCode} ${response.requestOptions.path}',
        );
        debugPrint('📄 Response Data: ${response.data}');
        return handler.next(response);
      },
      onError: (error, handler) {
        debugPrint('❌ API Error: ${error.message}');
        if (error.response != null) {
          debugPrint('❌ Error Response Data: ${error.response?.data}');
          debugPrint('❌ Error Status Code: ${error.response?.statusCode}');
        }
        return handler.next(error);
      },
    );
  }

  Interceptor _errorInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) async {
        // 统一错误处理
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout) {
          throw NetworkException('连接超时，请检查网络');
        }

        if (error.response?.statusCode == 429) {
          throw NetworkException('请求太频繁，请稍后重试');
        }

        throw NetworkException(
          error.message ?? '网络请求失败',
          code: error.response?.statusCode,
        );
      },
    );
  }
}

class NetworkException implements Exception {
  final String message;
  final int? code;

  NetworkException(this.message, {this.code});

  @override
  String toString() => 'NetworkException: $message (${code ?? 'unknown'})';
}
