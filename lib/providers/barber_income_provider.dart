import 'package:flutter/material.dart';
import '../data/models/booking_model.dart';
import '../data/services/fake_booking_service.dart';
import '../core/constants/app_constants.dart';

class BarberIncomeProvider extends ChangeNotifier {
  final FakeBookingService _bookingService = FakeBookingService();
  
  List<BookingModel> _allBookings = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Filters
  String _selectedPeriod = 'day'; // 'day', 'week', 'month'

  // Getters
  List<BookingModel> get allBookings => _allBookings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedPeriod => _selectedPeriod;

  void setSelectedPeriod(String period) {
    _selectedPeriod = period;
    notifyListeners();
  }

  Future<void> loadIncomeData(String barberId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allBookings = await _bookingService.getBarberBookings(barberId);
      // Filter for completed bookings only for income calculation
      _allBookings = _allBookings.where((b) => b.status == BookingStatus.completed).toList();
    } catch (e) {
      _errorMessage = 'Lỗi khi tải dữ liệu thu nhập: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  double get totalIncome {
    return _allBookings.fold(0, (sum, b) => sum + b.totalPrice);
  }

  List<BookingModel> get filteredBookings {
    final now = DateTime.now();
    return _allBookings.where((b) {
      if (_selectedPeriod == 'day') {
        return DateUtils.isSameDay(b.bookingDate, now);
      } else if (_selectedPeriod == 'week') {
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return b.bookingDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) && 
               b.bookingDate.isBefore(endOfWeek.add(const Duration(days: 1)));
      } else if (_selectedPeriod == 'month') {
        return b.bookingDate.year == now.year && b.bookingDate.month == now.month;
      }
      return true;
    }).toList();
  }

  double get periodIncome {
    return filteredBookings.fold(0, (sum, b) => sum + b.totalPrice);
  }
}
