import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  AppTheme — Single source of truth
//  Material Design 3 · Blue primary palette
// ─────────────────────────────────────────────

abstract final class AppTheme {
  // ── Prevent instantiation ──────────────────
  const AppTheme._();

  // ════════════════════════════════════════════
  //  COLOR TOKENS — Primarios
  // ════════════════════════════════════════════

  static const Color primary = Colors.blue;
  static const Color secondary = Color(0xFF03DAC6);

  // Backgrounds
  static const Color background = Colors.white;
  static const Color surface = Colors.white;
  static const Color inputBackground = Color(0xFFFAFAFA); // grey[50]

  // Borders
  static const Color border = Color(0xFFE0E0E0); // grey[300]
  static const Color borderFocus = Colors.blue;

  // AppBar
  static const Color appBarBackground = Colors.blue;
  static const Color appBarForeground = Colors.white;

  // Text
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.black54;
  static const Color textHint = Colors.grey;

  // Status
  static const Color error = Colors.red;
  static const Color success = Colors.green;
  static const Color warning = Colors.orange;

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
  //  AVATAR RADIUS TOKENS
  // ════════════════════════════════════════════

  /// Avatar estándar (autor, perfil inline)
  static const double avatarRadiusDefault = 20;

  // ════════════════════════════════════════════
  //  LAYOUT CONSTRAINTS
  // ════════════════════════════════════════════

  /// Ancho máximo del contenedor web principal
  static const double maxWidthWebContent = 1300;

  /// Ancho máximo de imagen cover en web
  static const double maxWidthCoverImage = 400;

  /// Ancho máximo de sección solo-imagen en web
  static const double maxWidthSectionImage = 600;

  /// Breakpoint mobile → web
  static const double breakpointWeb = 768;

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

  static const TextTheme _textTheme = TextTheme(
    // Títulos principales
    headlineMedium: TextStyle(
      fontWeight: FontWeight.bold,
      color: textPrimary,
    ),
    // Texto destacado / subtítulos
    titleMedium: TextStyle(
      fontWeight: FontWeight.bold,
      color: textPrimary,
    ),
    // Texto descriptivo
    bodyLarge: TextStyle(
      color: textPrimary,
    ),
    // Texto secundario / auxiliar
    bodySmall: TextStyle(
      color: textSecondary,
    ),
    // Etiquetas (drawer, chips, etc.)
    labelMedium: TextStyle(
      fontWeight: FontWeight.w600,
      letterSpacing: 0.8,
      color: textPrimary,
    ),
    // Hint / placeholders
    bodyMedium: TextStyle(
      color: textHint,
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
        hintStyle: TextStyle(color: textHint),
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
        color: surface,
        shape: const RoundedRectangleBorder(
          borderRadius: borderRadiusDefault,
        ),
      );

  // ════════════════════════════════════════════
  //  THEME DATA  (public entry point)
  // ════════════════════════════════════════════

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          secondary: secondary,
          error: error,
          surface: surface,
          onSurface: textPrimary,
        ),
        scaffoldBackgroundColor: background,
        textTheme: _textTheme,
        appBarTheme: _appBarTheme,
        inputDecorationTheme: _inputDecorationTheme,
        elevatedButtonTheme: _elevatedButtonTheme,
        cardTheme: _cardTheme,
      );
}
