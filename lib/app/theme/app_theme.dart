// 📁 lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {
  const AppTheme._();

  static const Color _seedPrimary = Color(0xFF5E7E99);
  static const Color _seedSecondary = Color(0xFFA5CBEB);

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedPrimary,
      secondary: _seedSecondary,
      error: AppColors.light().errorText,
      brightness: Brightness.light,
    );

    final colors = AppColors.light();

    return ThemeData(
      useMaterial3: true,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.surface,
      canvasColor: colors.surface,
      textTheme: AppTextStyles.light,
      primaryTextTheme: AppTextStyles.light.apply(
        bodyColor: colorScheme.onPrimary,
        displayColor: colorScheme.onPrimary,
      ),
      appBarTheme: _appBarTheme(colorScheme, colors),
      inputDecorationTheme: _inputDecorationTheme(colors),
      elevatedButtonTheme: _elevatedButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      textButtonTheme: _textButtonTheme,
      cardTheme: _cardTheme(colors),
      listTileTheme: _listTileTheme(colorScheme),
      dividerTheme: _dividerTheme(colors),
      chipTheme: _chipTheme(colorScheme),
      snackBarTheme: _snackBarTheme,
      floatingActionButtonTheme: _floatingActionButtonTheme,
      extensions: [colors],
    );
  }

  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedPrimary,
      secondary: _seedSecondary,
      error: AppColors.dark().errorText,
      brightness: Brightness.dark,
    );

    final colors = AppColors.dark();

    return ThemeData(
      useMaterial3: true,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.surface,
      canvasColor: colors.surface,
      textTheme: AppTextStyles.dark,
      primaryTextTheme: AppTextStyles.dark.apply(
        bodyColor: colorScheme.onPrimary,
        displayColor: colorScheme.onPrimary,
      ),
      appBarTheme: _appBarTheme(colorScheme, colors),
      inputDecorationTheme: _inputDecorationTheme(colors),
      elevatedButtonTheme: _elevatedButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      textButtonTheme: _textButtonTheme,
      cardTheme: _cardTheme(colors),
      listTileTheme: _listTileTheme(colorScheme),
      dividerTheme: _dividerTheme(colors),
      chipTheme: _chipTheme(colorScheme),
      snackBarTheme: _snackBarTheme,
      floatingActionButtonTheme: _floatingActionButtonTheme,
      extensions: [colors],
    );
  }

  // ════════════════════════════════════════════
  //  COMPONENT THEMES (usan AppColors)
  // ════════════════════════════════════════════

  static AppBarTheme _appBarTheme(ColorScheme colorScheme, AppColors colors) =>
      AppBarTheme(
        backgroundColor: colorScheme.surfaceContainerHigh,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
          height: 1.2,
        ),
        iconTheme: IconThemeData(color: colors.textPrimary, size: 24),
        actionsIconTheme: IconThemeData(color: colors.textPrimary, size: 24),
      );

  static InputDecorationTheme _inputDecorationTheme(AppColors colors) {
    const borderRadius = BorderRadius.all(Radius.circular(12));

    final border = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: colors.border),
    );

    return InputDecorationTheme(
      hintStyle: TextStyle(
        fontSize: 14,
        color: colors.textHint, // ✅ Centralizado
        fontWeight: FontWeight.normal,
      ),
      filled: true,
      fillColor: colors.inputBackground,
      contentPadding: AppSpacing.inputPadding(),
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: colors.borderFocus, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: colors.errorText),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: colors.errorText, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: colors.border),
      ),
      labelStyle: TextStyle(fontSize: 14, color: colors.textSecondary),
      floatingLabelStyle: TextStyle(fontSize: 12, color: colors.borderFocus),
      helperStyle: TextStyle(fontSize: 12, color: colors.textSecondary),
      errorStyle: TextStyle(
          fontSize: 12, color: colors.errorText, fontWeight: FontWeight.w500),
      prefixIconColor: colors.textSecondary,
      suffixIconColor: colors.textSecondary,
    );
  }

  static ElevatedButtonThemeData get _elevatedButtonTheme {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        padding: AppSpacing.buttonPadding(),
        backgroundColor: _seedPrimary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.light().textDisabled,
        disabledForegroundColor: AppColors.light().textSecondary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        textStyle: AppTextStyles.buttonLabel,
      ),
    );
  }

  static OutlinedButtonThemeData get _outlinedButtonTheme {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: AppSpacing.buttonPadding(),
        foregroundColor: _seedPrimary,
        disabledForegroundColor: AppColors.light().textDisabled,
        side: const BorderSide(color: _seedPrimary, width: 1.5),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        textStyle: AppTextStyles.buttonLabel,
      ),
    );
  }

  static TextButtonThemeData get _textButtonTheme {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: AppSpacing.symmetric(
            horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
        foregroundColor: _seedPrimary,
        disabledForegroundColor: AppColors.light().textDisabled,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  static CardThemeData _cardTheme(AppColors colors) {
    return CardThemeData(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      color: colors.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      margin: AppSpacing.symmetric(
          vertical: AppSpacing.xxs, horizontal: AppSpacing.sm),
    );
  }

  static ListTileThemeData _listTileTheme(ColorScheme colorScheme) {
    return ListTileThemeData(
      textColor: colorScheme.onSurface,
      iconColor: colorScheme.onSurfaceVariant,
      titleTextStyle: AppTextStyles.listItemTitle.copyWith(fontSize: 14),
      subtitleTextStyle:
          TextStyle(fontSize: 13, color: AppColors.light().textSecondary),
      contentPadding: AppSpacing.symmetric(horizontal: AppSpacing.sm),
      visualDensity: const VisualDensity(vertical: -4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  static DividerThemeData _dividerTheme(AppColors colors) {
    return DividerThemeData(
      color: colors.divider, // ✅ Centralizado
      thickness: 1,
      space: AppSpacing.md,
      indent: AppSpacing.sm,
      endIndent: AppSpacing.sm,
    );
  }

  static ChipThemeData _chipTheme(ColorScheme colorScheme) {
    return ChipThemeData(
      backgroundColor: colorScheme.surfaceContainerHighest,
      deleteIconColor: colorScheme.onSurfaceVariant,
      disabledColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      padding: AppSpacing.symmetric(
          horizontal: AppSpacing.xxs, vertical: AppSpacing.xxxs),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  static SnackBarThemeData get _snackBarTheme {
    return SnackBarThemeData(
      backgroundColor: AppColors.dark().surfaceElevated, // ✅ Usar AppColors
      contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
      actionTextColor: _seedSecondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
    );
  }

  static FloatingActionButtonThemeData get _floatingActionButtonTheme {
    return FloatingActionButtonThemeData(
      backgroundColor: _seedPrimary,
      foregroundColor: Colors.white,
      elevation: 4,
      highlightElevation: 8,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    );
  }

  static ThemeData fromBrightness(Brightness brightness) {
    return brightness == Brightness.dark ? dark : light;
  }

  static ThemeData custom({
    Brightness brightness = Brightness.light,
    Color? seedColor,
    Color? secondaryColor,
    double? spacingScale,
  }) {
    if (spacingScale != null) {
      AppSpacing.setGlobalScale(spacingScale);
    }

    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor ?? _seedPrimary,
      secondary: secondaryColor ?? _seedSecondary,
      brightness: brightness,
    );

    final baseTheme = brightness == Brightness.dark ? dark : light;

    return baseTheme.copyWith(colorScheme: colorScheme);
  }
}
