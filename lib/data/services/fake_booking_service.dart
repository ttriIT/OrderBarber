import '../models/booking_model.dart';
import '../models/service_model.dart';
import '../models/barber_model.dart';
import '../models/shop_model.dart';
import '../mock/mock_bookings.dart';
import '../mock/mock_shops.dart';
import '../mock/mock_barbers.dart';
import '../../core/constants/app_constants.dart';

/// Fake booking service for mock booking operations
/// TODO: Replace with real API calls when backend is ready
class FakeBookingService {
  // Local storage for dynamic bookings
  final List<BookingModel> _bookings = [];

  FakeBookingService() {
    _bookings.addAll(MockBookings.getBookings());
  }

  /// Get available time slots for a date
  Future<List<String>> getAvailableTimeSlots({
    required String shopId,
    required String barberId,
    required DateTime date,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    // Generate time slots from 8:00 to 21:00
    final slots = <String>[];
    for (int hour = AppConstants.openingHour; hour < AppConstants.closingHour; hour++) {
      slots.add('${hour.toString().padLeft(2, '0')}:00');
      slots.add('${hour.toString().padLeft(2, '0')}:30');
    }

    // Remove some random slots to simulate booked times
    final bookedSlots = ['09:00', '10:30', '14:00', '16:30'];
    slots.removeWhere((slot) => bookedSlots.contains(slot));

    return slots;
  }

  /// Create a new booking
  Future<BookingModel> createBooking({
    required String customerId,
    required String customerName,
    required String shopId,
    required String barberId,
    required List<ServiceModel> services,
    required DateTime bookingDate,
    required String timeSlot,
    String? note,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final totalPrice = services.fold<double>(0, (sum, s) => sum + s.price);

    final booking = BookingModel(
      id: 'booking_${DateTime.now().millisecondsSinceEpoch}',
      customerId: customerId,
      customerName: customerName,
      shopId: shopId,
      shop: MockShops.getById(shopId),
      barberId: barberId,
      barber: MockBarbers.getById(barberId),
      services: services,
      bookingDate: bookingDate,
      timeSlot: timeSlot,
      status: BookingStatus.pending,
      totalPrice: totalPrice,
      note: note,
      createdAt: DateTime.now(),
    );

    _bookings.add(booking);
    return booking;
  }

  /// Get bookings by customer ID
  Future<List<BookingModel>> getCustomerBookings(String customerId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _bookings.where((b) => b.customerId == customerId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get bookings by barber ID
  Future<List<BookingModel>> getBarberBookings(String barberId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _bookings.where((b) => b.barberId == barberId).toList()
      ..sort((a, b) => b.bookingDate.compareTo(a.bookingDate));
  }

  /// Get today's bookings for a barber
  Future<List<BookingModel>> getTodayBookings(String barberId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final today = DateTime.now();
    return _bookings.where((b) {
      return b.barberId == barberId &&
          b.bookingDate.year == today.year &&
          b.bookingDate.month == today.month &&
          b.bookingDate.day == today.day &&
          b.status != BookingStatus.cancelled;
    }).toList()
      ..sort((a, b) => a.timeSlot.compareTo(b.timeSlot));
  }

  /// Get all bookings (for admin)
  Future<List<BookingModel>> getAllBookings() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return List.from(_bookings)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Update booking status
  Future<BookingModel?> updateBookingStatus({
    required String bookingId,
    required BookingStatus status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(status: status);
      return _bookings[index];
    }
    return null;
  }

  /// Cancel booking
  Future<bool> cancelBooking(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(status: BookingStatus.cancelled);
      return true;
    }
    return false;
  }

  /// Get booking by ID
  Future<BookingModel?> getBookingById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _bookings.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }
}
