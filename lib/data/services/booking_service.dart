import '../../core/api/api_client.dart';
import '../models/booking_model.dart';
import '../../core/constants/app_constants.dart';
import '../models/service_model.dart';

class BookingService {
  final ApiClient _client;

  BookingService({ApiClient? client}) : _client = client ?? apiClient;

  /// Get all bookings for current user
  Future<List<BookingModel>> getBookings({String? status}) async {
    try {
      final response = await _client.get('/bookings', queryParameters: status != null ? {'status': status} : null);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => BookingModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Get bookings for a specific barber
  Future<List<BookingModel>> getBarberBookings(String barberId) async {
    try {
      final response = await _client.get('/barbers/$barberId/bookings');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => BookingModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get today's bookings for a barber
  Future<List<BookingModel>> getTodayBookings(String barberId) async {
    try {
      final response = await _client.get('/barbers/$barberId/bookings/today');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => BookingModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get all bookings (admin)
  Future<List<BookingModel>> getAllBookings() async {
    try {
      final response = await _client.get('/admin/bookings');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => BookingModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get bookings by customer ID (explicitly)
  Future<List<BookingModel>> getCustomerBookings(String customerId) async {
    try {
      final response = await _client.get('/customers/$customerId/bookings');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => BookingModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get booking details by ID
  Future<BookingModel?> getBookingById(String bookingId) async {
    try {
      final response = await _client.get('/bookings/$bookingId');
      if (response.statusCode == 200) {
        return BookingModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Create new booking
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
    try {
      final response = await _client.post('/bookings', data: {
        'customerId': customerId,
        'customerName': customerName,
        'shopId': shopId,
        'barberId': barberId,
        'services': services.map((s) => s.toJson()).toList(),
        'bookingDate': bookingDate.toIso8601String(),
        'timeSlot': timeSlot,
        'note': note,
      });
      return BookingModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Update booking status
  Future<BookingModel?> updateBookingStatus({
    required String bookingId,
    required BookingStatus status,
  }) async {
    try {
      final response = await _client.put('/bookings/$bookingId/status', data: {'status': status.name});
      if (response.statusCode == 200) {
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

  /// Get available time slots for a barber on a specific date
  Future<List<String>> getAvailableTimeSlots({
    required String shopId,
    required String barberId,
    required DateTime date,
  }) async {
    try {
      final response = await _client.get('/barbers/$barberId/slots', queryParameters: {
        'shopId': shopId,
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
}
