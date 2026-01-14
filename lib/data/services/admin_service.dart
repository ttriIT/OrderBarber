import '../../core/api/api_client.dart';
import '../models/promotion_model.dart';
import '../models/user_model.dart';
import '../../core/constants/app_constants.dart';

class AdminService {
  final ApiClient _client;

  AdminService({ApiClient? client}) : _client = client ?? apiClient;

  /// Get dashboard statistics
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _client.get('/admin/stats');
      if (response.statusCode == 200) {
        return response.data;
      }
      return {};
    } catch (e) {
      rethrow;
    }
  }

  /// Get revenue by date range
  Future<List<Map<String, dynamic>>> getRevenueChart() async {
    try {
      final response = await _client.get('/admin/revenue-chart');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get top services by bookings
  Future<List<Map<String, dynamic>>> getTopServices() async {
    try {
      final response = await _client.get('/admin/top-services');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get all users for management
  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await _client.get('/admin/users');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => UserModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }



  /// Get booking summary by status
  Future<Map<BookingStatus, int>> getBookingsByStatus() async {
    try {
      final response = await _client.get('/admin/bookings-status');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        return data.map((key, value) => MapEntry(
          BookingStatus.values.firstWhere((s) => s.name == key, orElse: () => BookingStatus.pending),
          value as int,
        ));
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  /// Get all promotions for management
  Future<List<PromotionModel>> getAllPromotions() async {
    try {
      final response = await _client.get('/admin/promotions');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => PromotionModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Add new promotion
  Future<void> addPromotion(PromotionModel promotion) async {
    try {
      await _client.post('/admin/promotions', data: promotion.toJson());
    } catch (e) {
      rethrow;
    }
  }

  /// Update promotion
  Future<void> updatePromotion(PromotionModel promotion) async {
    try {
      await _client.put('/admin/promotions/${promotion.id}', data: promotion.toJson());
    } catch (e) {
      rethrow;
    }
  }

  /// Delete promotion
  Future<void> deletePromotion(String id) async {
    try {
      await _client.delete('/admin/promotions/$id');
    } catch (e) {
      rethrow;
    }
  }
}
