import '../../core/api/api_client.dart';
import '../models/user_model.dart';
import '../../core/constants/app_constants.dart';

class AuthService {
  final ApiClient _client;

  AuthService({ApiClient? client}) : _client = client ?? apiClient;

  /// Login with username (phone) and password
  Future<UserModel?> login({
    required String username, // mapped from phone in UI
    required String password,
  }) async {
    try {
      final response = await _client.post('/Auth/login', data: {
        'username': username,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        // Save token
        if (data['token'] != null) {
          _client.setToken(data['token']);
        }
        
        // Parse user (data contains both user info and token at root level based on Swagger)
        // Adjusting json to match UserModel.fromJson expectation (flat structure from API)
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
    String? username,
  }) async {
    try {
      final response = await _client.post('/Auth/register', data: {
        'fullName': fullName,
        'email': email,
        'phone': phone,
        // Use phone as username if not provided
        'username': username ?? phone, 
        'password': password,
        'role': UserRole.customer.name, // Swagger expects string
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
      return null; // Return null instead of throwing for smooth UX
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      // Best effort logout
      await _client.post('/Auth/logout'); 
    } catch (_) {}
    await _client.clearToken();
  }

  /// Verify OTP (Keep existing if used by UI, but endpoint might not exist in new API)
  Future<bool> verifyOTP({
    required String phone,
    required String otp,
  }) async {
     // TODO: Check if this endpoint exists in new API. Keeping for now.
    try {
      final response = await _client.post('/Auth/verify-otp', data: {
        'phone': phone,
        'otp': otp,
      });
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
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

  /// Update profile
  Future<UserModel?> updateProfile({
    required String name,
    String? email,
    String? phone,
    String? avatarUrl,
    List<String>? skills,
    int? yearsOfExperience,
  }) async {
    try {
      final response = await _client.put('/Auth/profile', data: {
        'name': name,
        'email': email,
        'phone': phone,
        'avatarUrl': avatarUrl,
        'skills': skills,
        'yearsOfExperience': yearsOfExperience,
      });

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      rethrow;
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
