import 'package:flutter/material.dart';
import 'package:conectasoc/app/theme/theme.dart';

class AppCardTheme {
  /// Cards principales (artículos, documentos)
  static CardThemeData get primary => CardThemeData(
        color: AppColors.surface,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadiusTheme.card,
          side: BorderSide(color: Colors.grey.shade200),
        ),
        clipBehavior: Clip.antiAlias,
      );

  /// Cards compactas (filtros, chips)
  static CardThemeData get compact => CardThemeData(
        color: AppColors.surface,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: AppRadiusTheme.card),
      );

  /// Cards con hover (web/desktop)
  static CardThemeData get interactive => CardThemeData(
        color: AppColors.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: AppRadiusTheme.card),
      );
}
