import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
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
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
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
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Menu items
                  const SizedBox(height: 16),
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
                    icon: Icons.history,
                    title: 'Lịch sử đặt lịch',
                    onTap: () {},
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
                  const Divider(height: 32),
                  _buildMenuItem(
                    context,
                    icon: Icons.notifications_outlined,
                    title: 'Cài đặt thông báo',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.lock_outline,
                    title: 'Đổi mật khẩu',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.changePassword);
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.language,
                    title: 'Ngôn ngữ',
                    trailing: const Text('Tiếng Việt'),
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.dark_mode_outlined,
                    title: 'Chế độ tối',
                    trailing: Switch(
                      value: false,
                      onChanged: (value) {},
                    ),
                    onTap: () {},
                  ),
                  const Divider(height: 32),
                  _buildMenuItem(
                    context,
                    icon: Icons.help_outline,
                    title: 'Trợ giúp',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.info_outline,
                    title: 'Về ứng dụng',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.logout,
                    title: 'Đăng xuất',
                    color: AppColors.error,
                    onTap: () async {
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
                              child: const Text('Đăng xuất'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true && context.mounted) {
                        await authProvider.logout();
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.login,
                          (route) => false,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Phiên bản 1.0.0',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
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

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.textPrimary),
      title: Text(
        title,
        style: TextStyle(color: color ?? AppColors.textPrimary),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
