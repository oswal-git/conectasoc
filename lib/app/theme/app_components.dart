import 'package:flutter/material.dart';
import 'theme.dart';

abstract final class AppComponents {
  const AppComponents._();

  static const appBar = AppBarTheme(
    elevation: 0,
    centerTitle: true,
    // ✅ Usa colorScheme del tema, no hardcoded
  );

  static InputDecorationTheme get input {
    return InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: AppSpacing.all(AppSpacing.lg),
      border: _border(Colors.grey.shade300),
      enabledBorder: _border(Colors.grey.shade300),
      focusedBorder: _border(AppColors.primary, width: 2),
      errorBorder: _border(Colors.red),
      focusedErrorBorder: _border(Colors.red, width: 2),
      hintStyle: const TextStyle(color: Colors.grey),
    );
  }

  static ElevatedButtonThemeData get elevatedButton {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: AppTextStyles.buttonLabel,
      ),
    );
  }

  static CardThemeData get card {
    return CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
    );
  }

  // 🔹 Helper privado
  static OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
