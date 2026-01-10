import '../models/shop_model.dart';
import '../models/service_model.dart';
import '../models/barber_model.dart';
import '../mock/mock_shops.dart';
import '../mock/mock_services.dart';
import '../mock/mock_barbers.dart';

/// Fake shop service for mock data
/// TODO: Replace with real API calls when backend is ready
class FakeShopService {
  /// Get all shops
  Future<List<ShopModel>> getShops() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return MockShops.shops;
  }

  /// Get shop by ID
  Future<ShopModel?> getShopById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockShops.getById(id);
  }

  /// Get featured shops (top rated)
  Future<List<ShopModel>> getFeaturedShops({int limit = 5}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final shops = List<ShopModel>.from(MockShops.shops);
    shops.sort((a, b) => b.rating.compareTo(a.rating));
    return shops.take(limit).toList();
  }

  /// Search shops by name or address
  Future<List<ShopModel>> searchShops(String query) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final lowerQuery = query.toLowerCase();
    return MockShops.shops.where((shop) {
      return shop.name.toLowerCase().contains(lowerQuery) ||
          shop.address.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Get all services
  Future<List<ServiceModel>> getServices() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockServices.services;
  }

  /// Get services by shop ID
  Future<List<ServiceModel>> getServicesByShopId(String shopId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockServices.getByShopId(shopId);
  }

  /// Get service by ID
  Future<ServiceModel?> getServiceById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return MockServices.getById(id);
  }

  /// Get featured services
  Future<List<ServiceModel>> getFeaturedServices({int limit = 5}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return MockServices.services.take(limit).toList();
  }

  /// Get all barbers
  Future<List<BarberModel>> getBarbers() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockBarbers.barbers;
  }

  /// Get barbers by shop ID
  Future<List<BarberModel>> getBarbersByShopId(String shopId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockBarbers.getByShopId(shopId);
  }

  /// Get barber by ID
  Future<BarberModel?> getBarberById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return MockBarbers.getById(id);
  }

  /// Get available barbers for a shop
  Future<List<BarberModel>> getAvailableBarbers(String shopId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockBarbers.getAvailable(shopId);
  }
}
