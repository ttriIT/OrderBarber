import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
// import 'package:shared_preferences/shared_preferences.dart'; // Add this to pubspec if not available

class ApiInterceptors extends Interceptor {
  static String? authToken;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (authToken != null) {
      options.headers['Authorization'] = 'Bearer $authToken';
    }
    
    options.headers['Accept'] = 'application/json';
    options.headers['Content-Type'] = 'application/json';
    
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle specific errors like 401 Unauthorized
    if (err.response?.statusCode == 401) {
      // TODO: Handle logout or refresh token
    }
    super.onError(err, handler);
  }
}
