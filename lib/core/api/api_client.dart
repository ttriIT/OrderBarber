import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import 'api_interceptors.dart';

class ApiClient {
  late Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(milliseconds: AppConstants.connectionTimeout),
        receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
        validateStatus: (status) => true, // Let us handle status codes manually for debugging
      ),
    );
    _dio.interceptors.add(ApiInterceptors());
    
    // Always add logging in debug mode to see what's happening
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        responseBody: true, 
        requestBody: true,
        requestHeader: true,
        responseHeader: false,
        error: true,
      ));
    }
  }

  Dio get dio => _dio;

  // GET request
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      _checkError(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // POST request
  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.post(path, data: data, queryParameters: queryParameters);
      _checkError(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // PUT request
  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.put(path, data: data, queryParameters: queryParameters);
      _checkError(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // DELETE request
  Future<Response> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.delete(path, data: data, queryParameters: queryParameters);
      _checkError(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  void _checkError(Response response) {
    if (response.statusCode != null && response.statusCode! >= 400) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
  }

  void setToken(String token) {
    ApiInterceptors.authToken = token;
  }

  Future<void> clearToken() async {
    ApiInterceptors.authToken = null;
  }
}

// Global instance or use a service locator like GetIt
final apiClient = ApiClient();
