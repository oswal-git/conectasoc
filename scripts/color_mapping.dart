// 📁 scripts/color_mapping.dart
// ✅ VERSIÓN FINAL SIN ERRORES

/// 🎯 Mapeo de colores hardcoded a AppColors equivalents
///
/// Nota: Un mismo color hex puede tener múltiples usos semánticos.
/// El script prioriza según el contexto (nombre de variable, archivo, etc.)
abstract final class ColorMapping {
  const ColorMapping._();

  // ════════════════════════════════════════════
  //  MAPA PRINCIPAL (sin duplicados)
  //  Prioridad: text > background > border > semantic
  // ════════════════════════════════════════════

  static const Map<String, String> map = {
    // ── TEXT COLORS (prioridad alta) ───────────
    '0xFF212121': 'textPrimary',
    '0xFF757575': 'textSecondary',
    '0xFF7E7D7D': 'textHint',
    '0xFF9E9E9E': 'textHint',
    '0xFFBDBDBD': 'textDisabled',
    '0xFF616161': 'textSecondary',

    // ── BACKGROUND COLORS ──────────────────────
    '0xFFFFFFFF': 'surface',
    '0xFFFAFAFA': 'inputBackground',
    '0xFFF5F5F5': 'surface',
    '0xFF121212': 'surface',
    '0xFF1E1E1E': 'surfaceElevated',
    '0xFF2A2A2A': 'inputBackground',
    '0xFF323232': 'surfaceElevated',

    // ── BORDER/DIVIDER COLORS ──────────────────
    '0xFFE0E0E0': 'border',
    '0xFF424242': 'border',

    // ── PRIMARY/SECONDARY ──────────────────────
    '0xFF5E7E99': 'borderFocus',
    '0xFFA5CBEB': 'borderFocus',

    // ── ERROR COLORS ───────────────────────────
    '0xFFC62828': 'errorText',
    '0xFFD32F2F': 'errorText',
    '0xFFF44336': 'errorText',
    '0xFFFFEBEE': 'errorBg',
    '0xFFEF9A9A': 'errorText',

    // ── SUCCESS COLORS ─────────────────────────
    '0xFF2E7D32': 'successText',
    '0xFF388E3C': 'successIcon',
    '0xFFE8F5E9': 'successBg',
    '0xFFA5D6A7': 'successText',

    // ── WARNING COLORS ─────────────────────────
    '0xFFE65100': 'warningText',
    '0xFFFF9800': 'warningText',
    '0xFFFFF3E0': 'warningBg',
    '0xFFFFCC80': 'warningBorder',
    '0xFFFFB74D': 'warningText',

    // ── INFO COLORS ────────────────────────────
    '0xFF0D47A1': 'infoTextTitle',
    '0xFF1565C0': 'infoTextBody',
    '0xFFE3F2FD': 'infoBg',
    '0xFFBBDEFB': 'infoTextTitle',
    '0xFF90CAF9': 'infoTextBody',

    // ── OVERLAY COLORS ─────────────────────────
    '0x80000000': 'overlayDark',
    '0x03000000': 'overlayLoading',
  };

  // ════════════════════════════════════════════
  //  MAPAS SEMÁNTICOS ESPECÍFICOS
  // ════════════════════════════════════════════

  static const Map<String, String> fileTypeMap = {
    '0xFFC62828': 'fileTypePdf',
    '0xFF1565C0': 'fileTypeWord',
    '0xFF2E7D32': 'fileTypeExcel',
    '0xFFE65100': 'fileTypePpt',
    '0xFF616161': 'fileTypeDefault',
  };

  static const Map<String, String> statusMap = {
    '0xFFE3F2FD': 'redaccion',
    '0xFFFFFDE7': 'revision',
    '0xFFFFF3E0': 'expirado',
    '0xFFFFEBEE': 'anulado',
  };

  static const Map<String, String> infoBannerMap = {
    '0xFFE3F2FD': 'infoBg',
    '0xFFA5CBEB': 'infoBorder',
    '0xFF5E7E99': 'infoIcon',
    '0xFF0D47A1': 'infoTextTitle',
    '0xFF1565C0': 'infoTextBody',
  };

