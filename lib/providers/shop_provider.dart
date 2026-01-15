import 'package:flutter/material.dart';
import '../data/models/shop_model.dart';
import '../data/models/service_model.dart';
import '../data/models/barber_model.dart';
import '../data/services/shop_service.dart';

/// ShopProvider for managing shop, service, and barber data
class ShopProvider extends ChangeNotifier {
  final ShopService _shopService = ShopService();

  List<ShopModel> _shops = [];
  List<ServiceModel> _services = [];
  List<BarberModel> _barbers = [];
  ShopModel? _selectedShop;
  ServiceModel? _selectedService;
  BarberModel? _selectedBarber;
  bool _isLoading = false;

  // Getters
  List<ShopModel> get shops => _shops;
  List<ServiceModel> get services => _services;
  List<BarberModel> get barbers => _barbers;
  ShopModel? get selectedShop => _selectedShop;
  ServiceModel? get selectedService => _selectedService;
  BarberModel? get selectedBarber => _selectedBarber;
  bool get isLoading => _isLoading;

  /// Load all shops
  Future<void> loadShops() async {
    _isLoading = true;
    notifyListeners();

    try {
      _shops = await _shopService.getShops();
    } catch (e) {
      debugPrint('Error loading shops: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Search shops
  Future<List<ShopModel>> searchShops(String query) async {
    return await _shopService.searchShops(query);
  }

  /// Load shop details
  Future<void> loadShopDetails(String shopId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _selectedShop = await _shopService.getShopById(shopId);
      // In Swagger, there might not be a direct "services by shop" yet, 
      // but we use the common pattern if it exists or fallback to general services
      _barbers = await _shopService.getBarbersByShopId(shopId);
      // Load general services for now as shop-specific might not be ready
      if (_services.isEmpty) {
        _services = await _shopService.getServices();
      }
    } catch (e) {
      debugPrint('Error loading shop details: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load all services
  Future<void> loadServices() async {
    _isLoading = true;
    notifyListeners();

    try {
      _services = await _shopService.getServices();
    } catch (e) {
      debugPrint('Error loading services: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load barbers for a shop
  Future<void> loadBarbers(String shopId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _barbers = await _shopService.getBarbersByShopId(shopId);
    } catch (e) {
      debugPrint('Error loading barbers: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Select shop
  void selectShop(ShopModel shop) {
    _selectedShop = shop;
    notifyListeners();
  }

  /// Select service
  void selectService(ServiceModel service) {
    _selectedService = service;
    notifyListeners();
  }

  /// Select barber
  void selectBarber(BarberModel barber) {
    _selectedBarber = barber;
    notifyListeners();
  }

  /// Clear selections
  void clearSelections() {
    _selectedShop = null;
    _selectedService = null;
    _selectedBarber = null;
    notifyListeners();
  }

  /// Get featured shops (client-side limit)
  Future<List<ShopModel>> getFeaturedShops({int limit = 5}) async {
    try {
      final allShops = await _shopService.getShops();
      return allShops.take(limit).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get featured services (client-side limit)
  Future<List<ServiceModel>> getFeaturedServices({int limit = 5}) async {
    try {
      final allServices = await _shopService.getServices();
      return allServices.take(limit).toList();
    } catch (e) {
      return [];
    }
  }

  /// Load service details
  Future<void> loadServiceDetails(String serviceId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Find within loaded services first
      try {
        _selectedService = _services.firstWhere((s) => s.id == serviceId);
      } catch (_) {
        // If not found, force reload all services (API might not have single service endpoint exposed yet)
        await loadServices();
        _selectedService = _services.firstWhere((s) => s.id == serviceId);
      }
    } catch (e) {
      debugPrint('Error loading service details: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
