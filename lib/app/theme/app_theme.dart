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

  static const Color primary = Color.fromARGB(255, 94, 126, 153);
  static const Color secondary = Color.fromARGB(255, 165, 203, 235);

  // Backgrounds
  static const Color background = Colors.white;
  static const Color surface = Colors.white;
  static const Color inputBackground = Color(0xFFFAFAFA); // grey[50]

  // Borders
  static const Color border = Color(0xFFE0E0E0); // grey[300]
  static const Color borderFocus = primary;

  // AppBar
  static const Color appBarBackground = primary;
  static const Color appBarForeground = Colors.white;

  // Text
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.black54;

  // Text Field
  static const Color textFieldEnabled = inputBackground;
  static const Color textFieldDisabled = Color(0xFFE0E0E0); // grey[300]
  static const Color textFieldHint = Color.fromARGB(255, 126, 125, 125);

  // Image icon
  static const Color imageIconHint = Color.fromARGB(255, 126, 125, 125);

  // Status
  static const Color error = Colors.red;
  static const Color success = Colors.green;
  static const Color warning = Colors.orange;

// Info banner (blue tints)
  static const Color infoBg = Color(0xFFE3F2FD); // blue.shade50
  static const Color infoBorder = secondary; // blue.shade200
  static const Color infoIcon = primary; // blue.shade700
  static const Color infoTextBody = Color(0xFF1565C0); // blue.shade800
  static const Color infoTextTitle = Color(0xFF0D47A1); // blue.shade900

  // Success banner (green tints)
  static const Color successBg = Color(0xFFE8F5E9); // green.shade50
  static const Color successIcon = Color(0xFF388E3C); // green.shade700

  // Warning banner (orange tints)
  static const Color warningBg = Color(0xFFFFF3E0); // orange.shade50
  static const Color warningBorder = Color(0xFFFFCC80); // orange.shade200

  // On-dark surfaces
  static const Color onDarkPrimary = Colors.white;
  static const Color onDarkSecondary = Color(0xB3FFFFFF); // white70
  static const Color overlayDark = Color(0x80000000); // black 50%
  static const Color overlayLoading = Color(0x03000000); // black ~1%

  // Neutral tints
  static const Color neutralBg = Color(0xFFF5F5F5); // grey.shade100
  static const Color neutralText = Color(0xFF757575); // grey.shade600
  static const Color neutralTextDark = Color(0xFF616161); // grey.shade700
  static const Color neutralDivider = border; // grey.shade300 (= border)

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

  /// 40 px — espacio superior en páginas de bienvenida
  static const double spaceTop = 20;

  /// 48 px — separación extra grande (fin de formulario)
  static const double spaceXl = 48;

  /// 60 px — espacio previo a secciones principales (welcome)
  static const double spaceSection = 30;

  // ════════════════════════════════════════════
  //  BORDER RADIUS TOKENS
  // ════════════════════════════════════════════

  static const double radiusDefault = 12;
  static const BorderRadius borderRadiusDefault =
      BorderRadius.all(Radius.circular(radiusDefault));

  /// Radio para tarjetas de bienvenida / modo card
  static const double radiusCard = 16;
  static const BorderRadius borderRadiusCard =
      BorderRadius.all(Radius.circular(radiusCard));

  /// Radio para contenedor logo (splash / welcome)
  static const double radiusLogo = 20;
  static const BorderRadius borderRadiusLogo =
      BorderRadius.all(Radius.circular(radiusLogo));

  /// Radio para contenedor logo grande (welcome)
  static const double radiusLogoLg = 30;
  static const BorderRadius borderRadiusLogoLg =
      BorderRadius.all(Radius.circular(radiusLogoLg));

  // ════════════════════════════════════════════
  //  AVATAR RADIUS TOKENS
  // ════════════════════════════════════════════

  /// Avatar estándar (autor, perfil inline)
  static const double avatarRadiusDefault = 20;

  /// Avatar logo grande (logo picker, perfil principal)
  static const double avatarRadiusLarge = 60;

  // ════════════════════════════════════════════
  //  ICON SIZE TOKENS
  // ════════════════════════════════════════════

  /// Icono hero (e.g. email verification)
  static const double iconSizeLarge = 100;

  /// Icono app en login / splash
  static const double iconSizeApp = 80;

  /// Icono placeholder de entidad (negocio, avatar vacío)
  static const double iconSizeMedium = 60;

  /// Icono en welcome cards
  static const double iconSizeCard = 32;

  /// Icono de acción en lista (delete Dismissible)
  static const double iconSizeAction = 32;

  /// Icono en filas de ajustes / edición inline
  static const double iconSizeXs = 24;

  /// Icono en botones pequeños / debug
  static const double iconSizeSmall = 16;

  /// Tamaño del contenedor de logo (splash / welcome)
  static const double logoContainerSize = 120;

  /// Tamaño del contenedor de icono en welcome cards
  static const double cardIconContainerSize = 56;

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
  static const double elevationCardHigh = 8;

  // ════════════════════════════════════════════
  //  LOADING INDICATOR TOKENS
  // ════════════════════════════════════════════

  /// Tamaño del CircularProgressIndicator inline (AppBar, botones)
  static const double loadingIndicatorSize = 24;

  /// Grosor del trazo del indicador inline
  static const double loadingStrokeWidth = 2;

  // ════════════════════════════════════════════
  //  PADDING HELPERS
  // ════════════════════════════════════════════

  /// Input content padding
  static const EdgeInsets paddingInput =
      EdgeInsets.symmetric(horizontal: spaceSm, vertical: spaceXs);

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

  /// Padding compacto para dropdowns en modo filtro / dense
  static const EdgeInsets paddingDropdownDense =
      EdgeInsets.symmetric(horizontal: 10, vertical: spaceXs);

  // ════════════════════════════════════════════
  //  TEXT WEIGHT TOKENS
  // ════════════════════════════════════════════

  static const FontWeight fontWeightBold = FontWeight.bold;
  static const FontWeight fontWeightSemi = FontWeight.w600;

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
      color: textFieldHint,
    ),
  );

  // ════════════════════════════════════════════
  //  SEMANTIC TEXT STYLES
  //
  //  Capa semántica sobre Material TextTheme.
  //  Los widgets consumen estos estilos, nunca
  //  textTheme.bodyLarge directamente.
  //  Para cambiar el texto de los artículos:
  //    → modifica articleTitle / articleBody
  //  Para cambiar botones:
  //    → modifica buttonLabel
  //  Los tipos Material (headlineMedium...) solo
  //  se tocan si cambia el sistema de diseño global.
  // ════════════════════════════════════════════

  // ── Splash / Welcome ─────────────────────
  /// Título principal splash (app name)
  static const TextStyle splashTitle = TextStyle(
    fontSize: 32,
    fontWeight: fontWeightBold,
    color: onDarkPrimary,
  );

  /// Subtítulo splash
  static const TextStyle splashSubtitle = TextStyle(
    fontSize: 16,
    color: onDarkSecondary,
  );

  /// Título hero en welcome (app name grande)
  static const TextStyle welcomeTitle = TextStyle(
    fontSize: 40,
    fontWeight: fontWeightBold,
    color: onDarkPrimary,
  );

  /// Subtítulo welcome
  static const TextStyle welcomeSubtitle = TextStyle(
    fontSize: 18,
    color: onDarkSecondary,
  );

  // ── Login / Auth ─────────────────────────
  /// Título de página de login (app name)
  static TextStyle loginTitle(BuildContext context) =>
      Theme.of(context).textTheme.headlineLarge!.copyWith(
            fontWeight: fontWeightBold,
            color: AppTheme.primary,
          );

  /// Subtítulo de login
  static TextStyle loginSubtitle(BuildContext context) =>
      Theme.of(context).textTheme.titleMedium!.copyWith(
            color: neutralText,
          );

  /// Texto separador 'O' en login
  static const TextStyle loginDividerLabel = TextStyle(
    color: neutralText,
  );

  /// Texto de enlace secundario (sin registrarse)
  static const TextStyle loginSecondaryLink = TextStyle(
      fontStyle: FontStyle.italic,
      // decoration: TextDecoration.underline,
      // decorationColor:
      //     Colors.blue, // color de la línea (por defecto hereda el del texto)
      // decorationThickness: 2.0, // grosor
      // decorationStyle: TextDecorationStyle.solid,
      fontSize: 14);

  // ── Botones ───────────────────────────────
  /// Label de botón primario / outline
  static const TextStyle buttonLabel = TextStyle(
    fontSize: 16,
    fontWeight: fontWeightBold,
  );

  // ── Info / banners ────────────────────────
  /// Título de banner informativo
  static const TextStyle infoBannerTitle = TextStyle(
    fontWeight: fontWeightBold,
    color: infoTextTitle,
  );

  /// Cuerpo de banner informativo
  static const TextStyle infoBannerBody = TextStyle(
    fontSize: 13,
    color: infoTextBody,
  );

  /// Texto de banner de aviso (warning/neutral)
  static const TextStyle warningBannerBody = TextStyle(
    fontSize: 13,
    color: neutralText,
  );

  // ── Cards (welcome) ───────────────────────
  /// Título de card de modo de acceso
  static const TextStyle cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: fontWeightBold,
  );

  static const TextStyle cardSubTitle = TextStyle(
    fontSize: 16,
    fontWeight: fontWeightBold,
  );

  /// Descripción de card de modo de acceso
  static const TextStyle cardDescription = TextStyle(
    fontSize: 12,
    color: neutralText,
  );

  // ── Captions ─────────────────────────────
  /// Texto pequeño explicativo / caption
  static const TextStyle caption = TextStyle(
    fontSize: 13,
    color: neutralText,
  );

  /// Etiqueta de sección en el Drawer (documentos, admin, etc.)
  static const TextStyle drawerSectionLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: neutralText,
    letterSpacing: 0.8,
  );

  // ── Email verification ────────────────────
  /// Email destacado en verificación
  static TextStyle verificationEmail(BuildContext context) =>
      Theme.of(context).textTheme.titleMedium!.copyWith(
            color: AppTheme.primary,
            fontWeight: fontWeightBold,
          );

  /// Instrucción en panel de verificación
  static const TextStyle verificationInstruction = TextStyle(
    color: infoTextTitle,
  );

  // ── Artículo ─────────────────────────────
  /// Título principal del artículo
  static TextStyle articleTitle(BuildContext context) =>
      Theme.of(context).textTheme.headlineMedium!.copyWith(
            fontSize: 24,
          );

  /// Cuerpo / contenido del artículo
  static TextStyle articleBody(BuildContext context) =>
      Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: textPrimary,
            fontSize: 14,
          );

  /// Metadatos del artículo (autor, fecha, categoría)
  static TextStyle articleMeta(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall!;

  /// Pie de artículo con énfasis en vigencia (italic)
  static TextStyle articleFooter(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall!.copyWith(
            fontStyle: FontStyle.italic,
          );

  // ── Página / sección ─────────────────────
  /// Título de sección dentro de una página
  static TextStyle sectionTitle(BuildContext context) =>
      Theme.of(context).textTheme.headlineSmall!;

  // ── Feedback / errores ───────────────────
  /// Mensaje de error amigable al usuario
  static TextStyle errorMessage(BuildContext context) =>
      Theme.of(context).textTheme.titleMedium!.copyWith(
            color: textSecondary,
          );

  /// Detalle técnico de error (monospace)
  static const TextStyle errorDetail = TextStyle(
    fontFamily: 'monospace',
    fontSize: 11,
    color: error,
  );

  /// Label de toggle para expandir/colapsar detalles
  /// Texto de item en dropdown compacto (filtros)
  static const TextStyle dropdownDenseItem = TextStyle(fontSize: 13);
  static const TextStyle toggleLabel = TextStyle(fontSize: 12);

  // ── Listas ───────────────────────────────
  /// Nombre principal de un item en lista
  static const TextStyle listCaptionTitle = TextStyle(
    fontWeight: fontWeightBold,
    fontSize: 14,
  );

  /// Nombre de un item en lista
  static const TextStyle listItemTitle = TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: 14,
  );

  // ── Acciones destructivas ────────────────
  /// Texto de botón o acción destructiva (eliminar, descartar)
  static const TextStyle destructiveAction = TextStyle(
    color: error,
  );

  // ════════════════════════════════════════════
  //  COMPONENT THEMES
  // ════════════════════════════════════════════

  static AppBarTheme get _appBarTheme => const AppBarTheme(
        backgroundColor: appBarBackground,
        foregroundColor: appBarForeground,
        elevation: elevationAppBar,
        centerTitle: true,
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
        hintStyle: TextStyle(color: textFieldHint),
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
        listTileTheme: ListTileThemeData(
          textColor: textPrimary,
          iconColor: textPrimary,
          titleTextStyle: listItemTitle.copyWith(
            fontSize: 12.0,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: spaceSm),
          visualDensity: const VisualDensity(vertical: -4),
        ),
      );
}
