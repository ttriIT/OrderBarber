import '../../core/api/api_client.dart';
import '../models/shop_model.dart';
import '../models/service_model.dart';
import '../models/barber_model.dart';

class ManagerService {
  final ApiClient _client;

  ManagerService({ApiClient? client}) : _client = client ?? apiClient;

  /// Get shops managed by the current manager
  Future<List<ShopModel>> getManagedShops() async {
    try {
      final response = await _client.get('/manager/shops');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ShopModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Update shop details
  Future<ShopModel?> updateShop(ShopModel shop) async {
    try {
      final response = await _client.put('/manager/shops/${shop.id}', data: shop.toJson());
      if (response.statusCode == 200) {
        return ShopModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Get services for a specific shop
  Future<List<ServiceModel>> getShopServices(String shopId) async {
    try {
      final response = await _client.get('/manager/shops/$shopId/services');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ServiceModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Add new service to shop
  Future<void> addService(String shopId, ServiceModel service) async {
    try {
      await _client.post('/manager/shops/$shopId/services', data: service.toJson());
    } catch (e) {
      rethrow;
    }
  }

  /// Update shop service
  Future<void> updateService(String shopId, ServiceModel service) async {
    try {
      await _client.put('/manager/shops/$shopId/services/${service.id}', data: service.toJson());
    } catch (e) {
      rethrow;
    }
  }

  /// Delete shop service
  Future<void> deleteService(String shopId, String serviceId) async {
    try {
      await _client.delete('/manager/shops/$shopId/services/$serviceId');
    } catch (e) {
      rethrow;
    }
  }

  /// Get barbers for a specific shop
  Future<List<BarberModel>> getShopBarbers(String shopId) async {
    try {
      final response = await _client.get('/manager/shops/$shopId/barbers');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => BarberModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }
}
