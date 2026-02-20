import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio;

  ApiClient(this._dio) {
    _dio.options.baseUrl = 'http://10.0.2.2:3000/api'; // Use 10.0.2.2 for Android Emulator connecting to localhost
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers = {
      // Must match the API_KEY defined in backend/.env.example
      'x-api-key': 'your_super_secret_api_key_here',
    };

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  Future<Response> post(String path, {Map<String, dynamic>? data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException error) {
    if (error.response != null) {
      return Exception(error.response?.data['error'] ?? 'An API error occurred');
    } else {
      return Exception('Failed to connect to the server. Is it running?');
    }
  }
}
