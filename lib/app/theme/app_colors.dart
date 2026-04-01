import 'package:flutter/material.dart';

abstract class AppColors {
  // Primary brand
  static const Color primary = Color(0xFF5E7E99);
  static const Color primaryLight = Color(0xFFA5CBEB);
  static const Color primaryDark = Color(0xFF3E5C73);

  // Neutrals
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color surface = white;

  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color border = Color(0xFFE0E0E0); // grey[300]
  static const Color hint = Color(0xFF7E7D7D);

  // Status
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color errorDetail = Color(0xFFDC2626);
  static const Color enabled = Color(0xFFFAFAFA); // grey[50]
  static const Color disabled = Color(0xFFE0E0E0); // grey[300]

  // Status backgrounds
  static const Color successBg = Color(0xFFF0FDF4);
  static const Color errorBg = Color(0xFFFEF2F2);

  static Color surfaceElevation(int level) {
    switch (level) {
      case 1:
        return const Color(0xFFF8FAFC);
      case 2:
        return const Color(0xFFF1F5F9);
      default:
        return surface;
    }
  }

  static Color errorOpacity(double alpha) =>
      AppColors.error.withValues(alpha: alpha);
}
