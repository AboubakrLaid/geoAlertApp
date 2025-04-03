import 'package:dio/dio.dart';
import 'package:geoalert/config/app_config.dart';
import 'package:geoalert/core/network/api_interceptor.dart';
import 'package:geoalert/core/network/network_checker.dart';
import 'package:geoalert/core/storage/local_storage.dart';

class ApiClient {
  final NetworkChecker _networkChecker = NetworkChecker();
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConfig.baseUrl, connectTimeout: const Duration(seconds: 30), receiveTimeout: const Duration(seconds: 30)));

  ApiClient() {
    _dio.interceptors.add(ApiInterceptor(_dio));
  }

  Future<void> _addAuthorizationHeaderIfNeeded({bool requireAuth = false}) async {
    if (requireAuth) {
      final token = await LocalStorage.instance.getAccessToken();
      if (token != null && token.isNotEmpty) {
        _dio.options.headers['Authorization'] = 'Bearer $token';
      }
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  Future<Response> post(String path, dynamic data, {bool requireAuth = false}) async {
    await _addAuthorizationHeaderIfNeeded(requireAuth: requireAuth);

    if (!await _networkChecker.hasInternetConnection()) {
      throw ApiException("No internet connection. Please check your network.");
    }

    try {
      print(_dio.options.headers);
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> get(String path, {bool requireAuth = false}) async {
    await _addAuthorizationHeaderIfNeeded(requireAuth: requireAuth);

    if (!await _networkChecker.hasInternetConnection()) {
      throw ApiException("No internet connection. Please check your network.");
    }

    try {
      return await _dio.get(path);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  ApiException _handleDioError(DioException e) {
    String? errorMessage;
    print("e.respinse : ${e.response}");
    print("e.status code : ${e.response?.statusCode}");
    if (e.response != null) {
      if (e.response?.data is Map<String, dynamic> && e.response?.data.containsKey('message')) {
        errorMessage = e.response?.data['message'];
      }
    }

    if (e.type == DioExceptionType.connectionError) {
      return ApiException("Could not connect to the server. Please try again later.");
    } else if (e.type == DioExceptionType.receiveTimeout || e.type == DioExceptionType.sendTimeout) {
      return ApiException("Request timed out. Please check your internet connection.");
    } else if (e.response != null && e.response?.statusCode == 500) {
      if (errorMessage != null) {
        return ApiException(errorMessage);
      }
      return ApiException("Server error. Please try again later.");
    } else if (e.response != null && e.response?.statusCode == 401) {
      if (errorMessage != null) {
        return ApiException(errorMessage);
      }
      return ApiException("Unauthorized. Please log in again.");
    } else if (e.response != null && e.response?.statusCode == 403) {
      if (errorMessage != null) {
        return ApiException(errorMessage);
      }
      return ApiException("Forbidden. You do not have permission to access this resource.");
    } else if (e.response != null && e.response?.statusCode == 400) {
      if (errorMessage != null) {
        return ApiException(errorMessage);
      }
      return ApiException("Bad request. Please check your input.");
    } else {
      return ApiException("Something went wrong. Please try again.");
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
}
