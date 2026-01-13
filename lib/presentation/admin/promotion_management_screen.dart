import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../data/models/promotion_model.dart';
import '../../core/theme/app_colors.dart';
import 'package:intl/intl.dart';

class PromotionManagementScreen extends StatefulWidget {
  const PromotionManagementScreen({super.key});

  @override
  State<PromotionManagementScreen> createState() => _PromotionManagementScreenState();
}

class _PromotionManagementScreenState extends State<PromotionManagementScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<AdminProvider>().loadPromotions(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý khuyến mãi'),
        actions: [
          IconButton(
            onPressed: () => _showPromotionDialog(context),
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Thêm khuyến mãi',
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final promotions = provider.promotions;

          if (promotions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.discount_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có chương trình khuyến mãi nào',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _showPromotionDialog(context),
                    child: const Text('Tạo khuyến mãi mới'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: promotions.length,
            itemBuilder: (context, index) {
              final promotion = promotions[index];
              return _buildPromotionCard(context, promotion);
            },
          );
        },
      ),
    );
  }

  Widget _buildPromotionCard(BuildContext context, PromotionModel promotion) {
    final isExpired = promotion.expiryDate.isBefore(DateTime.now());
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              promotion.imageUrl,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 150,
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: promotion.isActive ? AppColors.success.withOpacity(0.1) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: promotion.isActive ? AppColors.success.withOpacity(0.3) : Colors.grey[300]!),
                      ),
                      child: Text(
                        promotion.isActive ? 'Đang chạy' : 'Đã dừng',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: promotion.isActive ? AppColors.success : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.info),
                          onPressed: () => _showPromotionDialog(context, promotion: promotion),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                          onPressed: () => _showDeleteConfirm(context, promotion),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        promotion.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.info.withOpacity(0.3)),
                      ),
                      child: Text(
                        promotion.code,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  promotion.description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 12),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Giảm giá',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          '${promotion.discountPercentage.toInt()}%',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Hết hạn',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          dateFormat.format(promotion.expiryDate),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          color: isExpired ? AppColors.error : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPromotionDialog(BuildContext context, {PromotionModel? promotion}) {
    final isEditing = promotion != null;
    final titleController = TextEditingController(text: promotion?.title ?? '');
    final descController = TextEditingController(text: promotion?.description ?? '');
    final codeController = TextEditingController(text: promotion?.code ?? '');
    final discountController = TextEditingController(text: promotion?.discountPercentage.toString() ?? '');
    final imageController = TextEditingController(text: promotion?.imageUrl ?? '');
    DateTime selectedDate = promotion?.expiryDate ?? DateTime.now().add(const Duration(days: 30));
    bool isActive = promotion?.isActive ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Sửa khuyến mãi' : 'Thêm khuyến mãi mới'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Tiêu đề'),
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Mô tả'),
                  maxLines: 2,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: codeController,
                        decoration: const InputDecoration(labelText: 'Mã code'),
                        textCapitalization: TextCapitalization.characters,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: discountController,
                        decoration: const InputDecoration(labelText: 'Giảm (%)'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                TextField(
                  controller: imageController,
                  decoration: const InputDecoration(labelText: 'Link ảnh (URL)'),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Ngày hết hạn:'),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  contentPadding: EdgeInsets.zero,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedDate = picked);
                    }
                  },
                ),
                SwitchListTile(
                  title: const Text('Trạng thái hoạt động'),
                  value: isActive,
                  onChanged: (value) {
                    setDialogState(() => isActive = value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                final newPromotion = PromotionModel(
                  id: isEditing ? promotion.id : DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text,
                  description: descController.text,
                  code: codeController.text.toUpperCase(),
                  discountPercentage: double.tryParse(discountController.text) ?? 0,
                  imageUrl: imageController.text.isNotEmpty 
                      ? imageController.text 
                      : 'https://via.placeholder.com/400x200/D4AF37/FFFFFF?text=Promotion',
                  expiryDate: selectedDate,
                  isActive: isActive,
                );

                if (isEditing) {
                  context.read<AdminProvider>().updatePromotion(newPromotion);
                } else {
                  context.read<AdminProvider>().addPromotion(newPromotion);
                }
                Navigator.pop(context);
              },
              child: Text(isEditing ? 'Cập nhật' : 'Thêm'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, PromotionModel promotion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa khuyến mãi "${promotion.title}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              context.read<AdminProvider>().deletePromotion(promotion.id);
              Navigator.pop(context);
            },
              child: const Text('Xóa', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
