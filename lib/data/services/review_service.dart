import '../../core/api/api_client.dart';
import '../models/review_model.dart';

class ReviewService {
  final ApiClient _client;

  ReviewService({ApiClient? client}) : _client = client ?? apiClient;

  /// Get reviews for a target
  Future<List<ReviewModel>> getReviews({
    required String targetId,
    required String targetType,
  }) async {
    try {
      final response = await _client.get('/reviews', queryParameters: {
        'targetId': targetId,
        'targetType': targetType,
      });
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ReviewModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Get average rating for a target
  Future<double> getAverageRating({
    required String targetId,
    required String targetType,
  }) async {
    try {
      final response = await _client.get('/reviews/average', queryParameters: {
        'targetId': targetId,
        'targetType': targetType,
      });
      if (response.statusCode == 200) {
        return (response.data['average'] ?? 0).toDouble();
      }
      return 0;
    } catch (e) {
      return 0;
    }
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
    try {
      final response = await _client.post('/reviews', data: {
        'customerId': customerId,
        'customerName': customerName,
        'customerAvatar': customerAvatar,
        'targetId': targetId,
        'targetType': targetType,
        'rating': rating,
        'comment': comment,
        'createdAt': DateTime.now().toIso8601String(),
      });
      return ReviewModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get customer's reviews
  Future<List<ReviewModel>> getCustomerReviews(String customerId) async {
    try {
      final response = await _client.get('/customers/$customerId/reviews');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ReviewModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
  /// Report a review
  Future<bool> reportReview(String reviewId, String reason) async {
    try {
      final response = await _client.post('/reviews/$reviewId/report', data: {'reason': reason});
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
