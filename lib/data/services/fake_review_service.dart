import '../models/review_model.dart';

/// Fake review service for mock reviews
/// TODO: Replace with real API calls when backend is ready
class FakeReviewService {
  // In-memory storage for reviews
  final List<ReviewModel> _reviews = [];

  FakeReviewService() {
    _initMockReviews();
  }

  void _initMockReviews() {
    final now = DateTime.now();
    _reviews.addAll([
      ReviewModel(
        id: 'review_1',
        customerId: 'customer_1',
        customerName: 'Nguyễn Văn An',
        customerAvatar: 'https://i.pravatar.cc/150?img=1',
        targetId: 'barber_1',
        targetType: 'barber',
        rating: 5,
        comment: 'Cắt tóc rất đẹp, anh thợ tư vấn kiểu tóc phù hợp với khuôn mặt. Rất hài lòng!',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      ReviewModel(
        id: 'review_2',
        customerId: 'customer_2',
        customerName: 'Trần Thị Bình',
        customerAvatar: 'https://i.pravatar.cc/150?img=5',
        targetId: 'barber_1',
        targetType: 'barber',
        rating: 4,
        comment: 'Dịch vụ tốt, không gian sạch sẽ. Thợ cắt khá nhanh.',
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      ReviewModel(
        id: 'review_3',
        customerId: 'customer_3',
        customerName: 'Lê Hoàng Cường',
        customerAvatar: 'https://i.pravatar.cc/150?img=3',
        targetId: 'service_1',
        targetType: 'service',
        rating: 5,
        comment: 'Dịch vụ cắt tóc cơ bản nhưng chất lượng rất tốt. Sẽ quay lại!',
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      ReviewModel(
        id: 'review_4',
        customerId: 'customer_1',
        customerName: 'Nguyễn Văn An',
        customerAvatar: 'https://i.pravatar.cc/150?img=1',
        targetId: 'barber_6',
        targetType: 'barber',
        rating: 5,
        comment: 'Combo VIP đáng đồng tiền! Massage rất thư giãn, tóc đẹp.',
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      ReviewModel(
        id: 'review_5',
        customerId: 'customer_2',
        customerName: 'Trần Thị Bình',
        customerAvatar: 'https://i.pravatar.cc/150?img=5',
        targetId: 'service_2',
        targetType: 'service',
        rating: 4.5,
        comment: 'Gội đầu rất thư giãn, tinh dầu thơm. Cắt tóc gọn gàng.',
        createdAt: now.subtract(const Duration(days: 14)),
      ),
    ]);
  }

  /// Get reviews for a target (barber or service)
  Future<List<ReviewModel>> getReviews({
    required String targetId,
    required String targetType,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _reviews
        .where((r) => r.targetId == targetId && r.targetType == targetType)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get average rating for a target
  Future<double> getAverageRating({
    required String targetId,
    required String targetType,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final reviews = _reviews.where((r) => r.targetId == targetId && r.targetType == targetType).toList();
    if (reviews.isEmpty) return 0;
    final sum = reviews.fold<double>(0, (sum, r) => sum + r.rating);
    return sum / reviews.length;
  }

  /// Add a new review
  Future<ReviewModel> addReview({
    required String customerId,
    required String customerName,
    required String customerAvatar,
    required String targetId,
    required String targetType,
    required double rating,
    required String comment,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final review = ReviewModel(
      id: 'review_${DateTime.now().millisecondsSinceEpoch}',
      customerId: customerId,
      customerName: customerName,
      customerAvatar: customerAvatar,
      targetId: targetId,
      targetType: targetType,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );

    _reviews.add(review);
    return review;
  }

  /// Get customer's reviews
  Future<List<ReviewModel>> getCustomerReviews(String customerId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _reviews.where((r) => r.customerId == customerId).toList();
  }
}
