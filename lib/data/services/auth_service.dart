import '../../core/api/api_client.dart';
import '../models/user_model.dart';
import '../../core/constants/app_constants.dart';

class AuthService {
  final ApiClient _client;

  AuthService({ApiClient? client}) : _client = client ?? apiClient;

  /// Login with username and password
  Future<UserModel?> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _client.post('/Auth/login', data: {
        'username': username,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['token'] != null) {
          _client.setToken(data['token']);
        }
        return UserModel.fromJson(data);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Register new user
  Future<UserModel?> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    UserRole role = UserRole.customer,
    String? username,
  }) async {
    try {
      final response = await _client.post('/Auth/register', data: {
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'username': username ?? phone, 
        'password': password,
        'role': role.name, // Pass role name string
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;
        if (data['token'] != null) {
          _client.setToken(data['token']);
        }
        return UserModel.fromJson(data);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Get current user profile
  Future<UserModel?> getProfile() async {
    try {
      final response = await _client.get('/Auth/me');
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _client.post('/Auth/logout'); 
    } catch (_) {}
    await _client.clearToken();
  }

  /// Request password reset
  Future<bool> requestPasswordReset(String email) async {
    try {
      final response = await _client.post('/Auth/forgot-password', data: {
        'email': email,
      });
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Change password
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _client.post('/Auth/change-password', data: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      });
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
