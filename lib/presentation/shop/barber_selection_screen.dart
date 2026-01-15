import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/widgets/barber_card.dart';
import '../../providers/shop_provider.dart';
import '../../providers/booking_provider.dart';

class BarberSelectionScreen extends StatefulWidget {
  final String shopId;

  const BarberSelectionScreen({super.key, required this.shopId});

  @override
  State<BarberSelectionScreen> createState() => _BarberSelectionScreenState();
}

class _BarberSelectionScreenState extends State<BarberSelectionScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ShopProvider>().loadBarbers(widget.shopId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn thợ cắt tóc'),
      ),
      body: Consumer2<ShopProvider, BookingProvider>(
        builder: (context, shopProvider, bookingProvider, child) {
          if (shopProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final barbers = shopProvider.barbers;
          if (barbers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_off,
                    size: 64,
                    color: AppColors.textSecondary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Không có thợ cắt tóc',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: barbers.length,
                  itemBuilder: (context, index) {
                    final barber = barbers[index];
                    final isSelected = bookingProvider.selectedBarber?.id == barber.id;
                    return BarberCard(
                      barber: barber,
                      isSelected: isSelected,
                      onTap: () {
                        bookingProvider.setBarber(barber);
                      },
                    );
                  },
                ),
              ),
              Container(
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
                child: ElevatedButton(
                  onPressed: bookingProvider.selectedBarber != null
                      ? () {
                          Navigator.pushNamed(context, AppRoutes.bookingDate);
                        }
                      : null,
                  child: const Text('Tiếp tục'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
