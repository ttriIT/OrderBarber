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
  final String? token;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    required this.role,
    required this.createdAt,
    this.isActive = true,
    this.token,
  });

  /// Create from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      // API uses 'userId' (int) or 'id'
      id: (json['userId'] ?? json['id'] ?? '').toString(),
      // API uses 'fullName' or 'name'
      name: json['fullName'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? json['username'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      role: _parseUserRole(json['role']),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      isActive: json['isActive'] ?? true,
      token: json['token'],
    );
  }

  static UserRole _parseUserRole(dynamic role) {
    if (role is int) {
      // Mapping common integer roles if applicable, otherwise fallback
      if (role == 0) return UserRole.customer;
      if (role == 1) return UserRole.barber;
      if (role == 2) return UserRole.manager;
      if (role == 3) return UserRole.admin;
      return UserRole.values.length > role ? UserRole.values[role] : UserRole.customer;
    }
    if (role is String) {
      try {
        final lowerRole = role.toLowerCase();
        return UserRole.values.firstWhere(
          (e) => e.name.toLowerCase() == lowerRole,
          orElse: () => UserRole.customer,
        );
      } catch (_) {
        return UserRole.customer;
      }
    }
    return UserRole.customer;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': name,
      'email': email,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'role': role.name,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    UserRole? role,
    DateTime? createdAt,
    bool? isActive,
    String? token,
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
      token: token ?? this.token,
    );
  }

  bool get isCustomer => role == UserRole.customer;
  bool get isBarber => role == UserRole.barber;
  bool get isManager => role == UserRole.manager;
  bool get isAdmin => role == UserRole.admin;
}
