import 'package:flutter/material.dart';
import 'package:conectasoc/app/theme/theme.dart';

class AppInputTheme {
  static InputDecorationTheme get primary => InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceElevation(1),
        contentPadding: AppSpacingTheme.paddingInput,

        // Bordes
        border: OutlineInputBorder(
          borderRadius: AppRadiusTheme.input,
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadiusTheme.input,
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadiusTheme.input,
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadiusTheme.input,
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),

        // Labels y hints
        labelStyle: AppTextStylesTheme.labelLarge,
        hintStyle: AppTextStylesTheme.bodySmall.copyWith(
          color: AppColors.textMuted,
        ),

        // Iconos
        prefixIconConstraints:
            const BoxConstraints(minWidth: 24, minHeight: 24),
      );

  /// FACTORY para campos de búsqueda
  static InputDecoration searchField({
    String? hintText,
    IconData? prefixIcon,
    VoidCallback? onClear,
  }) {
    return InputDecoration(
      hintText: hintText ?? "Buscar...",
      prefixIcon: Icon(prefixIcon ?? Icons.search, size: 20),
      suffixIcon: onClear != null
          ? IconButton(
              icon: const Icon(Icons.clear, size: 20), onPressed: onClear)
          : null,
      border: OutlineInputBorder(borderRadius: AppRadiusTheme.input),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadiusTheme.input,
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }
}
