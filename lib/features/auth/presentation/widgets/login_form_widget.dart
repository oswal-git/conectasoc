// lib/features/auth/presentation/widgets/login_form.dart

import 'package:conectasoc/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import 'auth_text_field_widget.dart';

class LoginFormWidget extends StatefulWidget {
  final AuthBloc authBloc;

  const LoginFormWidget({super.key, required this.authBloc});

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState!.validate()) {
      widget.authBloc.add(
        AuthSignInRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthTextFieldWidget(
            controller: _emailController,
            label: 'Email',
            hint: 'tu@email.com',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email_outlined),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email requerido';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return 'Email inválido';
              }
              return null;
            },
          ),
          const SizedBox(height: AppTheme.spaceSm),
          AuthTextFieldWidget(
            controller: _passwordController,
            label: 'Contraseña',
            obscureText: _obscurePassword,
            prefixIcon: const Icon(Icons.lock_outlined),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Contraseña requerida';
              }
              if (value.length < 6) {
                return 'Mínimo 6 caracteres';
              }
              return null;
            },
          ),
          // const SizedBox(height: AppTheme.spaceXxs),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                _showPasswordResetDialog();
              },
              child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppTheme.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.only(bottom: 0.1), // ← separación
                  child: const Text(
                    '¿Olvidaste tu contraseña?',
                    style: AppTheme.loginSecondaryLink,
                  )),
            ),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          ElevatedButton(
            onPressed: _onLogin,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceSm),
              shape: RoundedRectangleBorder(
                borderRadius: AppTheme.borderRadiusDefault,
              ),
            ),
            child: const Text(
              'Iniciar Sesión',
              style: AppTheme.buttonLabel,
            ),
          ),
        ],
      ),
    );
  }

  void _showPasswordResetDialog() {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recuperar Contraseña'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ingresa tu email y te enviaremos un enlace para restablecer tu contraseña.',
            ),
            const SizedBox(height: AppTheme.spaceSm),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (emailController.text.isNotEmpty) {
                widget.authBloc.add(
                  AuthPasswordResetRequested(
                    emailController.text.trim(),
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }
}
