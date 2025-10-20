// lib/features/auth/presentation/pages/login_page.dart

import 'package:conectasoc/features/auth/presentation/widgets/widgets.dart';
import 'package:conectasoc/app/router/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:conectasoc/features/auth/presentation/bloc/bloc.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
        }
        // La navegación se maneja globalmente en main.dart
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          body: Stack(
            children: [
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // LOGO
                        Icon(
                          Icons.people_alt_outlined,
                          size: 80,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(height: 16),

                        // TÍTULO
                        Text(
                          'ConectaAsoc',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                        ),
                        const SizedBox(height: 8),

                        Text(
                          'Inicia sesión en tu cuenta',
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                        ),
                        const SizedBox(height: 40),

                        // FORMULARIO DE LOGIN
                        const LoginFormWidget(),

                        const SizedBox(height: 24),

                        // SEPARADOR
                        Row(
                          children: [
                            Expanded(
                                child: Divider(color: Colors.grey.shade300)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'O',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ),
                            Expanded(
                                child: Divider(color: Colors.grey.shade300)),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // BOTÓN REGISTRO
                        OutlinedButton(
                          onPressed: isLoading
                              ? null
                              : () => GoRouter.of(context)
                                  .push(RouteNames.register),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Crear Cuenta Nueva',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // BOTÓN USUARIO LOCAL
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () => GoRouter.of(context)
                                  .push(RouteNames.localUserSetup),
                          child: const Text(
                            'Continuar sin registrarme (solo lectura)',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (isLoading)
                Container(
                  color: Colors.black.withValues(alpha: 0.5),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
