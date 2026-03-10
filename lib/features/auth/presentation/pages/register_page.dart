// lib/features/auth/presentation/pages/register_page.dart

// ignore_for_file: avoid_debugPrint

import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/material.dart';
import 'package:conectasoc/app/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:conectasoc/features/auth/presentation/bloc/bloc.dart';
import 'package:conectasoc/features/auth/presentation/widgets/register_form_widget.dart';
import 'package:conectasoc/l10n/app_localizations.dart';
import 'package:conectasoc/services/snackbar_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Variable para mantener el estado de los datos cargados
  // y evitar que desaparezca el formulario durante errores
  RegisterDataLoaded? _cachedRegisterData;

  @override
  void initState() {
    super.initState();
    // Cargar datos iniciales del registro usando el Bloc global
    context.read<AuthBloc>().add(AuthLoadRegisterData());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createAccount),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          debugPrint('🧪 TEST: Iniciando prueba directa de Firebase');

          try {
            final auth = firebase.FirebaseAuth.instance;
            debugPrint('🧪 TEST: FirebaseAuth instance obtenida');

            final testEmail =
                'test${DateTime.now().millisecondsSinceEpoch}@test.com';
            final testPassword = 'test123456';

            debugPrint('🧪 TEST: Intentando crear usuario: $testEmail');

            final credential = await auth
                .createUserWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            )
                .timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                debugPrint('🧪 TEST: TIMEOUT!');
                throw Exception('Timeout');
              },
            );

            debugPrint(
                '🧪 TEST: ✅ Usuario creado! UID: ${credential.user?.uid}');

            // Limpiar
            await credential.user?.delete();
            debugPrint('🧪 TEST: ✅ Usuario eliminado');

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Test exitoso!')),
              );
            }
          } catch (e, stack) {
            debugPrint('🧪 TEST: ❌ Error: $e');
            debugPrint('🧪 TEST: Stack: $stack');

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Test falló: $e')),
              );
            }
          }
        },
        child: const Icon(Icons.science),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            SnackBarService.showSnackBar(state.message, isError: true);

            // CRÍTICO: Si tenemos datos cacheados del formulario,
            // NO recargamos AuthLoadRegisterData automáticamente
            // porque eso borraría los datos del usuario en el formulario.
            // Solo recargamos si NO hay cache (primera vez)
            if (_cachedRegisterData == null) {
              context.read<AuthBloc>().add(AuthLoadRegisterData());
            }
          } else if (state is AuthNeedsVerification) {
            // Opcional: Mostrar mensaje de éxito si el registro fue exitoso
            SnackBarService.showSnackBar(
              l10n.registrationSuccessMessage,
              isError: false,
            );
            // Navegar de vuelta al login o a una página de verificación
            Navigator.of(context).pop();
          }
        },
        // Usamos un BlocBuilder que solo reconstruya la UI cuando sea estrictamente necesario.
        // buildWhen asegura que el formulario no se destruya cuando llega un AuthError.
        builder: (context, state) {
          // Cachear los datos cuando se cargan exitosamente
          if (state is RegisterDataLoaded) {
            _cachedRegisterData = state;
          }

          // Mostrar indicador de carga solo en la carga inicial
          if (state is RegisterLoading && _cachedRegisterData == null) {
            return const Center(child: CircularProgressIndicator());
          }

          // Durante el proceso de registro, mostrar un overlay de carga
          // SOBRE el formulario para que el usuario vea que algo está pasando
          // pero sin destruir el formulario
          final isProcessing = state is AuthLoading;

          // Si tenemos datos (cacheados o actuales), mostrar el formulario
          if (_cachedRegisterData != null) {
            return Stack(
              children: [
                // Formulario
                Padding(
                  padding: const EdgeInsets.all(AppTheme.spaceSm),
                  child: RegisterFormWidget(
                    authBloc: context
                        .read<AuthBloc>(), // Pasa la instancia del AuthBloc
                    associations: _cachedRegisterData!.associations,
                    isFirstUser: _cachedRegisterData!.isFirstUser,
                  ),
                ),

                // Overlay de carga durante el procesamiento
                if (isProcessing)
                  Container(
                    color: AppTheme.overlayLoading,
                    child: const Center(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(AppTheme.spaceMd),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: AppTheme.spaceSm),
                              Text('Registrando usuario...'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }
          // Estado inicial o inesperado
          return const SizedBox.shrink(); // Estado inicial o inesperado
        },
      ),
    );
  }
}
