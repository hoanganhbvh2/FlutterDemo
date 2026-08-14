import 'package:flutter/material.dart';

/// Centralized color palette for the app.
/// All colors are defined here; never hardcode Color() values elsewhere.
abstract final class AppColors {
  // Brand
  static const Color primary = Color(0xFF4EB748);
  static const Color secondary = Color(0xFF124DA3);
  static const Color tertiary = Color(0xFFF37022);

  // Backgrounds
  static const Color surface = Color(0xFFF8FAFC);
  static const Color cardBackground = Colors.white;

  // Borders
  static const Color cardBorder = Color(0xFFE2E8F0);

  // Text
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
}
