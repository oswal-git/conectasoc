import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles_theme.dart';
import 'app_spacing_theme.dart';
import 'app_radius_theme.dart';
import 'components/app_buttons_theme.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
        ),

        // scaffoldBackgroundColor: AppColors.surface,

        // TEXTOS
        textTheme: TextTheme(
          headlineMedium: AppTextStylesTheme.titleMedium,
          titleMedium: AppTextStylesTheme.titleSmall,
          bodyLarge: AppTextStylesTheme.bodyLarge,
          bodyMedium: AppTextStylesTheme.bodyMedium,
          labelLarge: AppTextStylesTheme.labelLarge,
        ),

        // COMPONENTES
        elevatedButtonTheme: AppButtonTheme.elevated,
        inputDecorationTheme: _inputTheme(),
        cardTheme: _cardTheme(),
      );

  static InputDecorationTheme _inputTheme() => InputDecorationTheme(
        contentPadding: AppSpacingTheme.paddingInput,
        border: OutlineInputBorder(
          borderRadius: AppRadiusTheme.input,
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      );

  static CardThemeData _cardTheme() => CardThemeData(
        shape: RoundedRectangleBorder(borderRadius: AppRadiusTheme.card),
      );
}
