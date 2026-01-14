import 'package:flutter/material.dart';
import '../data/services/schedule_service.dart';
import '../core/constants/app_constants.dart';

/// Provider for managing barber working schedule
class BarberScheduleProvider extends ChangeNotifier {
  final ScheduleService _scheduleService = ScheduleService();
  
  // Map of date to list of blocked time slots
  // Key: YYYY-MM-DD
  final Map<String, List<String>> _blockedSlots = {};
  
  // Set of dates marked as off days
  // Format: YYYY-MM-DD
  final Set<String> _offDays = {};

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Get blocked slots for a specific date
  List<String> getBlockedSlots(DateTime date) {
    final dateKey = _getDateKey(date);
    return _blockedSlots[dateKey] ?? [];
  }

  /// Check if a date is marked as an off day
  bool isOffDay(DateTime date) {
    final dateKey = _getDateKey(date);
    return _offDays.contains(dateKey);
  }

  /// Toggle a time slot's blocked status
  void toggleSlot(DateTime date, String timeSlot) {
    final dateKey = _getDateKey(date);
    final slots = _blockedSlots[dateKey] ?? [];
    
    if (slots.contains(timeSlot)) {
      slots.remove(timeSlot);
    } else {
      slots.add(timeSlot);
    }
    
    if (slots.isEmpty) {
      _blockedSlots.remove(dateKey);
    } else {
      _blockedSlots[dateKey] = slots;
    }
    
    notifyListeners();
  }

  /// Toggle off day status for a date
  void toggleOffDay(DateTime date) {
    final dateKey = _getDateKey(date);
    if (_offDays.contains(dateKey)) {
      _offDays.remove(dateKey);
    } else {
      _offDays.add(dateKey);
    }
    notifyListeners();
  }

  /// Check if a slot is blocked
  bool isSlotBlocked(DateTime date, String timeSlot) {
    final dateKey = _getDateKey(date);
    return _blockedSlots[dateKey]?.contains(timeSlot) ?? false;
  }

  /// Generate all possible time slots for a day
  List<String> getAllTimeSlots() {
    final slots = <String>[];
    for (int hour = AppConstants.openingHour; hour < AppConstants.closingHour; hour++) {
      slots.add('${hour.toString().padLeft(2, '0')}:00');
      slots.add('${hour.toString().padLeft(2, '0')}:30');
    }
    return slots;
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Load schedule data for a barber (mock)
  Future<void> loadSchedule(String barberId) async {
    _isLoading = true;
    notifyListeners();
    
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));
    
    _isLoading = false;
    notifyListeners();
  }
}
