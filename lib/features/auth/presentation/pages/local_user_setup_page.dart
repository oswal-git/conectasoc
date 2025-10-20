// lib/features/auth/presentation/pages/local_user_setup_page.dart

import 'package:conectasoc/app/router/router.dart';
import 'package:conectasoc/features/associations/domain/entities/entities.dart';
import 'package:conectasoc/features/auth/presentation/bloc/bloc.dart';
import 'package:conectasoc/features/auth/presentation/widgets/auth_text_field_widget.dart';
import 'package:conectasoc/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LocalUserSetupPage extends StatelessWidget {
  const LocalUserSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<LocalUserSetupBloc>()..add(LoadAssociations()),
      child: const LocalUserSetupView(),
    );
  }
}

class LocalUserSetupView extends StatefulWidget {
  const LocalUserSetupView({super.key});

  @override
  State<LocalUserSetupView> createState() => _LocalUserSetupViewState();
}

class _LocalUserSetupViewState extends State<LocalUserSetupView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _selectedAssociationId;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onSave(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthSaveLocalUser(
              displayName: _nameController.text.trim(),
              associationId: _selectedAssociationId!,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Acceso Rápido'),
          elevation: 0,
        ),
        body: MultiBlocListener(
          listeners: [
            BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                // The go_router redirect will handle navigation on AuthLocalUser.
                if (state is AuthError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
            BlocListener<LocalUserSetupBloc, LocalUserSetupState>(
              listener: (context, state) {
                if (state is LocalUserSetupError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
          child: SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // INFO
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: Colors.blue.shade700),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Solo Lectura',
                                    style: TextStyle(
                                      color: Colors.blue.shade900,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Con esta opción solo podrás ver contenido. No guardaremos tu email ni datos personales.',
                                    style: TextStyle(
                                      color: Colors.blue.shade800,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // NOMBRE
                      AuthTextFieldWidget(
                        controller: _nameController,
                        label: 'Tu Nombre *',
                        hint: 'Cómo quieres que te llamemos',
                        prefixIcon: const Icon(Icons.person_outline),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El nombre es requerido';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      _buildAssociationDropdown(),

                      const SizedBox(height: 32),

                      // BOTÓN CONTINUAR
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final isLoading =
                              state is AuthLoading; // From AuthBloc

                          return ElevatedButton(
                            onPressed: isLoading || _associations.isEmpty
                                ? null
                                : () => _onSave(context),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Continuar',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // OPCIÓN REGISTRO
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '¿Quieres más funcionalidades?',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Regístrate para crear y editar contenido, recibir notificaciones y más.',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () {
                                GoRouter.of(context).go(RouteNames.register);
                              },
                              child: const Text('Crear Cuenta Completa'),
                            ),
                          ],
                        ),
                      ),
                    ]),
              ),
            ),
          ),
        ));
  }

  // Extracted for clarity
  List<AssociationEntity> _associations = [];

  Widget _buildAssociationDropdown() {
    return BlocBuilder<LocalUserSetupBloc, LocalUserSetupState>(
      builder: (context, state) {
        if (state is LocalUserSetupLoading || state is LocalUserSetupInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is LocalUserSetupLoaded) {
          _associations = state.associations;
        }

        if (_associations.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: const Text(
              'No hay asociaciones disponibles. Debes registrarte para crear una.',
              style: TextStyle(color: Colors.orange),
              textAlign: TextAlign.center,
            ),
          );
        }

        return DropdownButtonFormField<String>(
          isExpanded: true,
          itemHeight: null, // Allow items to have variable height
          initialValue: _selectedAssociationId,
          decoration: const InputDecoration(
            labelText: 'Asociación *',
            hintText: 'Selecciona tu asociación',
            prefixIcon: Icon(Icons.business_outlined),
          ),
          items: _associations.map((assoc) {
            final displayText = assoc.shortName != assoc.longName
                ? '${assoc.shortName} (${assoc.longName})'
                : assoc.shortName;
            return DropdownMenuItem(
              value: assoc.id,
              child: Text(
                displayText,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedAssociationId = value);
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Selecciona una asociación';
            }
            return null;
          },
        );
      },
    );
  }
}
