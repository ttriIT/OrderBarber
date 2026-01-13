import '../models/promotion_model.dart';
import '../models/user_model.dart';
import '../models/shop_model.dart';
import '../models/service_model.dart';
import '../mock/mock_users.dart';
import '../mock/mock_shops.dart';
import '../mock/mock_services.dart';
import '../mock/mock_bookings.dart';
import '../mock/mock_promotions.dart';
import '../../core/constants/app_constants.dart';

/// Fake admin service for dashboard and management
/// TODO: Replace with real API calls when backend is ready
class FakeAdminService {
  /// Get dashboard statistics
  Future<Map<String, dynamic>> getDashboardStats() async {
    await Future.delayed(const Duration(milliseconds: 600));

    final bookings = MockBookings.getBookings();
    final completedBookings = bookings.where((b) => b.status == BookingStatus.completed).toList();
    final totalRevenue = completedBookings.fold<double>(0, (sum, b) => sum + b.totalPrice);

    return {
      'totalUsers': MockUsers.all.length,
      'totalCustomers': MockUsers.customers.length,
      'totalBarbers': MockUsers.barbers.length,
      'totalShops': MockShops.shops.length,
      'totalServices': MockServices.services.length,
      'totalBookings': bookings.length,
      'completedBookings': completedBookings.length,
      'pendingBookings': bookings.where((b) => b.status == BookingStatus.pending).length,
      'cancelledBookings': bookings.where((b) => b.status == BookingStatus.cancelled).length,
      'totalRevenue': totalRevenue,
      'todayRevenue': 450000, // Mock
      'monthlyRevenue': 15000000, // Mock
    };
  }

  /// Get revenue by date range (mock)
  Future<List<Map<String, dynamic>>> getRevenueChart() async {
    await Future.delayed(const Duration(milliseconds: 400));

    final now = DateTime.now();
    return List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      return {
        'date': '${date.day}/${date.month}',
        'revenue': (500000 + (index * 100000) + (DateTime.now().second * 10000)).toDouble(),
      };
    });
  }

  /// Get top services by bookings
  Future<List<Map<String, dynamic>>> getTopServices() async {
    await Future.delayed(const Duration(milliseconds: 400));

    return [
      {'name': 'Cắt tóc nam cơ bản', 'count': 45, 'revenue': 3600000},
      {'name': 'Combo VIP', 'count': 28, 'revenue': 8400000},
      {'name': 'Cắt tóc + Gội đầu', 'count': 35, 'revenue': 4200000},
      {'name': 'Uốn tóc Hàn Quốc', 'count': 15, 'revenue': 5250000},
      {'name': 'Nhuộm tóc', 'count': 20, 'revenue': 5000000},
    ];
  }

  /// Get all users for management
  Future<List<UserModel>> getAllUsers() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockUsers.all;
  }

  /// Get all shops for management
  Future<List<ShopModel>> getAllShops() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return MockShops.shops;
  }

  /// Get all services for management
  Future<List<ServiceModel>> getAllServices() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return MockServices.services;
  }

  /// Get booking summary by status
  Future<Map<BookingStatus, int>> getBookingsByStatus() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final bookings = MockBookings.getBookings();
    return {
      BookingStatus.pending: bookings.where((b) => b.status == BookingStatus.pending).length,
      BookingStatus.confirmed: bookings.where((b) => b.status == BookingStatus.confirmed).length,
      BookingStatus.completed: bookings.where((b) => b.status == BookingStatus.completed).length,
      BookingStatus.cancelled: bookings.where((b) => b.status == BookingStatus.cancelled).length,
    };
  }

  /// Get all promotions for management
  Future<List<PromotionModel>> getAllPromotions() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return MockPromotions.promotions;
  }

  /// Add new promotion
  Future<void> addPromotion(PromotionModel promotion) async {
    await Future.delayed(const Duration(milliseconds: 500));
    MockPromotions.addPromotion(promotion);
  }

  /// Update promotion
  Future<void> updatePromotion(PromotionModel promotion) async {
    await Future.delayed(const Duration(milliseconds: 500));
    MockPromotions.updatePromotion(promotion);
  }

  /// Delete promotion
  Future<void> deletePromotion(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    MockPromotions.deletePromotion(id);
  }
}
