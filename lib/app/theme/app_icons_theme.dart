import 'package:conectasoc/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

abstract class AppIconsTheme {
  // Tamaños estándar
  static const double sizeXs = 16;
  static const double sizeSm = 20;
  static const double sizeMd = 24;
  static const double sizeLg = 32;
  static const double sizeXl = 48;

  // Iconos comunes con estilo
  static Widget action({required IconData icon, Color? color}) => Icon(
        icon,
        size: sizeSm,
        color: color ?? AppColors.textSecondary,
      );

  static Widget primary({required IconData icon}) => Icon(
        icon,
        size: sizeMd,
        color: AppColors.primary,
      );
}
