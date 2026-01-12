import '../models/user_model.dart';
import '../mock/mock_users.dart';
import '../../core/constants/app_constants.dart';
import '../mock/mock_barbers.dart';

/// Fake authentication service for mock login/logout
/// TODO: Replace with real API calls when backend is ready
class FakeAuthService {
  // Simulate current logged in user
  UserModel? _currentUser;

  /// Get current user
  UserModel? get currentUser => _currentUser;

  /// Check if user is logged in
  bool get isLoggedIn => _currentUser != null;

  /// Login with phone and password (fake)
  Future<UserModel?> login({
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock login - always succeed based on role
    UserModel? user;
    switch (role) {
      case UserRole.customer:
        user = MockUsers.customers.first;
        break;
      case UserRole.barber:
        user = MockUsers.barbers.first;
        break;
      case UserRole.admin:
        user = MockUsers.admins.first;
        break;
    }

    _currentUser = user;
    return user;
  }

  /// Register new user (fake)
  Future<UserModel?> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Create new mock user
    final newUser = UserModel(
      id: 'customer_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      phone: phone,
      avatarUrl: 'https://i.pravatar.cc/150?img=${DateTime.now().second}',
      role: UserRole.customer,
      createdAt: DateTime.now(),
    );

    _currentUser = newUser;
    return newUser;
  }

  /// Verify OTP (fake - always succeed)
  Future<bool> verifyOTP({
    required String phone,
    required String otp,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return otp.length == 6; // Simple validation
  }

  /// Request password reset (fake)
  Future<bool> requestPasswordReset(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true; // Always succeed
  }

  /// Logout
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
  }

  Future<UserModel?> updateProfile({
    required String name,
    String? email,
    String? phone,
    String? avatarUrl,
    List<String>? skills,
    int? yearsOfExperience,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        name: name,
        email: email ?? _currentUser!.email,
        phone: phone ?? _currentUser!.phone,
        avatarUrl: avatarUrl ?? _currentUser!.avatarUrl,
      );

      // If user is a barber, update their barber details too
      if (_currentUser!.role == UserRole.barber) {
        final barber = MockBarbers.getByPhone(_currentUser!.phone) ?? MockBarbers.getById(_currentUser!.id);
        if (barber != null) {
          MockBarbers.updateBarber(barber.copyWith(
            name: name,
            phone: phone ?? _currentUser!.phone,
            avatarUrl: avatarUrl ?? _currentUser!.avatarUrl,
            skills: skills,
            yearsOfExperience: yearsOfExperience,
          ));
        }
      }
    }

    return _currentUser;
  }

  /// Change password (fake)
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Fake validation - old password must be "123456"
    return oldPassword.isNotEmpty && newPassword.length >= 6;
  }
}
