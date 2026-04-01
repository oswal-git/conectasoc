import 'package:flutter/material.dart';
import 'package:conectasoc/app/theme/theme.dart';

class AppButtonTheme {
  static ElevatedButtonThemeData get elevated => ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: AppSpacingTheme.paddingButton,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadiusTheme.button,
          ),
          elevation: 0,
        ),
      );

  static TextButtonThemeData get text => TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: AppSpacingTheme.paddingButton,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadiusTheme.button,
          ),
        ),
      );
}
