import 'package:dio/dio.dart';
import 'api_client.dart';

abstract class BaseApiService {
  final Dio dio;

  BaseApiService() : dio = ApiClient().dio;

  /// 统一的 GET 请求处理
  Future<T> get<T>({
    required String url,
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic> json) parser,
  }) async {
    try {
      final response = await dio.get(
        url,
        queryParameters: queryParameters,
      );

      return parser(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw NetworkException('未知错误: $e');
    }
  }

  /// 错误处理统一方法
  NetworkException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return NetworkException('连接超时');
      case DioExceptionType.cancel:
        return NetworkException('请求已取消');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = _parseErrorMessage(error.response?.data);
        return NetworkException(
          message ?? '服务器错误 ($statusCode)',
          code: statusCode,
        );
      default:
        return NetworkException(error.message ?? '网络错误');
    }
  }

  /// 解析错误信息（根据后端返回格式）
  String? _parseErrorMessage(dynamic data) {
    if (data is Map) {
      return data['reason'] ?? data['message'] ?? data['error'];
    }
    return null;
  }
}