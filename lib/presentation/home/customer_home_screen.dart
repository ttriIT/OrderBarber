import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/widgets/shop_card.dart';
import '../../core/widgets/service_card.dart';
import '../../data/models/shop_model.dart';
import '../../data/models/service_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/shop_provider.dart';
import '../../providers/notification_provider.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  List<ShopModel> _featuredShops = [];
  List<ServiceModel> _featuredServices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final shopProvider = context.read<ShopProvider>();
    final featuredShops = await shopProvider.getFeaturedShops(limit: 4);
    final featuredServices = await shopProvider.getFeaturedServices(limit: 6);

    if (mounted) {
      setState(() {
        _featuredShops = featuredShops;
        _featuredServices = featuredServices;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                floating: true,
                backgroundColor: AppColors.backgroundLight,
                elevation: 0,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xin chào, ${user?.name ?? 'Khách'}! 👋',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Hôm nay bạn cần gì?',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                actions: [
                  Consumer<NotificationProvider>(
                    builder: (context, provider, child) {
                      return Stack(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.notifications_outlined,
                              color: AppColors.textPrimary,
                            ),
                            onPressed: () {
                              Navigator.pushNamed(context, AppRoutes.notifications);
                            },
                          ),
                          if (provider.unreadCount > 0)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${provider.unreadCount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),

              // Content
              SliverToBoxAdapter(
                child: _isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Search bar
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, AppRoutes.shopList);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
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
                                    Icon(
                                      Icons.search,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Tìm kiếm tiệm, dịch vụ...',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Banner
                          _buildBanner(),

                          // Quick actions
                          _buildQuickActions(),

                          // Featured Shops
                          _buildSectionHeader(
                            title: 'Tiệm nổi bật',
                            onViewAll: () {
                              Navigator.pushNamed(context, AppRoutes.shopList);
                            },
                          ),
                          _buildFeaturedShops(),

                          // Featured Services
                          _buildSectionHeader(
                            title: 'Dịch vụ phổ biến',
                            onViewAll: () {
                              Navigator.pushNamed(context, AppRoutes.serviceList);
                            },
                          ),
                          _buildFeaturedServices(),

                          const SizedBox(height: 24),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 160,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.content_cut,
              size: 140,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'KHUYẾN MÃI 🔥',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Giảm 20% cho lần\nđặt đầu tiên!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Áp dụng đến hết tháng',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionItem(
            icon: Icons.content_cut,
            label: 'Đặt lịch',
            color: AppColors.primary,
            onTap: () => Navigator.pushNamed(context, AppRoutes.shopList),
          ),
          _buildActionItem(
            icon: Icons.star,
            label: 'Top đánh giá',
            color: AppColors.secondary,
            onTap: () => Navigator.pushNamed(context, AppRoutes.shopList),
          ),
          _buildActionItem(
            icon: Icons.local_offer,
            label: 'Ưu đãi',
            color: AppColors.error,
            onTap: () {},
          ),
          _buildActionItem(
            icon: Icons.location_on,
            label: 'Gần đây',
            color: AppColors.success,
            onTap: () => Navigator.pushNamed(context, AppRoutes.shopList),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required VoidCallback onViewAll,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: onViewAll,
            child: const Text('Xem tất cả'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedShops() {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _featuredShops.length,
        itemBuilder: (context, index) {
          final shop = _featuredShops[index];
          return ShopCardCompact(
            shop: shop,
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.shopDetail,
                arguments: {'shopId': shop.id},
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFeaturedServices() {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _featuredServices.length,
        itemBuilder: (context, index) {
          final service = _featuredServices[index];
          return ServiceCardCompact(
            service: service,
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.serviceDetail,
                arguments: {'serviceId': service.id},
              );
            },
          );
        },
      ),
    );
  }
}
