import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/rating_bar.dart';
import '../../data/models/booking_model.dart';
import '../../providers/booking_provider.dart';

class OrderDetailScreen extends StatelessWidget {
  final String bookingId;

  const OrderDetailScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingProvider>(
      builder: (context, provider, child) {
        final booking = provider.bookings.firstWhere(
          (b) => b.id == bookingId,
          orElse: () => BookingModel(
            id: '',
            customerId: '',
            customerName: '',
            shopId: '',
            barberId: '',
            services: [],
            bookingDate: DateTime.now(),
            timeSlot: '',
            status: BookingStatus.pending,
            totalPrice: 0,
            createdAt: DateTime.now(),
          ),
        );

        if (booking.id.isEmpty) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Không tìm thấy lịch hẹn')),
          );
        }

        Color statusColor;
        switch (booking.status) {
          case BookingStatus.pending:
            statusColor = AppColors.pending;
            break;
          case BookingStatus.confirmed:
            statusColor = AppColors.confirmed;
            break;
          case BookingStatus.completed:
            statusColor = AppColors.completed;
            break;
          case BookingStatus.cancelled:
            statusColor = AppColors.cancelled;
            break;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Chi tiết lịch hẹn'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        statusColor.withOpacity(0.8),
                        statusColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        booking.status == BookingStatus.completed
                            ? Icons.check_circle
                            : booking.status == BookingStatus.cancelled
                                ? Icons.cancel
                                : Icons.schedule,
                        color: Colors.white,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        booking.statusText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '#${booking.id.substring(0, 8).toUpperCase()}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Date & Time
                _buildSection(
                  title: 'Thời gian',
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${booking.bookingDate.day}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              DateFormat('MMM', 'vi').format(booking.bookingDate),
                              style: const TextStyle(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('EEEE', 'vi').format(booking.bookingDate),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  booking.timeSlot,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Shop info
                if (booking.shop != null)
                  _buildSection(
                    title: 'Tiệm',
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            booking.shop!.imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 60,
                                height: 60,
                                color: AppColors.primary.withOpacity(0.1),
                                child: const Icon(Icons.store),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.shop!.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                booking.shop!.address,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // Barber info
                if (booking.barber != null)
                  _buildSection(
                    title: 'Thợ cắt tóc',
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(booking.barber!.avatarUrl),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.barber!.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                booking.barber!.specialization,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              RatingBar(rating: booking.barber!.rating, size: 14),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // Services
                _buildSection(
                  title: 'Dịch vụ',
                  child: Column(
                    children: booking.services.map((service) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline,
                                color: AppColors.success, size: 20),
                            const SizedBox(width: 8),
                            Expanded(child: Text(service.name)),
                            Text(
                              service.formattedPrice,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Note
                if (booking.note?.isNotEmpty ?? false)
                  _buildSection(
                    title: 'Ghi chú',
                    child: Text(booking.note!),
                  ),

                // Total
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tổng tiền',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${booking.totalPrice.toStringAsFixed(0)}đ',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: booking.status == BookingStatus.pending
              ? Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Hủy lịch hẹn?'),
                                content: const Text(
                                    'Bạn có chắc muốn hủy lịch hẹn này không?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Không'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Hủy lịch'),
                                  ),
                                ],
                              ),
                            );

                            if (confirmed == true) {
                              await provider.cancelBooking(booking.id);
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                          ),
                          child: const Text('Hủy lịch'),
                        ),
                      ),
                    ],
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
              ),
            ],
          ),
          child: child,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
