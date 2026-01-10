import 'package:flutter/material.dart';
import '../data/models/review_model.dart';
import '../data/services/fake_review_service.dart';

/// ReviewProvider for managing reviews and ratings
class ReviewProvider extends ChangeNotifier {
  final FakeReviewService _reviewService = FakeReviewService();

  List<ReviewModel> _reviews = [];
  double _averageRating = 0;
  bool _isLoading = false;

  // Getters
  List<ReviewModel> get reviews => _reviews;
  double get averageRating => _averageRating;
  bool get isLoading => _isLoading;

  /// Load reviews for a target (barber or service)
  Future<void> loadReviews({
    required String targetId,
    required String targetType,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _reviews = await _reviewService.getReviews(
        targetId: targetId,
        targetType: targetType,
      );
      _averageRating = await _reviewService.getAverageRating(
        targetId: targetId,
        targetType: targetType,
      );
    } catch (e) {
      debugPrint('Error loading reviews: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Add a new review
  Future<bool> addReview({
    required String customerId,
    required String customerName,
    required String customerAvatar,
    required String targetId,
    required String targetType,
    required double rating,
    required String comment,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final review = await _reviewService.addReview(
        customerId: customerId,
        customerName: customerName,
        customerAvatar: customerAvatar,
        targetId: targetId,
        targetType: targetType,
        rating: rating,
        comment: comment,
      );

      _reviews.insert(0, review);
      _averageRating = await _reviewService.getAverageRating(
        targetId: targetId,
        targetType: targetType,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding review: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Load customer's reviews
  Future<void> loadCustomerReviews(String customerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _reviews = await _reviewService.getCustomerReviews(customerId);
    } catch (e) {
      debugPrint('Error loading customer reviews: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Clear reviews
  void clearReviews() {
    _reviews = [];
    _averageRating = 0;
    notifyListeners();
  }
}
