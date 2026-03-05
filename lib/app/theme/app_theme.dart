import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  AppTheme — Single source of truth
//  Material Design 3 · Blue primary palette
// ─────────────────────────────────────────────

abstract final class AppTheme {
  // ── Prevent instantiation ──────────────────
  const AppTheme._();

  // ════════════════════════════════════════════
  //  COLOR TOKENS
  // ════════════════════════════════════════════

  static const Color primary = Colors.blue;
  static const Color inputBackground = Color(0xFFFAFAFA); // Colors.grey[50]
  static const Color border = Color(0xFFE0E0E0); // Colors.grey[300]
  static const Color borderFocus = Colors.blue;
  static const Color error = Colors.red;
  static const Color appBarBackground = Colors.blue;
  static const Color appBarForeground = Colors.white;

  // ════════════════════════════════════════════
  //  SPACING TOKENS
  // ════════════════════════════════════════════

  /// Separación mínima — 4 px
  static const double spaceXxs = 4;

  /// Separación pequeña — 8 px
  static const double spaceXs = 8;

  /// Separación estándar — 16 px
  static const double spaceSm = 16;

  /// Separación entre elementos — 24 px
  static const double spaceMd = 24;

  /// Separación entre secciones — 32 px
  static const double spaceLg = 32;

  // ════════════════════════════════════════════
  //  BORDER RADIUS TOKENS
  // ════════════════════════════════════════════

  static const double radiusDefault = 12;
  static const BorderRadius borderRadiusDefault =
      BorderRadius.all(Radius.circular(radiusDefault));

  // ════════════════════════════════════════════
  //  ELEVATION TOKENS
  // ════════════════════════════════════════════

  static const double elevationAppBar = 0;
  static const double elevationCard = 2;
  static const double elevationButton = 2;

  // ════════════════════════════════════════════
  //  ICON SIZE TOKENS
  // ════════════════════════════════════════════

  /// Icono destacado (e.g. email verification hero)
  static const double iconSizeLarge = 100;

  /// Icono en botones secundarios / debug
  static const double iconSizeSmall = 16;

  // ════════════════════════════════════════════
  //  PADDING HELPERS
  // ════════════════════════════════════════════

  /// Input content padding
  static const EdgeInsets paddingInput =
      EdgeInsets.symmetric(horizontal: spaceSm, vertical: spaceSm);

  /// ElevatedButton primary padding
  static const EdgeInsets paddingButtonPrimary =
      EdgeInsets.symmetric(horizontal: spaceMd, vertical: spaceSm);

  /// Small / debug button padding
  static const EdgeInsets paddingButtonSmall =
      EdgeInsets.symmetric(horizontal: 12, vertical: spaceXs);

  /// General container padding
  static const EdgeInsets paddingPage = EdgeInsets.all(spaceMd);

  /// Info-container padding
  static const EdgeInsets paddingContainer = EdgeInsets.all(spaceSm);

  /// Profile padding
  static const EdgeInsets paddingProfile = EdgeInsets.all(spaceSm);

  // ════════════════════════════════════════════
  //  TEXT STYLES
  // ════════════════════════════════════════════

  // Override only the styles actually used in the app;
  // the rest delegate to Material 3 defaults.

  static TextTheme get _textTheme => const TextTheme(
        headlineMedium: TextStyle(
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(),
        bodySmall: TextStyle(),
        labelMedium: TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      );

  // ════════════════════════════════════════════
  //  COMPONENT THEMES
  // ════════════════════════════════════════════

  static AppBarTheme get _appBarTheme => const AppBarTheme(
        backgroundColor: appBarBackground,
        foregroundColor: appBarForeground,
        elevation: elevationAppBar,
        centerTitle: false,
      );

  static InputDecorationTheme get _inputDecorationTheme => InputDecorationTheme(
        filled: true,
        fillColor: inputBackground,
        contentPadding: paddingInput,
        border: OutlineInputBorder(
          borderRadius: borderRadiusDefault,
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadiusDefault,
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadiusDefault,
          borderSide: const BorderSide(color: borderFocus, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: borderRadiusDefault,
          borderSide: const BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: borderRadiusDefault,
          borderSide: const BorderSide(color: error, width: 2),
        ),
      );

  static ElevatedButtonThemeData get _elevatedButtonTheme =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: elevationButton,
          padding: paddingButtonPrimary,
          shape: const RoundedRectangleBorder(
            borderRadius: borderRadiusDefault,
          ),
        ),
      );

  static CardThemeData get _cardTheme => CardThemeData(
        elevation: elevationCard,
        shape: const RoundedRectangleBorder(
          borderRadius: borderRadiusDefault,
        ),
      );

  // ════════════════════════════════════════════
  //  THEME DATA  (public entry point)
  // ════════════════════════════════════════════

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          error: error,
        ),
        textTheme: _textTheme,
        appBarTheme: _appBarTheme,
        inputDecorationTheme: _inputDecorationTheme,
        elevatedButtonTheme: _elevatedButtonTheme,
        cardTheme: _cardTheme,
      );
}
