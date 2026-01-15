import 'package:flutter/material.dart';
import '../data/models/booking_model.dart';
import '../data/models/service_model.dart';
import '../data/models/barber_model.dart';
import '../data/models/shop_model.dart';
import '../data/services/booking_service.dart';
import '../core/constants/app_constants.dart';

/// BookingProvider for managing booking flow and state
class BookingProvider extends ChangeNotifier {
  final BookingService _bookingService = BookingService();

  // Booking form state
  ShopModel? _selectedShop;
  BarberModel? _selectedBarber;
  List<ServiceModel> _selectedServices = [];
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  String? _note;

  // Bookings data
  List<BookingModel> _bookings = [];
  List<String> _availableTimeSlots = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  ShopModel? get selectedShop => _selectedShop;
  BarberModel? get selectedBarber => _selectedBarber;
  List<ServiceModel> get selectedServices => _selectedServices;
  DateTime? get selectedDate => _selectedDate;
  String? get selectedTimeSlot => _selectedTimeSlot;
  String? get note => _note;
  List<BookingModel> get bookings => _bookings;
  List<String> get availableTimeSlots => _availableTimeSlots;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get totalPrice {
    return _selectedServices.fold(0, (sum, s) => sum + s.price);
  }

  int get totalDuration {
    return _selectedServices.fold(0, (sum, s) => sum + s.durationMinutes);
  }

  bool get canProceedToTime => _selectedServices.isNotEmpty && _selectedBarber != null;
  bool get canConfirm => _selectedDate != null && _selectedTimeSlot != null;

  /// Set selected shop
  void setShop(ShopModel shop) {
    _selectedShop = shop;
    notifyListeners();
  }

  /// Set selected barber
  void setBarber(BarberModel barber) {
    _selectedBarber = barber;
    notifyListeners();
  }

  /// Toggle service selection
  void toggleService(ServiceModel service) {
    if (_selectedServices.any((s) => s.id == service.id)) {
      _selectedServices.removeWhere((s) => s.id == service.id);
    } else {
      _selectedServices.add(service);
    }
    notifyListeners();
  }

  /// Set selected date
  void setDate(DateTime date) {
    _selectedDate = date;
    _selectedTimeSlot = null;
    notifyListeners();
  }

  /// Set selected time slot
  void setTimeSlot(String timeSlot) {
    _selectedTimeSlot = timeSlot;
    notifyListeners();
  }

  /// Set note
  void setNote(String note) {
    _note = note;
    notifyListeners();
  }

  /// Load available time slots
  Future<void> loadAvailableTimeSlots() async {
    if (_selectedShop == null || _selectedBarber == null || _selectedDate == null) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _availableTimeSlots = await _bookingService.getAvailableTimeSlots(
        shopId: _selectedShop!.id,
        barberId: _selectedBarber!.id,
        date: _selectedDate!,
      );
    } catch (e) {
      debugPrint('Error loading time slots: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Create booking
  Future<BookingModel?> createBooking({
    required String customerId,
    required String customerName,
  }) async {
    if (_selectedShop == null ||
        _selectedBarber == null ||
        _selectedServices.isEmpty ||
        _selectedDate == null ||
        _selectedTimeSlot == null) {
      _errorMessage = 'Vui lòng hoàn tất thông tin đặt lịch';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final booking = await _bookingService.createBooking(
        shopId: _selectedShop!.id,
        barberId: _selectedBarber!.id,
        serviceIds: _selectedServices.map((s) => s.id).toList(),
        bookingDate: _selectedDate!,
        timeSlot: _selectedTimeSlot!,
        note: _note,
      );

      if (booking != null) {
        _bookings.insert(0, booking);
      }
      _isLoading = false;
      notifyListeners();
      return booking;
    } catch (e) {
      _errorMessage = 'Đặt lịch thất bại: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Load customer bookings
  Future<void> loadCustomerBookings(String customerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _bookings = await _bookingService.getCustomerBookings(customerId);
    } catch (e) {
      debugPrint('Error loading bookings: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load barber bookings
  Future<void> loadBarberBookings(String barberId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _bookings = await _bookingService.getBarberBookings(barberId);
    } catch (e) {
      debugPrint('Error loading barber bookings: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load today's bookings for barber
  Future<void> loadTodayBookings(String barberId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _bookings = await _bookingService.getTodayBookings(barberId);
    } catch (e) {
      debugPrint('Error loading today bookings: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load all bookings (admin)
  Future<void> loadAllBookings() async {
    _isLoading = true;
    notifyListeners();

    try {
      _bookings = await _bookingService.getAllBookings();
    } catch (e) {
      debugPrint('Error loading all bookings: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Update booking status
  Future<bool> updateBookingStatus(String bookingId, BookingStatus status) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updated = await _bookingService.updateBookingStatus(
        bookingId: bookingId,
        status: status,
      );

      if (updated != null) {
        final index = _bookings.indexWhere((b) => b.id == bookingId);
        if (index != -1) {
          _bookings[index] = updated;
        }
      }

      _isLoading = false;
      notifyListeners();
      return updated != null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Cancel booking
  Future<bool> cancelBooking(String bookingId) async {
    return await updateBookingStatus(bookingId, BookingStatus.cancelled);
  }

  /// Reset booking form
  void resetBookingForm() {
    _selectedShop = null;
    _selectedBarber = null;
    _selectedServices = [];
    _selectedDate = null;
    _selectedTimeSlot = null;
    _note = null;
    _availableTimeSlots = [];
    _errorMessage = null;
    notifyListeners();
  }

  /// Get bookings by status
  List<BookingModel> getBookingsByStatus(BookingStatus status) {
    return _bookings.where((b) => b.status == status).toList();
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
