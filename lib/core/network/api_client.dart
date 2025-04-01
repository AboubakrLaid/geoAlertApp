import 'package:dio/dio.dart';
import 'package:geoalert/config/app_config.dart';
import 'dart:io';

import 'package:geoalert/core/network/network_checker.dart';

class ApiClient {
  final NetworkChecker _networkChecker = NetworkChecker();
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConfig.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    validateStatus: (status) {
      return true; // Allows all status codes to be returned instead of throwing exceptions
    },
  ));

  Future<Response> post(String path, dynamic data) async {
    if (! await _networkChecker.hasInternetConnection()){
      throw ApiException("No internet connection. Please check your network.");
    }
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException("An unexpected error occurred. Please try again.");
    }
  }

  
  ApiException _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionError) {
      return ApiException("Could not connect to the server. Please try again later.");
    } else if (e.type == DioExceptionType.receiveTimeout || e.type == DioExceptionType.sendTimeout) {
      return ApiException("Request timed out. Please check your internet connection.");
    } else if (e.response != null && e.response?.statusCode == 500) {
      return ApiException("Server error. Please try again later.");
    } else {
      return ApiException("Something went wrong. Please try again.");
    }
  }
}


class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}
