// 📁 lib/theme/app_spacing.dart
import 'package:flutter/material.dart';

/// 🎯 Design tokens de spacing — Escala 4pt (Material Design)
///
/// ## Uso básico:
/// ```dart
/// Padding(padding: EdgeInsets.all(AppSpacing.lg))
/// SizedBox(height: AppSpacing.xl)
/// ```
///
/// ## Escalar toda la app:
/// ```dart
/// // En main.dart, al iniciar:
/// AppSpacing.setGlobalScale(1.2); // +20% en todos los espaciados
/// ```
abstract final class AppSpacing {
  const AppSpacing._();

  // ════════════════════════════════════════════
  //  CONFIGURACIÓN GLOBAL
  // ════════════════════════════════════════════

  /// 🔹 Unidad base del sistema (4px = estándar Material)
  /// Cambia este valor para escalar PROPORCIONALMENTE todo el sistema
  static const double unit = 4.0;

  /// 🔹 Factor de escala global (para accesibilidad o preferencias de usuario)
  /// Valor por defecto: 1.0 (100%)
  /// Rango recomendado: 0.8 (compacto) - 1.5 (muy grande)
  static double _globalScale = 1.0;

  /// ✅ Configura la escala global en runtime
  /// Ej: AppSpacing.setGlobalScale(1.2) para +20%
  static void setGlobalScale(double scale) {
    assert(scale > 0 && scale <= 2.0, 'Scale must be between 0.0 and 2.0');
    _globalScale = scale;
  }

  /// ✅ Obtiene la escala actual (útil para debugging o cálculos custom)
  static double get globalScale => _globalScale;

  // ════════════════════════════════════════════
  //  SPACING TOKENS (const → compile-time)
  //  Definidos como múltiplos de `unit` para escalabilidad
  // ════════════════════════════════════════════

  static const double xxxs = 1 * unit; // 4px  — mínimo, separadores internos
  static const double xxs = 2 * unit; // 8px  — iconos pequeños, chips
  static const double xs = 3 * unit; // 12px — padding compacto
  static const double sm = 4 * unit; // 16px — padding estándar (lg en M3)
  static const double md = 5 * unit; // 20px — entre secciones
  static const double lg = 6 * unit; // 24px — padding páginas, cards
  static const double xl = 8 * unit; // 32px — separación de bloques
  static const double xxl = 10 * unit; // 40px — secciones principales
  static const double xxxl = 12 * unit; // 48px — márgenes grandes
  static const double huge = 16 * unit; // 64px — hero sections

  // ════════════════════════════════════════════
  //  GETTERS ESCALADOS (runtime, para UI dinámica)
  // ════════════════════════════════════════════

  static double get xxxsScaled => xxxs * _globalScale;
  static double get xxsScaled => xxs * _globalScale;
  static double get xsScaled => xs * _globalScale;
  static double get smScaled => sm * _globalScale;
  static double get mdScaled => md * _globalScale;
  static double get lgScaled => lg * _globalScale;
  static double get xlScaled => xl * _globalScale;
  static double get xxlScaled => xxl * _globalScale;
  static double get xxxlScaled => xxxl * _globalScale;
  static double get hugeScaled => huge * _globalScale;

  /// ✅ Obtiene un valor escalado genérico
  static double scale(double baseValue) => baseValue * _globalScale;

  // ════════════════════════════════════════════
  //  HELPERS DE EdgeInsets (con defaults const)
  // ════════════════════════════════════════════

  /// Padding simétrico horizontal/vertical
  static EdgeInsets symmetric({
    double horizontal = 0,
    double vertical = 0,
  }) =>
      EdgeInsets.symmetric(
        horizontal: horizontal,
        vertical: vertical,
      );

  /// Padding simétrico con escala aplicada
  static EdgeInsets symmetricScaled({
    double horizontalBase = 0,
    double verticalBase = 0,
  }) =>
      EdgeInsets.symmetric(
        horizontal: horizontalBase * _globalScale,
        vertical: verticalBase * _globalScale,
      );

  /// Padding uniforme en los 4 lados
  static EdgeInsets all(double value) => EdgeInsets.all(value);

  /// Padding uniforme con escala aplicada
  static EdgeInsets allScaled(double baseValue) =>
      EdgeInsets.all(baseValue * _globalScale);

  /// Padding personalizado (wrapper de EdgeInsets.only)
  static EdgeInsets only({
    double top = 0,
    double right = 0,
    double bottom = 0,
    double left = 0,
  }) =>
      EdgeInsets.only(
        top: top,
        right: right,
        bottom: bottom,
        left: left,
      );

  // ════════════════════════════════════════════
  //  HELPERS ESPECÍFICOS DE COMPONENTES
  //  Usan valores base (const) para máximo rendimiento
  // ════════════════════════════════════════════

  /// Padding para botones primarios
  static EdgeInsets buttonPadding({
    double horizontal = xl, // 32px base
    double vertical = sm, // 16px base
  }) =>
      EdgeInsets.symmetric(
        horizontal: horizontal,
        vertical: vertical,
      );

  /// Padding para cards
  static EdgeInsets cardPadding({
    double horizontal = sm, // 16px
    double vertical = xs, // 12px
  }) =>
      EdgeInsets.symmetric(
        horizontal: horizontal,
        vertical: vertical,
      );

  /// Padding para páginas principales
  static EdgeInsets pagePadding({
    double horizontal = sm, // 16px
    double vertical = xs, // 12px
  }) =>
      EdgeInsets.symmetric(
        horizontal: horizontal,
        vertical: vertical,
      );

  /// Padding para inputs / text fields
  static EdgeInsets inputPadding({
    double horizontal = sm, // 16px
    double vertical = xxs, // 8px
  }) =>
      EdgeInsets.symmetric(
        horizontal: horizontal,
        vertical: vertical,
      );

  /// Padding para listas / ListTiles
  static EdgeInsets listPadding({
    double horizontal = sm, // 16px
    double vertical = xxxs, // 4px
  }) =>
      EdgeInsets.symmetric(
        horizontal: horizontal,
        vertical: vertical,
      );

  // ════════════════════════════════════════════
  //  HELPERS DE SizedBox (para espaciado vertical/horizontal)
  // ════════════════════════════════════════════

  static SizedBox height(double value) => SizedBox(height: value);
  static SizedBox width(double value) => SizedBox(width: value);

  // Getters para valores comunes (const-safe)
  static SizedBox get xxxsHeight => SizedBox(height: xxxs);
  static SizedBox get xxsHeight => SizedBox(height: xxs);
  static SizedBox get xsHeight => SizedBox(height: xs);
  static SizedBox get smHeight => SizedBox(height: sm);
  static SizedBox get mdHeight => SizedBox(height: md);
  static SizedBox get lgHeight => SizedBox(height: lg);
  static SizedBox get xlHeight => SizedBox(height: xl);

  static SizedBox get xxxsWidth => SizedBox(width: xxxs);
  static SizedBox get xxsWidth => SizedBox(width: xxs);
  static SizedBox get xsWidth => SizedBox(width: xs);
  static SizedBox get smWidth => SizedBox(width: sm);
}
