import '../models/promotion_model.dart';

class MockPromotions {
  static List<PromotionModel> _promotions = [
    PromotionModel(
      id: '1',
      title: 'Chào mừng khách mới',
      description: 'Giảm giá 20% cho khách hàng lần đầu tiên đặt lịch tại BarberShop.',
      code: 'WELCOME20',
      discountPercentage: 20,
      imageUrl: 'https://via.placeholder.com/400x200/D4AF37/FFFFFF?text=Welcome+20%',
      expiryDate: DateTime.now().add(const Duration(days: 30)),
      isActive: true,
    ),
    PromotionModel(
      id: '2',
      title: 'Siêu sale cuối tuần',
      description: 'Cắt tóc thả ga không lo về giá mỗi thứ 7 và Chủ nhật hàng tuần.',
      code: 'WEEKEND15',
      discountPercentage: 15,
      imageUrl: 'https://via.placeholder.com/400x200/1E3A5F/FFFFFF?text=Weekend+15%',
      expiryDate: DateTime.now().add(const Duration(days: 15)),
      isActive: true,
    ),
    PromotionModel(
      id: '3',
      title: 'Ưu đãi sinh nhật',
      description: 'Tặng ngay lượt cắt tóc miễn phí hoặc giảm 50% trong tháng sinh nhật của bạn.',
      code: 'BDAY50',
      discountPercentage: 50,
      imageUrl: 'https://via.placeholder.com/400x200/FF5252/FFFFFF?text=Birthday+Discount',
      expiryDate: DateTime.now().add(const Duration(days: 365)),
      isActive: true,
    ),
  ];

  static List<PromotionModel> get promotions => _promotions;

  static void addPromotion(PromotionModel promotion) {
    _promotions.add(promotion);
  }

  static void updatePromotion(PromotionModel promotion) {
    final index = _promotions.indexWhere((p) => p.id == promotion.id);
    if (index != -1) {
      _promotions[index] = promotion;
    }
  }

  static void deletePromotion(String id) {
    _promotions.removeWhere((p) => p.id == id);
  }
}
