import '../models/service_model.dart';

/// Mock services for testing
class MockServices {
  MockServices._();

  static final List<ServiceModel> services = [
    const ServiceModel(
      id: 'service_1',
      name: 'Cắt tóc nam cơ bản',
      description: 'Cắt tóc nam theo yêu cầu, tư vấn kiểu tóc phù hợp với khuôn mặt.',
      price: 80000,
      durationMinutes: 30,
      imageUrl: 'https://images.unsplash.com/photo-1599351431202-1e0f0137899a?w=400',
      shopId: 'shop_1',
      category: 'haircut',
    ),
    const ServiceModel(
      id: 'service_2',
      name: 'Cắt tóc + Gội đầu massage',
      description: 'Combo cắt tóc kèm gội đầu thư giãn với tinh dầu cao cấp.',
      price: 120000,
      durationMinutes: 45,
      imageUrl: 'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=400',
      shopId: 'shop_1',
      category: 'combo',
    ),
    const ServiceModel(
      id: 'service_3',
      name: 'Cạo râu + Massage mặt',
      description: 'Cạo râu truyền thống với khăn nóng và massage mặt thư giãn.',
      price: 70000,
      durationMinutes: 25,
      imageUrl: 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=400',
      shopId: 'shop_1',
      category: 'shave',
    ),
    const ServiceModel(
      id: 'service_4',
      name: 'Nhuộm tóc',
      description: 'Nhuộm tóc với thuốc nhuộm cao cấp, nhiều màu sắc thời trang.',
      price: 250000,
      durationMinutes: 90,
      imageUrl: 'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=400',
      shopId: 'shop_1',
      category: 'color',
    ),
    const ServiceModel(
      id: 'service_5',
      name: 'Uốn tóc Hàn Quốc',
      description: 'Uốn tóc theo phong cách Hàn Quốc, giữ nếp lâu, không hại tóc.',
      price: 350000,
      durationMinutes: 120,
      imageUrl: 'https://images.unsplash.com/photo-1605497788044-5a32c7078486?w=400',
      shopId: 'shop_2',
      category: 'perm',
    ),
    const ServiceModel(
      id: 'service_6',
      name: 'Combo VIP',
      description: 'Gói dịch vụ cao cấp: Cắt + Gội + Massage + Cạo mặt + Đắp mặt nạ.',
      price: 300000,
      durationMinutes: 90,
      imageUrl: 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=400',
      shopId: 'shop_3',
      category: 'combo',
    ),
    const ServiceModel(
      id: 'service_7',
      name: 'Tạo kiểu + Sấy',
      description: 'Tạo kiểu tóc theo trend và sấy tạo phồng chuyên nghiệp.',
      price: 100000,
      durationMinutes: 30,
      imageUrl: 'https://images.unsplash.com/photo-1621605815971-fbc98d665033?w=400',
      shopId: 'shop_2',
      category: 'styling',
    ),
    const ServiceModel(
      id: 'service_8',
      name: 'Gội đầu dưỡng sinh',
      description: 'Gội đầu với thảo dược thiên nhiên, massage đầu vai gáy.',
      price: 60000,
      durationMinutes: 25,
      imageUrl: 'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=400',
      shopId: 'shop_3',
      category: 'wash',
    ),
  ];

  static List<ServiceModel> getByShopId(String shopId) {
    return services.where((s) => s.shopId == shopId).toList();
  }

  static ServiceModel? getById(String id) {
    try {
      return services.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<ServiceModel> getByCategory(String category) {
    return services.where((s) => s.category == category).toList();
  }
}
