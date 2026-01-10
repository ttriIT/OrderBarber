import 'package:flutter/material.dart';

/// App color palette for the barbershop app
class AppColors {
  AppColors._();

  // Primary colors
  static const Color primary = Color(0xFF1E3A5F);
  static const Color primaryLight = Color(0xFF4A6FA5);
  static const Color primaryDark = Color(0xFF0D1F33);

  // Secondary colors
  static const Color secondary = Color(0xFFD4AF37);
  static const Color secondaryLight = Color(0xFFE8D080);
  static const Color secondaryDark = Color(0xFFA88C2A);

  // Background colors
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Text colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFFFFFFFF);

  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Booking status colors
  static const Color pending = Color(0xFFF59E0B);
  static const Color confirmed = Color(0xFF3B82F6);
  static const Color completed = Color(0xFF10B981);
  static const Color cancelled = Color(0xFFEF4444);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryLight],
  );
}
