import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/admin_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminProvider>().loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final stats = provider.dashboardStats;

          return RefreshIndicator(
            onRefresh: () async => provider.loadDashboard(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats cards
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _buildStatCard(
                        title: 'Tổng lịch hẹn',
                        value: '${stats['totalBookings'] ?? 0}',
                        icon: Icons.calendar_today,
                        color: AppColors.primary,
                      ),
                      _buildStatCard(
                        title: 'Doanh thu',
                        value: '${((stats['totalRevenue'] ?? 0) / 1000000).toStringAsFixed(1)}M',
                        icon: Icons.attach_money,
                        color: AppColors.success,
                      ),
                      _buildStatCard(
                        title: 'Người dùng',
                        value: '${stats['totalUsers'] ?? 0}',
                        icon: Icons.people,
                        color: AppColors.info,
                      ),
                      _buildStatCard(
                        title: 'Tiệm',
                        value: '${stats['totalShops'] ?? 0}',
                        icon: Icons.store,
                        color: AppColors.secondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Booking status
                  const Text(
                    'Trạng thái lịch hẹn',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildStatusRow('Chờ xác nhận', 
                            provider.bookingsByStatus[BookingStatus.pending] ?? 0, 
                            AppColors.pending),
                        _buildStatusRow('Đã xác nhận', 
                            provider.bookingsByStatus[BookingStatus.confirmed] ?? 0, 
                            AppColors.confirmed),
                        _buildStatusRow('Hoàn thành', 
                            provider.bookingsByStatus[BookingStatus.completed] ?? 0, 
                            AppColors.completed),
                        _buildStatusRow('Đã hủy', 
                            provider.bookingsByStatus[BookingStatus.cancelled] ?? 0, 
                            AppColors.cancelled),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(
            '$count',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
