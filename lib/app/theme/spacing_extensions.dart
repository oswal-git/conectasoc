// 📁 lib/extensions/spacing_extensions.dart
import 'package:conectasoc/app/theme/theme.dart';
import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';

/// ✨ Extensiones para mejorar Developer Experience
/// Importa este archivo en tu `main.dart` o en un barrel file

// ════════════════════════════════════════════
//  Extensions para num → Spacing helpers
// ════════════════════════════════════════════

extension SpacingNum on num {
  /// Ej: `16.spaceH` → SizedBox(height: 16)
  SizedBox get spaceH => SizedBox(height: toDouble());

  /// Ej: `8.spaceW` → SizedBox(width: 8)
  SizedBox get spaceW => SizedBox(width: toDouble());

  /// Ej: `16.pt` → EdgeInsets.all(16)
  EdgeInsets get pt => EdgeInsets.all(toDouble());

  /// Ej: `16.hSym` → EdgeInsets.symmetric(horizontal: 16)
  EdgeInsets get hSym => EdgeInsets.symmetric(horizontal: toDouble());

  /// Ej: `12.vSym` → EdgeInsets.symmetric(vertical: 12)
  EdgeInsets get vSym => EdgeInsets.symmetric(vertical: toDouble());

  /// Ej: `16.scaled` → AppSpacing.scale(16)
  double get scaled => AppSpacing.scale(toDouble());

  /// Ej: `16.scaledPt` → EdgeInsets.all(16 * scale)
  EdgeInsets get scaledPt =>
      EdgeInsets.all(toDouble() * AppSpacing.globalScale);
}

// ════════════════════════════════════════════
//  Extensions para Widget → Padding helpers
// ════════════════════════════════════════════

extension WidgetPadding on Widget {
  /// Ej: `Text('Hola').padAll(16)` → Padding(padding: EdgeInsets.all(16), child: Text)
  Padding padAll(double value) => Padding(
        padding: EdgeInsets.all(value),
        child: this,
      );

  /// Ej: `Text('Hola').padSym(h: 16, v: 8)`
  Padding padSym({double h = 0, double v = 0}) => Padding(
        padding: EdgeInsets.symmetric(horizontal: h, vertical: v),
        child: this,
      );

  /// Ej: `Text('Hola').padOnly(top: 8)`
  Padding padOnly(
          {double top = 0,
          double right = 0,
          double bottom = 0,
          double left = 0}) =>
      Padding(
        padding:
            EdgeInsets.only(top: top, right: right, bottom: bottom, left: left),
        child: this,
      );

  /// Ej: `Text('Hola').padAppSm` → usa AppSpacing.sm
  Padding padAppSm() => Padding(
        padding: EdgeInsets.all(AppSpacing.sm),
        child: this,
      );

  /// Ej: `Text('Hola').padAppCard` → padding estándar para cards
  Padding padAppCard() => Padding(
        padding: AppSpacing.cardPadding(),
        child: this,
      );
}

// ════════════════════════════════════════════
//  Extensions para BuildContext → Theme helpers
// ════════════════════════════════════════════

extension ThemeContext on BuildContext {
  /// ✅ Acceso rápido a AppColors
  AppColors get appColors => AppColors.of(this);

  /// ✅ Verifica si es dark mode
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// ✅ TextScaler con límite seguro
  TextScaler get safeTextScaler =>
      MediaQuery.textScalerOf(this).clamp(maxScaleFactor: 1.3);
}
