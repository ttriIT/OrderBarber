import '../models/notification_model.dart';
import '../mock/mock_notifications.dart';
import '../../core/constants/app_constants.dart';

/// Fake notification service for mock notifications
/// TODO: Replace with real push notifications when backend is ready
class FakeNotificationService {
  // In-memory storage
  List<NotificationModel> _notifications = [];

  FakeNotificationService() {
    _notifications = List.from(MockNotifications.getNotifications());
  }

  /// Get all notifications
  Future<List<NotificationModel>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.from(_notifications)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get unread count
  Future<int> getUnreadCount() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _notifications.where((n) => !n.isRead).length;
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  /// Mark all as read
  Future<void> markAllAsRead() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _notifications.removeWhere((n) => n.id == notificationId);
  }

  /// Add new notification (for testing)
  Future<void> addNotification(NotificationModel notification) async {
    _notifications.insert(0, notification);
  }

  /// Create booking reminder notification
  Future<void> createBookingReminder({
    required String bookingId,
    required String shopName,
    required String time,
    required DateTime date,
  }) async {
    final notification = NotificationModel(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Nhắc nhở lịch hẹn',
      message: 'Đừng quên lịch hẹn của bạn vào lúc $time tại $shopName.',
      type: NotificationType.reminder,
      createdAt: DateTime.now(),
      isRead: false,
      targetId: bookingId,
    );
    await addNotification(notification);
  }
}
