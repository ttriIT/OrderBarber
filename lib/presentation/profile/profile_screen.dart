import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../data/models/barber_model.dart';
import '../../data/models/user_model.dart';
import '../../core/constants/app_constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        final role = user?.role ?? UserRole.customer;
        
        // Initialize barber details if role is barber
        BarberModel? barberDetails;
        if (role == UserRole.barber && user != null) {
          barberDetails = BarberModel(
            id: user.id,
            name: user.name,
            phone: user.phone,
            avatarUrl: user.avatarUrl,
            shopId: '', // Should be fetched from API
            specialization: 'Stylist',
            rating: 5.0,
            reviewCount: 0,
            skills: ['Cắt tóc nam', 'Tạo kiểu'],
            yearsOfExperience: 5,
          );
        }

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(user),

                  // Role-specific sections
                  if (role == UserRole.barber && barberDetails != null) ...[
                    _buildSectionHeader('Kỹ năng'),
                    _buildSkillsList(barberDetails.skills),
                    
                    _buildSectionHeader('Kinh nghiệm'),
                    _buildInfoCard(
                      icon: Icons.work_history_outlined,
                      title: 'Thâm niên',
                      value: '${barberDetails.yearsOfExperience} năm kinh nghiệm',
                    ),
                  ],

                  _buildSectionHeader('Hoạt động'),
                  ..._buildRoleSpecificMenu(context, role),

                  _buildSectionHeader('Tài khoản & Bảo mật'),
                  _buildMenuItem(
                    context,
                    icon: Icons.person_outline,
                    title: 'Thông tin cá nhân',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.editProfile);
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.lock_outline,
                    title: 'Đổi mật khẩu',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.changePassword);
                    },
                  ),

                  _buildSectionHeader('Cài đặt'),
                  _buildMenuItem(
                    context,
                    icon: Icons.notifications_outlined,
                    title: 'Thông báo',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.notifications);
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.help_outline,
                    title: 'Trợ giúp & Hỗ trợ',
                    onTap: () {},
                  ),

                  const Divider(height: 32),
                  _buildMenuItem(
                    context,
                    icon: Icons.logout,
                    title: 'Đăng xuất',
                    color: AppColors.error,
                    onTap: () => _handleLogout(context, authProvider),
                  ),
                  
                  const SizedBox(height: 32),
                  Center(
                    child: Text(
                      'Phiên bản 1.0.0',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildRoleSpecificMenu(BuildContext context, UserRole role) {
    switch (role) {
      case UserRole.customer:
        return [
          _buildMenuItem(
            context,
            icon: Icons.history,
            title: 'Lịch sử đặt lịch',
            onTap: () => Navigator.pushNamed(context, AppRoutes.orderList),
          ),
          _buildMenuItem(
            context,
            icon: Icons.favorite_outline,
            title: 'Tiệm yêu thích',
            onTap: () {},
          ),
          _buildMenuItem(
            context,
            icon: Icons.star_outline,
            title: 'Đánh giá của tôi',
            onTap: () {},
          ),
        ];
      case UserRole.barber:
        return [
          _buildMenuItem(
            context,
            icon: Icons.account_balance_wallet_outlined,
            title: 'Thu nhập của tôi',
            onTap: () => Navigator.pushNamed(context, AppRoutes.barberIncome),
          ),
          _buildMenuItem(
            context,
            icon: Icons.calendar_today_outlined,
            title: 'Lịch làm việc',
            onTap: () => Navigator.pushNamed(context, AppRoutes.barberSchedule),
          ),
        ];
      case UserRole.admin:
        return [
          _buildMenuItem(
            context,
            icon: Icons.dashboard_outlined,
            title: 'Quản trị hệ thống',
            onTap: () => Navigator.pushNamed(context, AppRoutes.adminDashboard),
          ),
          _buildMenuItem(
            context,
            icon: Icons.analytics_outlined,
            title: 'Thống kê chi tiết',
            onTap: () => Navigator.pushNamed(context, AppRoutes.statistics),
          ),
        ];
      case UserRole.manager:
        return [
          _buildMenuItem(
            context,
            icon: Icons.dashboard_outlined,
            title: 'Dashboard Quản lý',
            onTap: () => Navigator.pushNamed(context, AppRoutes.managerDashboard),
          ),
          _buildMenuItem(
            context,
            icon: Icons.store_outlined,
            title: 'Cửa hàng của tôi',
            onTap: () => Navigator.pushNamed(context, AppRoutes.shopManagement),
          ),
        ];
    }
  }

  Widget _buildHeader(UserModel? user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: user?.avatarUrl.isNotEmpty == true
                ? NetworkImage(user!.avatarUrl)
                : null,
            child: user?.avatarUrl.isEmpty ?? true
                ? const Icon(Icons.person, size: 50)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            user?.name ?? 'Người dùng',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? '',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              user?.role.name.toUpperCase() ?? 'CUSTOMER',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildSkillsList(List<String> skills) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: skills.map((skill) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Text(
            skill,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.textPrimary, size: 22),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? AppColors.textPrimary,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 18),
      onTap: onTap,
    );
  }

  Future<void> _handleLogout(BuildContext context, AuthProvider authProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất?'),
        content: const Text('Bạn có chắc muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await authProvider.logout();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      }
    }
  }
}
