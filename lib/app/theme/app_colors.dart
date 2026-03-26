// 📁 lib/theme/app_colors.dart
import 'package:flutter/material.dart';

/// 🎨 Design tokens de colores — Single Source of Truth
///
/// ## Reglas:
/// 1. ✅ NUNCA uses `Color(0xFF...)` fuera de este archivo
/// 2. ✅ Usa nombres semánticos (ej: `neutralText`, no `grey600`)
/// 3. ✅ Light/Dark definidos en factories separados
/// 4. ✅ Accede vía `AppColors.of(context)` o `AppColors.light.neutralText`
class AppColors extends ThemeExtension<AppColors> {
  // ════════════════════════════════════════════
  //  COLORES NEUTROS (Greyscale)
  //  Usados para texto, bordes, fondos, etc.
  // ════════════════════════════════════════════

  /// Texto primario (títulos, contenido principal)
  final Color textPrimary;

  /// Texto secundario (subtítulos, descripciones)
  final Color textSecondary;

  /// Texto tertiary (hints, placeholders, texto deshabilitado)
  final Color textHint;

  /// Texto deshabilitado (botones, inputs disabled)
  final Color textDisabled;

  /// Fondos de superficie (cards, sheets)
  final Color surface;

  /// Fondos de superficie elevada (dialogs, modals)
  final Color surfaceElevated;

  /// Fondos de inputs (TextField, filled)
  final Color inputBackground;

  /// Bordes estándar (dividers, input borders)
  final Color border;

  /// Bordes enfocados (input focused)
  final Color borderFocus;

  /// Divisores entre secciones
  final Color divider;

  /// Overlay oscuro (modals, dialogs backdrop)
  final Color overlayDark;

  /// Overlay loading (mínima opacidad)
  final Color overlayLoading;

  // ════════════════════════════════════════════
  //  GETTERS ALIAS (para compatibilidad)
  // ════════════════════════════════════════════

  /// ✅ Alias para textSecondary (backward compatibility)
  Color get neutralText => textSecondary;

  /// ✅ Alias para textDisabled (dark variant)
  Color get neutralTextDark => textDisabled;

  /// ✅ Alias para border
  Color get neutralDivider => border;

  // ════════════════════════════════════════════
  //  COLORES SEMÁNTICOS DE DOMINIO
  // ════════════════════════════════════════════

  /// Estados de artículos/documentos
  final Color redaccion;
  final Color revision;
  final Color expirado;
  final Color anulado;

  /// Tipos de archivo
  final Color fileTypePdf;
  final Color fileTypeWord;
  final Color fileTypeExcel;
  final Color fileTypePpt;
  final Color fileTypeDefault;

  /// Banners informativos
  final Color infoBg;
  final Color infoBorder;
  final Color infoIcon;
  final Color infoTextTitle;
  final Color infoTextBody;

  final Color successBg;
  final Color successIcon;
  final Color successText;

  final Color warningBg;
  final Color warningBorder;
  final Color warningText;

  final Color errorBg;
  final Color errorIcon;
  final Color errorText;

  const AppColors({
    // Neutros
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.textDisabled,
    required this.surface,
    required this.surfaceElevated,
    required this.inputBackground,
    required this.border,
    required this.borderFocus,
    required this.divider,
    required this.overlayDark,
    required this.overlayLoading,

    // Dominio
    required this.redaccion,
    required this.revision,
    required this.expirado,
    required this.anulado,
    required this.fileTypePdf,
    required this.fileTypeWord,
    required this.fileTypeExcel,
    required this.fileTypePpt,
    this.fileTypeDefault = const Color(0xFF616161),
    required this.infoBg,
    required this.infoBorder,
    required this.infoIcon,
    required this.infoTextTitle,
    required this.infoTextBody,
    required this.successBg,
    required this.successIcon,
    required this.successText,
    required this.warningBg,
    required this.warningBorder,
    required this.warningText,
    required this.errorBg,
    required this.errorIcon,
    required this.errorText,
  });

  // ════════════════════════════════════════════
  //  COPYWITH
  // ════════════════════════════════════════════

