import '../../core/api/api_client.dart';
import '../models/shop_model.dart';
import '../models/service_model.dart';
import '../models/barber_model.dart';

class ShopService {
  final ApiClient _client;

  ShopService({ApiClient? client}) : _client = client ?? apiClient;

  /// Get all shops
  Future<List<ShopModel>> getShops() async {
    try {
      final response = await _client.get('/Shops');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ShopModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Get featured shops (Assuming /Shops supports query params or dedicated endpoint, using /Shops for now if featured endpoint not confirmed, or keep if likely exists)
  // Swagger didn't explicitly show featured, but common. Keeping /Shops/featured but capitalization.
  Future<List<ShopModel>> getFeaturedShops({int limit = 5}) async {
    try {
      // Trying common convention or query param on main? 
      // Safe bet: use /Shops and filter client side if needed, or assume backend filters.
      // Reverting to /Shops for now as verified endpoint.
      final response = await _client.get('/Shops'); 
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ShopModel.fromJson(json)).take(limit).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get shop by ID
  Future<ShopModel?> getShopById(String shopId) async {
    try {
      final response = await _client.get('/Shops/$shopId');
      if (response.statusCode == 200) {
        return ShopModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Search shops
  Future<List<ShopModel>> searchShops(String query) async {
    try {
      // Assuming /Shops supports search or client side filtering for now if endpoint missing
      final response = await _client.get('/Shops'); 
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        // Simple client-side search if API doesn't support it directly yet for safety
        final shops = data.map((json) => ShopModel.fromJson(json)).toList();
        return shops.where((s) => s.name.toLowerCase().contains(query.toLowerCase())).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get all services
  Future<List<ServiceModel>> getServices() async {
    try {
      final response = await _client.get('/Services');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ServiceModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Get services by shop ID
  Future<List<ServiceModel>> getServicesByShopId(String shopId) async {
    try {
      final response = await _client.get('/Shops/$shopId/services');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ServiceModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get service by ID
  Future<ServiceModel?> getServiceById(String serviceId) async {
    try {
      // Swagger didn't show /Services/{id}, usually implies generic GET
      // Assuming /Services/{id} exists
      final response = await _client.get('/Services/$serviceId');
      if (response.statusCode == 200) {
        return ServiceModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Get featured services
  Future<List<ServiceModel>> getFeaturedServices({int limit = 5}) async {
    try {
       final response = await _client.get('/Services');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ServiceModel.fromJson(json)).take(limit).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get barbers by shop ID (Mapped to /Shops/{id}/staff)
  Future<List<BarberModel>> getBarbersByShopId(String shopId) async {
    try {
      final response = await _client.get('/Shops/$shopId/staff');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => BarberModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get available barbers for a shop and time
  Future<List<BarberModel>> getAvailableBarbers(String shopId) async {
    try {
       // Using generic staff endpoint for now
      final response = await _client.get('/Shops/$shopId/staff');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => BarberModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
