import '../models/shop_model.dart';

/// Mock shops for testing
class MockShops {
  MockShops._();

  static final List<ShopModel> shops = [
    const ShopModel(
      id: 'shop_1',
      name: 'Gentleman Barbershop',
      description: 'Tiệm cắt tóc nam cao cấp với phong cách hiện đại, mang đến trải nghiệm đẳng cấp cho quý ông.',
      address: '123 Nguyễn Huệ, Quận 1, TP.HCM',
      phone: '0281234567',
      imageUrl: 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=800',
      rating: 4.8,
      reviewCount: 256,
      openTime: '08:00',
      closeTime: '21:00',
      isOpen: true,
      images: [
        'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=800',
        'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=800',
        'https://images.unsplash.com/photo-1621605815971-fbc98d665033?w=800',
      ],
      latitude: 10.7731,
      longitude: 106.7030,
    ),
    const ShopModel(
      id: 'shop_2',
      name: 'Classic Barber House',
      description: 'Không gian vintage với dịch vụ cắt tóc truyền thống kết hợp hiện đại.',
      address: '456 Lê Lợi, Quận 1, TP.HCM',
      phone: '0282345678',
      imageUrl: 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=800',
      rating: 4.6,
      reviewCount: 189,
      openTime: '09:00',
      closeTime: '20:00',
      isOpen: true,
      images: [
        'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=800',
        'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=800',
      ],
      latitude: 10.7725,
      longitude: 106.6985,
    ),
    const ShopModel(
      id: 'shop_3',
      name: 'Modern Cut Studio',
      description: 'Studio cắt tóc với xu hướng mới nhất, đội ngũ stylist chuyên nghiệp.',
      address: '789 Hai Bà Trưng, Quận 3, TP.HCM',
      phone: '0283456789',
      imageUrl: 'https://images.unsplash.com/photo-1621605815971-fbc98d665033?w=800',
      rating: 4.9,
      reviewCount: 312,
      openTime: '08:30',
      closeTime: '21:30',
      isOpen: true,
      images: [
        'https://images.unsplash.com/photo-1621605815971-fbc98d665033?w=800',
        'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=800',
      ],
      latitude: 10.7850,
      longitude: 106.6900,
    ),
    const ShopModel(
      id: 'shop_4',
      name: 'Elite Barber Lounge',
      description: 'Trải nghiệm VIP với không gian sang trọng và dịch vụ premium.',
      address: '101 Đồng Khởi, Quận 1, TP.HCM',
      phone: '0284567890',
      imageUrl: 'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=800',
      rating: 4.7,
      reviewCount: 145,
      openTime: '09:00',
      closeTime: '22:00',
      isOpen: false,
      images: [],
      latitude: 10.7760,
      longitude: 106.7010,
    ),
  ];

  static ShopModel? getById(String id) {
    try {
      return shops.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
