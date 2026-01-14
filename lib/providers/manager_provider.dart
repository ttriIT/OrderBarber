import 'package:flutter/material.dart';
import '../data/models/shop_model.dart';
import '../data/models/service_model.dart';
import '../data/models/barber_model.dart';
import '../data/services/manager_service.dart';

class ManagerProvider extends ChangeNotifier {
  final ManagerService _managerService = ManagerService();

  List<ShopModel> _managedShops = [];
  List<ServiceModel> _currentShopServices = [];
  List<BarberModel> _currentShopBarbers = [];
  ShopModel? _selectedShop;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<ShopModel> get managedShops => _managedShops;
  List<ServiceModel> get currentShopServices => _currentShopServices;
  List<BarberModel> get currentShopBarbers => _currentShopBarbers;
  ShopModel? get selectedShop => _selectedShop;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load shops managed by the manager
  Future<void> loadManagedShops() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _managedShops = await _managerService.getManagedShops();
      if (_managedShops.isNotEmpty && _selectedShop == null) {
        _selectedShop = _managedShops.first;
      }
    } catch (e) {
      _errorMessage = 'Lỗi khi tải danh sách cửa hàng: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Select a shop to manage
  void selectShop(ShopModel shop) {
    _selectedShop = shop;
    _currentShopServices = [];
    _currentShopBarbers = [];
    notifyListeners();
    loadShopData(shop.id);
  }

  /// Load services and barbers for a specific shop
  Future<void> loadShopData(String shopId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentShopServices = await _managerService.getShopServices(shopId);
      _currentShopBarbers = await _managerService.getShopBarbers(shopId);
    } catch (e) {
      _errorMessage = 'Lỗi khi tải dữ liệu cửa hàng: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Update shop details
  Future<bool> updateShop(ShopModel shop) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updated = await _managerService.updateShop(shop);
      if (updated != null) {
        final index = _managedShops.indexWhere((s) => s.id == shop.id);
        if (index != -1) {
          _managedShops[index] = updated;
          if (_selectedShop?.id == updated.id) {
            _selectedShop = updated;
          }
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = 'Cập nhật cửa hàng thất bại: $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Service management methods
  Future<void> addService(ServiceModel service) async {
    if (_selectedShop == null) return;
    try {
      await _managerService.addService(_selectedShop!.id, service);
      await loadShopData(_selectedShop!.id);
    } catch (e) {
      _errorMessage = 'Thêm dịch vụ thất bại: $e';
      notifyListeners();
    }
  }

  Future<void> updateService(ServiceModel service) async {
    if (_selectedShop == null) return;
    try {
      await _managerService.updateService(_selectedShop!.id, service);
      await loadShopData(_selectedShop!.id);
    } catch (e) {
      _errorMessage = 'Cập nhật dịch vụ thất bại: $e';
      notifyListeners();
    }
  }

  Future<void> deleteService(String serviceId) async {
    if (_selectedShop == null) return;
    try {
      await _managerService.deleteService(_selectedShop!.id, serviceId);
      await loadShopData(_selectedShop!.id);
    } catch (e) {
      _errorMessage = 'Xóa dịch vụ thất bại: $e';
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