  static const Map<String, String> materialColorMap = {
    'Colors.white': 'surface',
    'Colors.black': 'textPrimary',
    'Colors.black87': 'textPrimary',
    'Colors.black54': 'textSecondary',
    'Colors.black45': 'textSecondary',
    'Colors.black38': 'textDisabled',
    'Colors.black26': 'textDisabled',
    'Colors.black12': 'textDisabled',
    'Colors.white70': 'textSecondary',
    'Colors.white60': 'textSecondary',
    'Colors.white54': 'textSecondary',
    'Colors.white38': 'textDisabled',
    'Colors.white24': 'textDisabled',
    'Colors.white12': 'textDisabled',
    'Colors.red': 'errorText',
    'Colors.green': 'successText',
    'Colors.orange': 'warningText',
    'Colors.blue': 'infoTextBody',
    'Colors.grey': 'textSecondary',
    'Colors.grey.shade50': 'inputBackground',
    'Colors.grey.shade100': 'surface',
    'Colors.grey.shade200': 'border',
    'Colors.grey.shade300': 'border',
    'Colors.grey.shade400': 'textDisabled',
    'Colors.grey.shade500': 'textSecondary',
    'Colors.grey.shade600': 'textSecondary',
    'Colors.grey.shade700': 'textSecondary',
    'Colors.grey.shade800': 'border',
    'Colors.grey.shade900': 'textPrimary',
  };

  // ════════════════════════════════════════════
  //  MÉTODOS DE BÚSQUEDA
  // ════════════════════════════════════════════

  static String? getAppColorsProperty(String hexColor) {
    final normalized = _normalizeHex(hexColor);
    return map[normalized];
  }

  static String? getFileTypeProperty(String hexColor) {
    final normalized = _normalizeHex(hexColor);
    return fileTypeMap[normalized];
  }

  static String? getStatusProperty(String hexColor) {
    final normalized = _normalizeHex(hexColor);
    return statusMap[normalized];
  }

  static String? getInfoBannerProperty(String hexColor) {
    final normalized = _normalizeHex(hexColor);
    return infoBannerMap[normalized];
  }

  static String? getMaterialColorProperty(String materialColor) {
    return materialColorMap[materialColor];
  }

  static String? getContextualProperty(String hexColor, String filePath) {
    final normalized = _normalizeHex(hexColor);
    final lowerPath = filePath.toLowerCase();

    if (lowerPath.contains('file') || lowerPath.contains('document')) {
      return fileTypeMap[normalized] ?? map[normalized];
    }

    if (lowerPath.contains('status') || lowerPath.contains('article')) {
      return statusMap[normalized] ?? map[normalized];
    }

    if (lowerPath.contains('banner') || lowerPath.contains('info')) {
      return infoBannerMap[normalized] ?? map[normalized];
    }

    return map[normalized];
  }

  static String _normalizeHex(String hex) {
    if (!hex.startsWith('0x')) {
      return '0x$hex';
    }
    return hex.toUpperCase();
  }

  static Set<String> getAllMappedColors() {
    return {
      ...map.keys,
      ...fileTypeMap.keys,
      ...statusMap.keys,
      ...infoBannerMap.keys,
      ...materialColorMap.keys,
    };
  }

  // ✅ CORREGIDO: Usar Map.fromEntries() con entries.where()
  static Map<String, List<String>> getAmbiguousColors() {
    final colorToProps = <String, List<String>>{};

    void add(String hex, String prop) {
      final normalized = _normalizeHex(hex);
      colorToProps.putIfAbsent(normalized, () => []).add(prop);
    }

    map.forEach((hex, prop) => add(hex, prop));
    fileTypeMap.forEach((hex, prop) => add(hex, prop));
    statusMap.forEach((hex, prop) => add(hex, prop));
    infoBannerMap.forEach((hex, prop) => add(hex, prop));

    // ✅ FILTRAR entries y convertir de nuevo a Map
    return Map.fromEntries(
        colorToProps.entries.where((entry) => entry.value.length > 1));
  }
}