  @override
  AppColors copyWith({
    Color? textPrimary,
    Color? textSecondary,
    Color? textHint,
    Color? textDisabled,
    Color? surface,
    Color? surfaceElevated,
    Color? inputBackground,
    Color? border,
    Color? borderFocus,
    Color? divider,
    Color? overlayDark,
    Color? overlayLoading,
    Color? redaccion,
    Color? revision,
    Color? expirado,
    Color? anulado,
    Color? fileTypePdf,
    Color? fileTypeWord,
    Color? fileTypeExcel,
    Color? fileTypePpt,
    Color? fileTypeDefault,
    Color? infoBg,
    Color? infoBorder,
    Color? infoIcon,
    Color? infoTextTitle,
    Color? infoTextBody,
    Color? successBg,
    Color? successIcon,
    Color? successText,
    Color? warningBg,
    Color? warningBorder,
    Color? warningText,
    Color? errorBg,
    Color? errorIcon,
    Color? errorText,
  }) {
    return AppColors(
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textHint: textHint ?? this.textHint,
      textDisabled: textDisabled ?? this.textDisabled,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      inputBackground: inputBackground ?? this.inputBackground,
      border: border ?? this.border,
      borderFocus: borderFocus ?? this.borderFocus,
      divider: divider ?? this.divider,
      overlayDark: overlayDark ?? this.overlayDark,
      overlayLoading: overlayLoading ?? this.overlayLoading,
      redaccion: redaccion ?? this.redaccion,
      revision: revision ?? this.revision,
      expirado: expirado ?? this.expirado,
      anulado: anulado ?? this.anulado,
      fileTypePdf: fileTypePdf ?? this.fileTypePdf,
      fileTypeWord: fileTypeWord ?? this.fileTypeWord,
      fileTypeExcel: fileTypeExcel ?? this.fileTypeExcel,
      fileTypePpt: fileTypePpt ?? this.fileTypePpt,
      fileTypeDefault: fileTypeDefault ?? this.fileTypeDefault,
      infoBg: infoBg ?? this.infoBg,
      infoBorder: infoBorder ?? this.infoBorder,
      infoIcon: infoIcon ?? this.infoIcon,
      infoTextTitle: infoTextTitle ?? this.infoTextTitle,
      infoTextBody: infoTextBody ?? this.infoTextBody,
      successBg: successBg ?? this.successBg,
      successIcon: successIcon ?? this.successIcon,
      successText: successText ?? this.successText,
      warningBg: warningBg ?? this.warningBg,
      warningBorder: warningBorder ?? this.warningBorder,
      warningText: warningText ?? this.warningText,
      errorBg: errorBg ?? this.errorBg,
      errorIcon: errorIcon ?? this.errorIcon,
      errorText: errorText ?? this.errorText,
    );
  }

  // ════════════════════════════════════════════
  //  LERP (animaciones de tema)
  // ════════════════════════════════════════════

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;

