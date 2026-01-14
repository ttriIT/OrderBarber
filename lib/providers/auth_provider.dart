import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/services/auth_service.dart';
import '../core/constants/app_constants.dart';

/// AuthProvider for managing authentication state
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  String? get errorMessage => _errorMessage;
  UserRole? get userRole => _currentUser?.role;

  /// Login with role selection
  Future<bool> login({
    required String phone,
    required String password,
    required UserRole role, // Keeping this parameter for UI compatibility, even if not used by API
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Map phone to username for API
      final user = await _authService.login(
        username: phone,
        password: password,
      );

      if (user != null) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Đăng nhập thất bại';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Có lỗi xảy ra: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Register new user
  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Map name to fullName for API
      final user = await _authService.register(
        fullName: name,
        email: email,
        phone: phone,
        password: password,
      );

      if (user != null) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Đăng ký thất bại: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Verify OTP
  Future<bool> verifyOTP(String phone, String otp) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.verifyOTP(phone: phone, otp: otp);
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Request password reset
  Future<bool> requestPasswordReset(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.requestPasswordReset(email);
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _authService.logout();
    _currentUser = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Update profile
  Future<bool> updateProfile({
    required String name,
    String? email,
    String? phone,
    String? avatarUrl,
    List<String>? skills,
    int? yearsOfExperience,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.updateProfile(
        name: name,
        email: email,
        phone: phone,
        avatarUrl: avatarUrl,
        skills: skills,
        yearsOfExperience: yearsOfExperience,
      );

      if (user != null) {
        _currentUser = user;
      }
      _isLoading = false;
      notifyListeners();
      return user != null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Change password
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
