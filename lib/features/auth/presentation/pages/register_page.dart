// lib/features/auth/presentation/pages/register_page.dart

import 'package:conectasoc/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:conectasoc/features/auth/presentation/bloc/auth_event.dart';
import 'package:conectasoc/features/auth/presentation/bloc/auth_state.dart';
import 'package:conectasoc/features/auth/presentation/widgets/register_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: BlocProvider.of<AuthBloc>(context)..add(AuthLoadRegisterData()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Crear Cuenta'),
          elevation: 0,
        ),
        body: const RegisterView(),
      ),
    );
  }
}

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  // Guardamos los datos cargados para no perderlos en caso de error
  AuthRegisterDataLoaded? _loadedData;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(listener: (context, state) {
      // La navegación al home en caso de éxito se gestiona en main.dart
      // Aquí solo mostramos los errores.
      if (state is AuthError) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error en el Registro'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 60),
                const SizedBox(height: 16),
                Text(state.message, textAlign: TextAlign.center),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
      }
    }, child: BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // Si el estado es de datos cargados, los guardamos
        if (state is AuthRegisterDataLoaded) {
          _loadedData = state;
        }

        // Si estamos cargando y AÚN NO tenemos datos, mostramos el loader
        if (state is AuthLoading || state is AuthInitial) {
          if (_loadedData == null) {
            return const Center(child: CircularProgressIndicator());
          }
        }

        // Si tenemos datos cargados (incluso si el estado actual es otro como AuthLoading o AuthError), mostramos el formulario
        if (_loadedData != null) {
          return SafeArea(
              child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: RegisterForm(
                    associations: _loadedData!.associations,
                    isFirstUser: _loadedData!.isFirstUser,
                  ),
                ),
              ],
            ),
          ));
        }

        // Si llegamos aquí, es porque hubo un error inicial antes de poder cargar datos
        return const Center(
          child: Text('Ocurrió un error inesperado.'),
        );
      },
    ));
  }
}
