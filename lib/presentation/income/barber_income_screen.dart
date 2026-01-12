import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/barber_income_provider.dart';
import '../../data/models/booking_model.dart';

class BarberIncomeScreen extends StatefulWidget {
  const BarberIncomeScreen({super.key});

  @override
  State<BarberIncomeScreen> createState() => _BarberIncomeScreenState();
}

class _BarberIncomeScreenState extends State<BarberIncomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.currentUser != null) {
        context.read<BarberIncomeProvider>().loadIncomeData(authProvider.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thu nhập của tôi'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<BarberIncomeProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(child: Text(provider.errorMessage!));
          }

          return Column(
            children: [
              _buildSummaryHeader(provider),
              _buildPeriodSelector(provider),
              Expanded(
                child: _buildTransactionList(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryHeader(BarberIncomeProvider provider) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const Text(
            'Tổng thu nhập',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            currencyFormat.format(provider.totalIncome),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSimpleStat(
                'Trong kỳ',
                currencyFormat.format(provider.periodIncome),
              ),
              Container(width: 1, height: 40, color: Colors.white24),
              _buildSimpleStat(
                'Số đơn',
                '${provider.filteredBookings.length}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector(BarberIncomeProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SegmentedButton<String>(
        segments: const [
          ButtonSegment(value: 'day', label: Text('Ngày')),
          ButtonSegment(value: 'week', label: Text('Tuần')),
          ButtonSegment(value: 'month', label: Text('Tháng')),
        ],
        selected: {provider.selectedPeriod},
        onSelectionChanged: (Set<String> newSelection) {
          provider.setSelectedPeriod(newSelection.first);
        },
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: AppColors.primary,
          selectedForegroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTransactionList(BarberIncomeProvider provider) {
    final bookings = provider.filteredBookings;
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'Không có đơn hoàn thành trong kỳ này',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: const Icon(Icons.check, color: AppColors.primary),
            ),
            title: Text(
              booking.customerName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  booking.services.map((s) => s.name).join(', '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(booking.bookingDate),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            trailing: Text(
              currencyFormat.format(booking.totalPrice),
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }
}
