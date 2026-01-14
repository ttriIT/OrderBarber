import '../../core/api/api_client.dart';

class ScheduleService {
  final ApiClient _client;

  ScheduleService({ApiClient? client}) : _client = client ?? apiClient;

  /// Get schedule for a barber
  Future<Map<String, dynamic>> getSchedule(String barberId) async {
    try {
      final response = await _client.get('/barbers/$barberId/schedule');
      if (response.statusCode == 200) {
        return response.data;
      }
      return {};
    } catch (e) {
      rethrow;
    }
  }

  /// Toggle a time slot
  Future<void> toggleSlot({
    required String barberId,
    required DateTime date,
    required String timeSlot,
  }) async {
    try {
      await _client.post('/barbers/$barberId/schedule/toggle-slot', data: {
        'date': date.toIso8601String().split('T')[0],
        'timeSlot': timeSlot,
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Toggle off day
  Future<void> toggleOffDay({
    required String barberId,
    required DateTime date,
  }) async {
    try {
      await _client.post('/barbers/$barberId/schedule/toggle-off-day', data: {
        'date': date.toIso8601String().split('T')[0],
      });
    } catch (e) {
      rethrow;
    }
  }
}
