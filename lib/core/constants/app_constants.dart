/// App constants for the barbershop app
class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'BarberShop';
  static const String appVersion = '1.0.0';

  // TODO: Replace with actual API base URL when backend is ready
  static const String apiBaseUrl = 'https://api.barbershop.com/v1';

  // Pagination
  static const int defaultPageSize = 20;

  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000;

  // Time slots configuration
  static const int openingHour = 8; // 8 AM
  static const int closingHour = 21; // 9 PM
  static const int slotDurationMinutes = 30;

  // Image placeholders
  static const String defaultAvatar = 'https://via.placeholder.com/150/1E3A5F/FFFFFF?text=User';
  static const String defaultShopImage = 'https://via.placeholder.com/400x200/1E3A5F/FFFFFF?text=Shop';
  static const String defaultServiceImage = 'https://via.placeholder.com/200/D4AF37/FFFFFF?text=Service';

  // Validation
  static const int minPasswordLength = 6;
  static const int otpLength = 6;
  static const int phoneLength = 10;

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';
}

/// User roles in the app
enum UserRole {
  customer,
  barber,
  admin,
}

/// Booking status
enum BookingStatus {
  pending,
  confirmed,
  completed,
  cancelled,
}

/// Order status
enum OrderStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled,
}

/// Notification types
enum NotificationType {
  booking,
  promotion,
  reminder,
  system,
  chat,
}
