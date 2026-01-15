import '../../core/api/api_client.dart';
import '../models/booking_model.dart';
import '../../core/constants/app_constants.dart';

class BookingService {
  final ApiClient _client;

  BookingService({ApiClient? client}) : _client = client ?? apiClient;

  /// Get bookings for current user
  Future<List<BookingModel>> getBookings() async {
    try {
      final response = await _client.get('/bookings');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => BookingModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get bookings for a specific barber
  Future<List<BookingModel>> getBarberBookings(String barberId) async {
    try {
      final response = await _client.get('/Barbers/$barberId/bookings');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => BookingModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Create new booking
  Future<BookingModel?> createBooking({
    required String shopId,
    required String barberId,
    required List<String> serviceIds,
    required DateTime bookingDate,
    required String timeSlot,
    String? note,
  }) async {
    try {
      final response = await _client.post('/bookings', data: {
        'shopId': int.tryParse(shopId) ?? shopId,
        'barberId': int.tryParse(barberId) ?? barberId,
        'serviceIds': serviceIds,
        'bookingDate': bookingDate.toIso8601String(),
        'timeSlot': timeSlot,
        'note': note,
      });
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return BookingModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Cancel booking
  Future<bool> cancelBooking(String bookingId) async {
    try {
      final response = await _client.post('/bookings/$bookingId/cancel');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get available slots
  Future<List<String>> getAvailableTimeSlots({
    required String shopId,
    required String barberId,
    required DateTime date,
  }) async {
    try {
      final response = await _client.get('/Shops/$shopId/staff/$barberId/availability', queryParameters: {
        'date': date.toIso8601String().split('T')[0],
      });
      if (response.statusCode == 200) {
        return List<String>.from(response.data);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get bookings for a specific customer
  Future<List<BookingModel>> getCustomerBookings(String customerId) async {
    return getBookings(); 
  }

  /// Get all bookings (Admin)
  Future<List<BookingModel>> getAllBookings() async {
     try {
      final response = await _client.get('/bookings'); 
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => BookingModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Update booking status
  Future<BookingModel?> updateBookingStatus({
    required String bookingId,
    required BookingStatus status,
  }) async {
    try {
      final response = await _client.put('/bookings/$bookingId/status', data: {
        'status': status.name,
      });
      if (response.statusCode == 200) {
        return BookingModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get today's bookings for barber
  Future<List<BookingModel>> getTodayBookings(String barberId) async {
    try {
      final now = DateTime.now();
      final allBookings = await getBarberBookings(barberId);
      return allBookings.where((b) => 
        b.bookingDate.year == now.year &&
        b.bookingDate.month == now.month &&
        b.bookingDate.day == now.day
      ).toList();
    } catch (e) {
      return [];
    }
  }
}
