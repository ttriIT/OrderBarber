import '../../core/api/api_client.dart';
import '../models/notification_model.dart';

class NotificationService {
  final ApiClient _client;

  NotificationService({ApiClient? client}) : _client = client ?? apiClient;

  /// Get all notifications
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _client.get('/notifications');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Get unread count
  Future<int> getUnreadCount() async {
    try {
      final response = await _client.get('/notifications/unread-count');
      if (response.statusCode == 200) {
        return response.data['count'] ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _client.put('/notifications/$notificationId/read');
    } catch (e) {
      // Ignore
    }
  }

  /// Mark all as read
  Future<void> markAllAsRead() async {
    try {
      await _client.put('/notifications/read-all');
    } catch (e) {
      // Ignore
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _client.delete('/notifications/$notificationId');
    } catch (e) {
      // Ignore
    }
  }
}
