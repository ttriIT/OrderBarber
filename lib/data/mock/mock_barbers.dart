import '../models/barber_model.dart';

/// Mock barbers for testing
class MockBarbers {
  MockBarbers._();

  static final List<BarberModel> barbers = [
    const BarberModel(
      id: 'barber_1',
      name: 'Phạm Minh Đức',
      phone: '0934567890',
      avatarUrl: 'https://i.pravatar.cc/150?img=11',
      shopId: 'shop_1',
      specialization: 'Senior Stylist - Chuyên kiểu tóc Âu Mỹ',
      rating: 4.9,
      reviewCount: 156,
      isAvailable: true,
      yearsOfExperience: 8,
      skills: ['Cắt tóc nam', 'Fade', 'Undercut', 'Tạo kiểu'],
    ),
    const BarberModel(
      id: 'barber_2',
      name: 'Hoàng Văn Em',
      phone: '0945678901',
      avatarUrl: 'https://i.pravatar.cc/150?img=12',
      shopId: 'shop_1',
      specialization: 'Master Barber - Chuyên cạo râu truyền thống',
      rating: 4.7,
      reviewCount: 98,
      isAvailable: true,
      yearsOfExperience: 5,
      skills: ['Cạo râu', 'Massage mặt', 'Cắt tóc cổ điển'],
    ),
    const BarberModel(
      id: 'barber_3',
      name: 'Ngô Thanh Phong',
      phone: '0956789012',
      avatarUrl: 'https://i.pravatar.cc/150?img=13',
      shopId: 'shop_1',
      specialization: 'Hair Colorist - Chuyên nhuộm tóc',
      rating: 4.8,
      reviewCount: 87,
      isAvailable: false,
      yearsOfExperience: 6,
      skills: ['Nhuộm tóc', 'Highlight', 'Balayage'],
    ),
    const BarberModel(
      id: 'barber_4',
      name: 'Trần Quốc Hùng',
      phone: '0967890123',
      avatarUrl: 'https://i.pravatar.cc/150?img=14',
      shopId: 'shop_2',
      specialization: 'Junior Stylist - Kiểu tóc Hàn Quốc',
      rating: 4.5,
      reviewCount: 45,
      isAvailable: true,
      yearsOfExperience: 3,
      skills: ['Kiểu Hàn', 'Two-block', 'Uốn tóc'],
    ),
    const BarberModel(
      id: 'barber_5',
      name: 'Lê Văn Khoa',
      phone: '0978901234',
      avatarUrl: 'https://i.pravatar.cc/150?img=15',
      shopId: 'shop_2',
      specialization: 'Senior Stylist - Tạo kiểu chuyên nghiệp',
      rating: 4.6,
      reviewCount: 112,
      isAvailable: true,
      yearsOfExperience: 7,
      skills: ['Cắt tóc nam', 'Tạo kiểu', 'Sấy phồng'],
    ),
    const BarberModel(
      id: 'barber_6',
      name: 'Đỗ Minh Tuấn',
      phone: '0989012345',
      avatarUrl: 'https://i.pravatar.cc/150?img=16',
      shopId: 'shop_3',
      specialization: 'Top Stylist - Kiểu tóc cao cấp',
      rating: 4.9,
      reviewCount: 203,
      isAvailable: true,
      yearsOfExperience: 10,
      skills: ['Cắt tóc VIP', 'Tư vấn phong cách', 'Điều trị tóc'],
    ),
  ];

  static List<BarberModel> getByShopId(String shopId) {
    return barbers.where((b) => b.shopId == shopId).toList();
  }

  static BarberModel? getById(String id) {
    try {
      return barbers.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<BarberModel> getAvailable(String shopId) {
    return barbers.where((b) => b.shopId == shopId && b.isAvailable).toList();
  }
}
