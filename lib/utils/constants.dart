import 'package:flutter/material.dart';

/// App constants for colors, spacing, and typography
class AppConstants {
  // Colors
  static const Color primary = Color(0xFF6C5CE7);
  static const Color accent = Color(0xFF00B894);
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);

  // Light theme colors (updated per user feedback)
  static const Color lightBackground = Color(0xFFFAF7FF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightMutedBg = Color(0xFFF3F4F6);

  // Dark theme colors (updated per user feedback)
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);
  static const Color darkMutedBg = Color(0xFF334155);

  // Legacy aliases for backward compatibility
  static const Color surface = lightSurface;
  static const Color mutedBg = lightMutedBg;
  static const Color textPrimary = lightTextPrimary;
  static const Color textSecondary = lightTextSecondary;

  // Spacing (8px baseline)
  static const double spacingXs = 8.0;
  static const double spacingSm = 16.0;
  static const double spacingMd = 24.0;
  static const double spacingLg = 32.0;
  static const double spacingXl = 48.0;

  // Border radius
  static const double borderRadius = 16.0; // 2xl
  static const double borderRadiusSm = 8.0;
  static const double borderRadiusLg = 24.0;

  // Shadows
  static const BoxShadow softShadow = BoxShadow(
    color: Color(0x0D000000),
    blurRadius: 8,
    offset: Offset(0, 4),
  );

  // Typography
  static const String fontFamily = 'Inter';

  // Animation durations
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration shimmerDuration = Duration(milliseconds: 200);
}
