import 'package:flutter/material.dart';
import '../data/models/shop_model.dart';
import '../data/models/service_model.dart';
import '../data/models/barber_model.dart';
import '../data/services/fake_shop_service.dart';

/// ShopProvider for managing shop, service, and barber data
class ShopProvider extends ChangeNotifier {
  final FakeShopService _shopService = FakeShopService();

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

  /// Get featured shops
  Future<List<ShopModel>> getFeaturedShops({int limit = 5}) async {
    return await _shopService.getFeaturedShops(limit: limit);
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
      _services = await _shopService.getServicesByShopId(shopId);
      _barbers = await _shopService.getBarbersByShopId(shopId);
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

  /// Get featured services
  Future<List<ServiceModel>> getFeaturedServices({int limit = 5}) async {
    return await _shopService.getFeaturedServices(limit: limit);
  }

  /// Load service details
  Future<void> loadServiceDetails(String serviceId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _selectedService = await _shopService.getServiceById(serviceId);
    } catch (e) {
      debugPrint('Error loading service: $e');
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

  /// Load available barbers
  Future<void> loadAvailableBarbers(String shopId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _barbers = await _shopService.getAvailableBarbers(shopId);
    } catch (e) {
      debugPrint('Error loading available barbers: $e');
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
}
