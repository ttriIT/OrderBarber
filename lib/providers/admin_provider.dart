import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/models/shop_model.dart';
import '../data/models/service_model.dart';
import '../data/services/fake_admin_service.dart';
import '../core/constants/app_constants.dart';

/// AdminProvider for admin dashboard and management
class AdminProvider extends ChangeNotifier {
  final FakeAdminService _adminService = FakeAdminService();

  Map<String, dynamic> _dashboardStats = {};
  List<Map<String, dynamic>> _revenueChart = [];
  List<Map<String, dynamic>> _topServices = [];
  List<UserModel> _users = [];
  List<ShopModel> _shops = [];
  List<ServiceModel> _services = [];
  Map<BookingStatus, int> _bookingsByStatus = {};
  bool _isLoading = false;

  // Getters
  Map<String, dynamic> get dashboardStats => _dashboardStats;
  List<Map<String, dynamic>> get revenueChart => _revenueChart;
  List<Map<String, dynamic>> get topServices => _topServices;
  List<UserModel> get users => _users;
  List<ShopModel> get shops => _shops;
  List<ServiceModel> get services => _services;
  Map<BookingStatus, int> get bookingsByStatus => _bookingsByStatus;
  bool get isLoading => _isLoading;

  /// Load dashboard data
  Future<void> loadDashboard() async {
    _isLoading = true;
    notifyListeners();

    try {
      _dashboardStats = await _adminService.getDashboardStats();
      _revenueChart = await _adminService.getRevenueChart();
      _topServices = await _adminService.getTopServices();
      _bookingsByStatus = await _adminService.getBookingsByStatus();
    } catch (e) {
      debugPrint('Error loading dashboard: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load users for management
  Future<void> loadUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _users = await _adminService.getAllUsers();
    } catch (e) {
      debugPrint('Error loading users: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load shops for management
  Future<void> loadShops() async {
    _isLoading = true;
    notifyListeners();

    try {
      _shops = await _adminService.getAllShops();
    } catch (e) {
      debugPrint('Error loading shops: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load services for management
  Future<void> loadServices() async {
    _isLoading = true;
    notifyListeners();

    try {
      _services = await _adminService.getAllServices();
    } catch (e) {
      debugPrint('Error loading services: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Filter users by role
  List<UserModel> getUsersByRole(UserRole role) {
    return _users.where((u) => u.role == role).toList();
  }
}
