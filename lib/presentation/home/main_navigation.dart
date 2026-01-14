import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import 'customer_home_screen.dart';
import 'barber_home_screen.dart';
import 'admin_home_screen.dart';
import '../shop/shop_list_screen.dart';
import '../order/order_list_screen.dart';
import '../chat/chat_list_screen.dart';
import '../profile/profile_screen.dart';
import '../notification/notification_screen.dart';
import '../admin/user_management_screen.dart';
import '../admin/shop_management_screen.dart';
import '../admin/statistics_screen.dart';
import '../admin/promotion_management_screen.dart';
import '../manager/manager_dashboard_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load notifications
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userRole = authProvider.userRole;

    return Scaffold(
      body: _buildBody(userRole),
      bottomNavigationBar: _buildBottomNav(userRole),
    );
  }

  Widget _buildBody(UserRole? role) {
    switch (role) {
      case UserRole.customer:
        return _buildCustomerBody();
      case UserRole.barber:
        return _buildBarberBody();
      case UserRole.admin:
        return _buildAdminBody();
      case UserRole.manager:
        return _buildManagerBody();
      default:
        return _buildCustomerBody();
    }
  }

  Widget _buildCustomerBody() {
    final screens = [
      const CustomerHomeScreen(),
      const ShopListScreen(),
      const OrderListScreen(),
      const ChatListScreen(),
      const ProfileScreen(),
    ];
    return screens[_currentIndex];
  }

  Widget _buildBarberBody() {
    final screens = [
      const BarberHomeScreen(),
      const OrderListScreen(),
      const ChatListScreen(),
      const NotificationScreen(),
      const ProfileScreen(),
    ];
    return screens[_currentIndex];
  }

  Widget _buildAdminBody() {
    final screens = [
      const AdminHomeScreen(),
      const UserManagementScreen(),
      const PromotionManagementScreen(),
      const StatisticsScreen(),
      const ProfileScreen(),
    ];
    return screens[_currentIndex];
  }

  Widget _buildManagerBody() {
    final screens = [
      const ManagerDashboardScreen(),
      const ShopManagementScreen(),
      const OrderListScreen(),
      const ChatListScreen(),
      const ProfileScreen(),
    ];
    return screens[_currentIndex];
  }

  Widget _buildBottomNav(UserRole? role) {
    switch (role) {
      case UserRole.customer:
        return _buildCustomerNav();
      case UserRole.barber:
        return _buildBarberNav();
      case UserRole.admin:
        return _buildAdminNav();
      case UserRole.manager:
        return _buildManagerNav();
      default:
        return _buildCustomerNav();
    }
  }

  Widget _buildCustomerNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      type: BottomNavigationBarType.fixed,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Trang chủ',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.store_outlined),
          activeIcon: Icon(Icons.store),
          label: 'Tiệm',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined),
          activeIcon: Icon(Icons.calendar_today),
          label: 'Lịch hẹn',
        ),
        BottomNavigationBarItem(
          icon: _buildChatIcon(),
          activeIcon: _buildChatIcon(isActive: true),
          label: 'Chat',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outlined),
          activeIcon: Icon(Icons.person),
          label: 'Tài khoản',
        ),
      ],
    );
  }

  Widget _buildBarberNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      type: BottomNavigationBarType.fixed,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Trang chủ',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined),
          activeIcon: Icon(Icons.calendar_today),
          label: 'Lịch hẹn',
        ),
        BottomNavigationBarItem(
          icon: _buildChatIcon(),
          activeIcon: _buildChatIcon(isActive: true),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: _buildNotificationIcon(),
          activeIcon: _buildNotificationIcon(isActive: true),
          label: 'Thông báo',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outlined),
          activeIcon: Icon(Icons.person),
          label: 'Tài khoản',
        ),
      ],
    );
  }

  Widget _buildAdminNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outlined),
          activeIcon: Icon(Icons.people),
          label: 'Users',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.discount_outlined),
          activeIcon: Icon(Icons.discount),
          label: 'Khuyến mãi',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart_outlined),
          activeIcon: Icon(Icons.bar_chart),
          label: 'Thống kê',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outlined),
          activeIcon: Icon(Icons.person),
          label: 'Tài khoản',
        ),
      ],
    );
  }

  Widget _buildManagerNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      type: BottomNavigationBarType.fixed,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'M.Dashboard',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.store_outlined),
          activeIcon: Icon(Icons.store),
          label: 'Shops',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined),
          activeIcon: Icon(Icons.calendar_today),
          label: 'Bookings',
        ),
        BottomNavigationBarItem(
          icon: _buildChatIcon(),
          activeIcon: _buildChatIcon(isActive: true),
          label: 'Chat',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outlined),
          activeIcon: Icon(Icons.person),
          label: 'Tài khoản',
        ),
      ],
    );
  }

  Widget _buildNotificationIcon({bool isActive = false}) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        return Stack(
          children: [
            Icon(isActive ? Icons.notifications : Icons.notifications_outlined),
            if (provider.unreadCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    provider.unreadCount > 9 ? '9+' : '${provider.unreadCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildChatIcon({bool isActive = false}) {
    return Stack(
      children: [
        Icon(isActive ? Icons.chat : Icons.chat_outlined),
        // Mock unread indicator
        Positioned(
          right: 0,
          top: 0,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}
