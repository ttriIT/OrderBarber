import '../models/notification_model.dart';
import '../../core/constants/app_constants.dart';

/// Mock notifications for testing
class MockNotifications {
  MockNotifications._();

  static List<NotificationModel> getNotifications() {
    final now = DateTime.now();
    return [
      NotificationModel(
        id: 'notif_1',
        title: 'Lịch hẹn được xác nhận',
        message: 'Lịch hẹn của bạn tại Gentleman Barbershop vào 10:00 ngày mai đã được xác nhận.',
        type: NotificationType.booking,
        createdAt: now.subtract(const Duration(hours: 1)),
        isRead: false,
        targetId: 'booking_1',
      ),
      NotificationModel(
        id: 'notif_2',
        title: 'Khuyến mãi đặc biệt!',
        message: 'Giảm 20% tất cả dịch vụ trong tuần này. Đặt lịch ngay!',
        type: NotificationType.promotion,
        createdAt: now.subtract(const Duration(hours: 3)),
        isRead: false,
        imageUrl: 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=400',
      ),
      NotificationModel(
        id: 'notif_3',
        title: 'Nhắc nhở lịch hẹn',
        message: 'Đừng quên lịch hẹn của bạn vào lúc 14:30 ngày 15/01 tại Classic Barber House.',
        type: NotificationType.reminder,
        createdAt: now.subtract(const Duration(days: 1)),
        isRead: true,
        targetId: 'booking_2',
      ),
      NotificationModel(
        id: 'notif_4',
        title: 'Đánh giá dịch vụ',
        message: 'Hãy đánh giá trải nghiệm của bạn tại Modern Cut Studio!',
        type: NotificationType.system,
        createdAt: now.subtract(const Duration(days: 2)),
        isRead: true,
        targetId: 'booking_4',
      ),
      NotificationModel(
        id: 'notif_5',
        title: 'Tin nhắn mới',
        message: 'Thợ cắt tóc Phạm Minh Đức đã gửi tin nhắn cho bạn.',
        type: NotificationType.chat,
        createdAt: now.subtract(const Duration(hours: 5)),
        isRead: false,
        targetId: 'barber_1',
      ),
      NotificationModel(
        id: 'notif_6',
        title: 'Chào mừng thành viên mới!',
        message: 'Cảm ơn bạn đã đăng ký. Nhận ngay voucher giảm 50K cho lần đặt đầu tiên.',
        type: NotificationType.promotion,
        createdAt: now.subtract(const Duration(days: 7)),
        isRead: true,
      ),
    ];
  }

  static int getUnreadCount() {
    return getNotifications().where((n) => !n.isRead).length;
  }

  static List<NotificationModel> getByType(NotificationType type) {
    return getNotifications().where((n) => n.type == type).toList();
  }
}
