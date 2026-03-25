// 📁 scripts/check_ambiguous_colors.dart
import 'package:flutter/material.dart';

import 'color_mapping.dart';

void main() {
  debugPrint('🔍 COLORES AMBIGUOS (múltiples usos semánticos)');
  debugPrint('═' * 60);

  final ambiguous = ColorMapping.getAmbiguousColors();

  if (ambiguous.isEmpty) {
    debugPrint('✅ No hay colores ambiguos');
  } else {
    for (final entry in ambiguous.entries) {
      debugPrint('');
      debugPrint('🎨 ${entry.key}');
      debugPrint('   Usos: ${entry.value.join(", ")}');
      debugPrint('   Decisión por contexto:');

      for (final prop in entry.value) {
        if (prop.contains('file')) {
          debugPrint('     • Archivos con "file" o "document" → $prop');
        } else if (prop.contains('status') ||
            prop.contains('redaccion') ||
            prop.contains('expirado') ||
            prop.contains('anulado')) {
          debugPrint('     • Archivos con "article" o "status" → $prop');
        } else if (prop.contains('info') || prop.contains('banner')) {
          debugPrint('     • Archivos con "banner" o "info" → $prop');
        } else {
          debugPrint('     • Default → $prop');
        }
      }
    }
  }

  debugPrint('');
  debugPrint('═' * 60);
  debugPrint('💡 Estos colores requieren review manual post-migración');
}
