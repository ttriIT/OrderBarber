using appcattoc.DTOs.Notifications;

namespace appcattoc.Services;

public interface INotificationService
{
    Task<List<NotificationResponse>> GetUserNotificationsAsync(int userId);
    Task<bool> MarkAsReadAsync(int userId, int notificationId);
    Task CreateNotificationAsync(CreateNotificationRequest request);
}
