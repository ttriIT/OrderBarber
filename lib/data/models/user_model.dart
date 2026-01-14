import '../../core/constants/app_constants.dart';

/// User model representing all user roles
class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String avatarUrl;
  final UserRole role;
  final DateTime createdAt;
  final bool isActive;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    required this.role,
    required this.createdAt,
    this.isActive = true,
  });

  /// Create from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      // API uses 'userId' (int) instead of 'id' (String)
      id: (json['userId'] ?? json['id'] ?? '').toString(),
      // API uses 'fullName' instead of 'name'
      name: json['fullName'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      role: _parseUserRole(json['role']),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      // API doesn't return isActive in profile, default to true
      isActive: json['isActive'] ?? true,
    );
  }

  static UserRole _parseUserRole(dynamic role) {
    if (role is int) {
      return UserRole.values.length > role ? UserRole.values[role] : UserRole.customer;
    }
    if (role is String) {
      try {
        return UserRole.values.firstWhere(
          (e) => e.name.toLowerCase() == role.toLowerCase(),
          orElse: () => UserRole.customer,
        );
      } catch (_) {
        return UserRole.customer;
      }
    }
    return UserRole.customer;
  }

  /// Convert to JSON (TODO: implement when backend ready)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'role': role.name,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  /// Copy with new values
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    UserRole? role,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Check if user is customer
  bool get isCustomer => role == UserRole.customer;

  /// Check if user is barber
  bool get isBarber => role == UserRole.barber;

  /// Check if user is manager
  bool get isManager => role == UserRole.manager;

  /// Check if user is admin
  bool get isAdmin => role == UserRole.admin;
}
