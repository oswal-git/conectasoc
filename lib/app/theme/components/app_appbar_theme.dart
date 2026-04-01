import 'package:flutter/material.dart';
import 'package:conectasoc/app/theme/theme.dart';

class AppAppBarTheme {
  /// AppBar principal
  static AppBarTheme get primary => const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleSpacing: 0,
        toolbarHeight: kToolbarHeight,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      );

  /// AppBar secundaria (filtros, tabs)
  static AppBarTheme get secondary => AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        titleTextStyle: AppTextStylesTheme.titleSmall.copyWith(
          color: AppColors.textPrimary,
        ),
      );

  /// TopBar minimalista (solo título)
  static PreferredSizeWidget topBar(String title) => PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight - 8),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacingTheme.md),
            child: Row(
              children: [
                Text(title, style: AppTextStylesTheme.titleMedium),
                const Spacer(),
                // Actions aquí
              ],
            ),
          ),
        ),
      );
}
