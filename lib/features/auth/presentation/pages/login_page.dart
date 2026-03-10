// lib/features/auth/presentation/pages/login_page.dart

import 'package:conectasoc/app/theme/app_theme.dart';
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
                backgroundColor: AppTheme.error,
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
                    padding: const EdgeInsets.all(AppTheme.spaceMd),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // LOGO
                        Icon(
                          Icons.people_alt_outlined,
                          size: AppTheme.iconSizeApp,
                          color: AppTheme.primary,
                        ),
                        const SizedBox(height: AppTheme.spaceSm),

                        // TÍTULO
                        Text(
                          'ConectaAsoc',
                          textAlign: TextAlign.center,
                          style: AppTheme.loginTitle(context),
                        ),
                        const SizedBox(height: AppTheme.spaceXxs),

                        Text(
                          'Inicia sesión en tu cuenta',
                          textAlign: TextAlign.center,
                          style: AppTheme.loginSubtitle(context),
                        ),
                        const SizedBox(height: AppTheme.spaceTop),

                        // FORMULARIO DE LOGIN
                        LoginFormWidget(
                          authBloc: context.read<AuthBloc>(),
                        ),

                        const SizedBox(height: AppTheme.spaceSm),

                        // SEPARADOR
                        Row(
                          children: [
                            Expanded(
                                child: Divider(color: AppTheme.neutralDivider)),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.spaceSm),
                              child: Text(
                                'O',
                                style: AppTheme.loginDividerLabel,
                              ),
                            ),
                            Expanded(
                                child: Divider(color: AppTheme.neutralDivider)),
                          ],
                        ),

                        const SizedBox(height: AppTheme.spaceSm),

                        // BOTÓN REGISTRO
                        OutlinedButton(
                          onPressed: isLoading
                              ? null
                              : () => GoRouter.of(context)
                                  .push(RouteNames.register),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: AppTheme.spaceSm),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppTheme.borderRadiusDefault,
                            ),
                          ),
                          child: Text(
                            'Crear Cuenta Nueva',
                            style: AppTheme.buttonLabel,
                          ),
                        ),

                        const SizedBox(height: AppTheme.spaceXxs),

                        // BOTÓN USUARIO LOCAL
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () => GoRouter.of(context)
                                  .push(RouteNames.localUserSetup),
                          child: Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: AppTheme.primary,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            padding: const EdgeInsets.only(
                                bottom: 0.1), // ← separación
                            child: Text(
                              'Continuar sin registrarme (solo lectura)',
                              style: AppTheme.loginSecondaryLink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (isLoading)
                Container(
                  color: AppTheme.overlayDark,
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