    return AppColors(
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      inputBackground: Color.lerp(inputBackground, other.inputBackground, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderFocus: Color.lerp(borderFocus, other.borderFocus, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      overlayDark: Color.lerp(overlayDark, other.overlayDark, t)!,
      overlayLoading: Color.lerp(overlayLoading, other.overlayLoading, t)!,
      redaccion: Color.lerp(redaccion, other.redaccion, t)!,
      revision: Color.lerp(revision, other.revision, t)!,
      expirado: Color.lerp(expirado, other.expirado, t)!,
      anulado: Color.lerp(anulado, other.anulado, t)!,
      fileTypePdf: Color.lerp(fileTypePdf, other.fileTypePdf, t)!,
      fileTypeWord: Color.lerp(fileTypeWord, other.fileTypeWord, t)!,
      fileTypeExcel: Color.lerp(fileTypeExcel, other.fileTypeExcel, t)!,
      fileTypePpt: Color.lerp(fileTypePpt, other.fileTypePpt, t)!,
      fileTypeDefault: Color.lerp(fileTypeDefault, other.fileTypeDefault, t)!,
      infoBg: Color.lerp(infoBg, other.infoBg, t)!,
      infoBorder: Color.lerp(infoBorder, other.infoBorder, t)!,
      infoIcon: Color.lerp(infoIcon, other.infoIcon, t)!,
      infoTextTitle: Color.lerp(infoTextTitle, other.infoTextTitle, t)!,
      infoTextBody: Color.lerp(infoTextBody, other.infoTextBody, t)!,
      successBg: Color.lerp(successBg, other.successBg, t)!,
      successIcon: Color.lerp(successIcon, other.successIcon, t)!,
      successText: Color.lerp(successText, other.successText, t)!,
      warningBg: Color.lerp(warningBg, other.warningBg, t)!,
      warningBorder: Color.lerp(warningBorder, other.warningBorder, t)!,
      warningText: Color.lerp(warningText, other.warningText, t)!,
      errorBg: Color.lerp(errorBg, other.errorBg, t)!,
      errorIcon: Color.lerp(errorIcon, other.errorIcon, t)!,
      errorText: Color.lerp(errorText, other.errorText, t)!,
    );
  }

  // ════════════════════════════════════════════
  //  ACCESO SEGURO
  // ════════════════════════════════════════════

  static AppColors of(BuildContext context) {
    final extension = Theme.of(context).extension<AppColors>();
    if (extension != null) return extension;
    return _lightDefaults;
  }

  static const AppColors _lightDefaults = AppColors(
    textPrimary: Color(0xFF212121),
    textSecondary: Color(0xFF757575),
    textHint: Color(0xFF7E7D7D),
    textDisabled: Color(0xFFBDBDBD),
    surface: Colors.white,
    surfaceElevated: Colors.white,
    inputBackground: Color(0xFFFAFAFA),
    border: Color(0xFFE0E0E0),
    borderFocus: Color(0xFF5E7E99),
    divider: Color(0xFFE0E0E0),
    overlayDark: Color(0x80000000),
    overlayLoading: Color(0x03000000),
    redaccion: Color(0xFFE3F2FD),
    revision: Color(0xFFFFFDE7),
    expirado: Color(0xFFFFF3E0),
    anulado: Color(0xFFFFEBEE),
    fileTypePdf: Color(0xFFC62828),
    fileTypeWord: Color(0xFF1565C0),
    fileTypeExcel: Color(0xFF2E7D32),
    fileTypePpt: Color(0xFFE65100),
    infoBg: Color(0xFFE3F2FD),
    infoBorder: Color(0xFFA5CBEB),
    infoIcon: Color(0xFF5E7E99),
    infoTextTitle: Color(0xFF0D47A1),
    infoTextBody: Color(0xFF1565C0),
    successBg: Color(0xFFE8F5E9),
    successIcon: Color(0xFF388E3C),
    successText: Color(0xFF2E7D32),
    warningBg: Color(0xFFFFF3E0),
    warningBorder: Color(0xFFFFCC80),
    warningText: Color(0xFFE65100),
    errorBg: Color(0xFFFFEBEE),
    errorIcon: Color(0xFFC62828),
    errorText: Color(0xFFC62828),
  );

  // ════════════════════════════════════════════
  //  FACTORIES
  // ════════════════════════════════════════════

  factory AppColors.light() => const AppColors(
        // Neutros Light
        textPrimary: Color(0xFF212121), // grey[900]
        textSecondary: Color(0xFF757575), // grey[600]
        textHint: Color(0xFF7E7D7D), // custom grey
        textDisabled: Color(0xFFBDBDBD), // grey[400]
        surface: Colors.white,
        surfaceElevated: Colors.white,
        inputBackground: Color(0xFFFAFAFA), // grey[50]
        border: Color(0xFFE0E0E0), // grey[300]
        borderFocus: Color(0xFF5E7E99), // primary
        divider: Color(0xFFE0E0E0), // grey[300]
        overlayDark: Color(0x80000000),
        overlayLoading: Color(0x03000000),

        // Dominio Light
        redaccion: Color(0xFFE3F2FD),
        revision: Color(0xFFFFFDE7),
        expirado: Color(0xFFFFF3E0),
        anulado: Color(0xFFFFEBEE),
        fileTypePdf: Color(0xFFC62828),
        fileTypeWord: Color(0xFF1565C0),
        fileTypeExcel: Color(0xFF2E7D32),
        fileTypePpt: Color(0xFFE65100),
        infoBg: Color(0xFFE3F2FD),
        infoBorder: Color(0xFFA5CBEB),
        infoIcon: Color(0xFF5E7E99),
        infoTextTitle: Color(0xFF0D47A1),
        infoTextBody: Color(0xFF1565C0),
        successBg: Color(0xFFE8F5E9),
        successIcon: Color(0xFF388E3C),
        successText: Color(0xFF2E7D32),
        warningBg: Color(0xFFFFF3E0),
        warningBorder: Color(0xFFFFCC80),
        warningText: Color(0xFFE65100),
        errorBg: Color(0xFFFFEBEE),
        errorIcon: Color(0xFFC62828),
        errorText: Color(0xFFC62828),
      );

  factory AppColors.dark() => const AppColors(
        // Neutros Dark
        textPrimary: Color(0xFFE0E0E0), // grey[300]
        textSecondary: Color(0xFFBDBDBD), // grey[400]
        textHint: Color(0xFF9E9E9E), // grey[400]
        textDisabled: Color(0xFF757575), // grey[600]
        surface: Color(0xFF121212), // grey[900]
        surfaceElevated: Color(0xFF1E1E1E), // grey[850]
        inputBackground: Color(0xFF2A2A2A), // grey[900]
        border: Color(0xFF424242), // grey[800]
        borderFocus: Color(0xFFA5CBEB), // secondary (más visible)
        divider: Color(0xFF424242), // grey[800]
        overlayDark: Color(0x80000000),
        overlayLoading: Color(0x03000000),

        // Dominio Dark (más saturados para visibilidad)
        redaccion: Color(0xFF1A3A52),
        revision: Color(0xFF3A3A1A),
        expirado: Color(0xFF4A301A),
        anulado: Color(0xFF4A1A20),
        fileTypePdf: Color(0xFFEF9A9A),
        fileTypeWord: Color(0xFF90CAF9),
        fileTypeExcel: Color(0xFFA5D6A7),
        fileTypePpt: Color(0xFFFFB74D),
        infoBg: Color(0xFF1A3A52),
        infoBorder: Color(0xFF3A6A92),
        infoIcon: Color(0xFFA5CBEB),
        infoTextTitle: Color(0xFFBBDEFB),
        infoTextBody: Color(0xFF90CAF9),
        successBg: Color(0xFF1B3A1F),
        successIcon: Color(0xFF81C784),
        successText: Color(0xFFA5D6A7),
        warningBg: Color(0xFF4A301A),
        warningBorder: Color(0xFF907040),
        warningText: Color(0xFFFFB74D),
        errorBg: Color(0xFF4A1A20),
        errorIcon: Color(0xFFEF9A9A),
        errorText: Color(0xFFEF9A9A),
      );
}
