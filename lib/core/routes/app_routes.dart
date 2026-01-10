import 'package:flutter/material.dart';

// Auth screens
import '../../presentation/auth/splash_screen.dart';
import '../../presentation/auth/login_screen.dart';
import '../../presentation/auth/register_screen.dart';
import '../../presentation/auth/otp_screen.dart';
import '../../presentation/auth/forgot_password_screen.dart';

// Home screens
import '../../presentation/home/main_navigation.dart';

// Shop screens
import '../../presentation/shop/shop_list_screen.dart';
import '../../presentation/shop/shop_detail_screen.dart';
import '../../presentation/shop/service_list_screen.dart';
import '../../presentation/shop/service_detail_screen.dart';
import '../../presentation/shop/barber_selection_screen.dart';

// Booking screens
import '../../presentation/booking/booking_date_screen.dart';
import '../../presentation/booking/booking_time_screen.dart';
import '../../presentation/booking/booking_confirmation_screen.dart';
import '../../presentation/booking/booking_success_screen.dart';

// Order screens
import '../../presentation/order/order_list_screen.dart';
import '../../presentation/order/order_detail_screen.dart';

// Chat screens
import '../../presentation/chat/chat_list_screen.dart';
import '../../presentation/chat/chat_detail_screen.dart';

// Notification screen
import '../../presentation/notification/notification_screen.dart';

// Profile screens
import '../../presentation/profile/profile_screen.dart';
import '../../presentation/profile/edit_profile_screen.dart';
import '../../presentation/profile/change_password_screen.dart';

// Review screens
import '../../presentation/review/review_list_screen.dart';

// Admin screens
import '../../presentation/admin/admin_dashboard_screen.dart';
import '../../presentation/admin/user_management_screen.dart';
import '../../presentation/admin/shop_management_screen.dart';
import '../../presentation/admin/statistics_screen.dart';

class AppRoutes {
  // Auth routes
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String otp = '/otp';
  static const String forgotPassword = '/forgot-password';

  // Main navigation
  static const String main = '/main';

  // Shop routes
  static const String shopList = '/shop-list';
  static const String shopDetail = '/shop-detail';
  static const String serviceList = '/service-list';
  static const String serviceDetail = '/service-detail';
  static const String barberSelection = '/barber-selection';

  // Booking routes
  static const String bookingDate = '/booking-date';
  static const String bookingTime = '/booking-time';
  static const String bookingConfirmation = '/booking-confirmation';
  static const String bookingSuccess = '/booking-success';

  // Order routes
  static const String orderList = '/order-list';
  static const String orderDetail = '/order-detail';

  // Chat routes
  static const String chatList = '/chat-list';
  static const String chatDetail = '/chat-detail';

  // Notification
  static const String notifications = '/notifications';

  // Profile routes
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String changePassword = '/change-password';

  // Review
  static const String reviewList = '/review-list';

  // Admin routes
  static const String adminDashboard = '/admin-dashboard';
  static const String userManagement = '/user-management';
  static const String shopManagement = '/shop-management';
  static const String serviceManagement = '/service-management';
  static const String statistics = '/statistics';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Auth
      case splash:
        return _buildRoute(const SplashScreen(), settings);
      case login:
        return _buildRoute(const LoginScreen(), settings);
      case register:
        return _buildRoute(const RegisterScreen(), settings);
      case otp:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          OTPScreen(phone: args?['phone'] ?? ''),
          settings,
        );
      case forgotPassword:
        return _buildRoute(const ForgotPasswordScreen(), settings);

      // Main
      case main:
        return _buildRoute(const MainNavigation(), settings);

      // Shop
      case shopList:
        return _buildRoute(const ShopListScreen(), settings);
      case shopDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          ShopDetailScreen(shopId: args?['shopId'] ?? ''),
          settings,
        );
      case serviceList:
        return _buildRoute(const ServiceListScreen(), settings);
      case serviceDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          ServiceDetailScreen(serviceId: args?['serviceId'] ?? ''),
          settings,
        );
      case barberSelection:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          BarberSelectionScreen(shopId: args?['shopId'] ?? ''),
          settings,
        );

      // Booking
      case bookingDate:
        return _buildRoute(const BookingDateScreen(), settings);
      case bookingTime:
        return _buildRoute(const BookingTimeScreen(), settings);
      case bookingConfirmation:
        return _buildRoute(const BookingConfirmationScreen(), settings);
      case bookingSuccess:
        return _buildRoute(const BookingSuccessScreen(), settings);

      // Order
      case orderList:
        return _buildRoute(const OrderListScreen(), settings);
      case orderDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          OrderDetailScreen(bookingId: args?['bookingId'] ?? ''),
          settings,
        );

      // Chat
      case chatList:
        return _buildRoute(const ChatListScreen(), settings);
      case chatDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          ChatDetailScreen(
            recipientId: args?['recipientId'] ?? '',
            recipientName: args?['recipientName'] ?? '',
            recipientAvatar: args?['recipientAvatar'] ?? '',
          ),
          settings,
        );

      // Notifications
      case notifications:
        return _buildRoute(const NotificationScreen(), settings);

      // Profile
      case profile:
        return _buildRoute(const ProfileScreen(), settings);
      case editProfile:
        return _buildRoute(const EditProfileScreen(), settings);
      case changePassword:
        return _buildRoute(const ChangePasswordScreen(), settings);

      // Review
      case reviewList:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          ReviewListScreen(
            targetId: args?['targetId'] ?? '',
            targetType: args?['targetType'] ?? '',
          ),
          settings,
        );

      // Admin
      case adminDashboard:
        return _buildRoute(const AdminDashboardScreen(), settings);
      case userManagement:
        return _buildRoute(const UserManagementScreen(), settings);
      case shopManagement:
        return _buildRoute(const ShopManagementScreen(), settings);
      case statistics:
        return _buildRoute(const StatisticsScreen(), settings);

      default:
        return _buildRoute(
          Scaffold(
            body: Center(
              child: Text('Route không tồn tại: ${settings.name}'),
            ),
          ),
          settings,
        );
    }
  }

  static MaterialPageRoute _buildRoute(Widget page, RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
    );
  }
}
