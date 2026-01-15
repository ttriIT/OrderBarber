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
      return [];
    }
  }

  /// Get staff (barbers) for a specific shop
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

  /// Search shops (Client-side filtering as fallback if no search endpoint)
  Future<List<ShopModel>> searchShops(String query) async {
    try {
      final shops = await getShops();
      return shops.where((s) => s.name.toLowerCase().contains(query.toLowerCase())).toList();
    } catch (e) {
      return [];
    }
  }
}
