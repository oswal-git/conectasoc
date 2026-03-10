// lib/features/auth/presentation/widgets/auth_text_field.dart

import 'package:conectasoc/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AuthTextFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final bool enabled;
  final EdgeInsetsGeometry?
      contentPadding; // ← null = hereda AppTheme.paddingInput

  const AuthTextFieldWidget({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.enabled = true,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      enabled: enabled,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        fillColor:
            enabled ? AppTheme.textFieldEnabled : AppTheme.textFieldDisabled,
        contentPadding: contentPadding,
        // border: OutlineInputBorder(
        //   borderRadius: AppTheme.borderRadiusDefault,
        // ),
        // enabledBorder: OutlineInputBorder(
        //   borderRadius: AppTheme.borderRadiusDefault,
        //   borderSide: BorderSide(
        //     color: AppTheme.border,
        //     width: 1.5,
        //   ),
        // ),
        // focusedBorder: OutlineInputBorder(
        //   borderRadius: AppTheme.borderRadiusDefault,
        //   borderSide: BorderSide(
        //     color: AppTheme.border,
        //     width: 2,
        //   ),
        // ),
        // errorBorder: OutlineInputBorder(
        //   borderRadius: AppTheme.borderRadiusDefault,
        //   borderSide: const BorderSide(
        //     color: AppTheme.error,
        //     width: 1.5,
        //   ),
        // ),
        // focusedErrorBorder: OutlineInputBorder(
        //   borderRadius: AppTheme.borderRadiusDefault,
        //   borderSide: const BorderSide(
        //     color: AppTheme.error,
        //     width: 2,
        //   ),
        // ),
        // filled: true,
        // contentPadding: const EdgeInsets.symmetric(
        //   horizontal: 16,
        //   vertical: 16,
        // ),
      ),
    );
  }
}
