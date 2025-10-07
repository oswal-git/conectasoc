// lib/features/auth/presentation/widgets/register_form.dart

import 'package:conectasoc/features/associations/domain/entities/association_entity.dart';
import 'package:conectasoc/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:conectasoc/features/auth/presentation/bloc/auth_event.dart';
import 'package:conectasoc/features/auth/presentation/widgets/auth_text_field_widget.dart';
import 'package:conectasoc/injection_container.dart';
import 'package:flutter/material.dart';

class RegisterFormWidget extends StatefulWidget {
  final List<AssociationEntity> associations;
  final bool isFirstUser;

  const RegisterFormWidget({
    super.key,
    required this.associations,
    this.isFirstUser = false,
  });

  @override
  State<RegisterFormWidget> createState() => _RegisterFormWidgetState();
}

class _RegisterFormWidgetState extends State<RegisterFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  // Para nueva asociación
  final _newAssocShortNameController = TextEditingController();
  final _newAssocLongNameController = TextEditingController();
  final _newAssocEmailController = TextEditingController();
  final _newAssocContactController = TextEditingController();
  final _newAssocPhoneController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _createNewAssociation = false;
  String? _selectedAssociationId;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _newAssocShortNameController.dispose();
    _newAssocLongNameController.dispose();
    _newAssocEmailController.dispose();
    _newAssocContactController.dispose();
    _newAssocPhoneController.dispose();
    super.dispose();
  }

  void _onRegister() {
    if (_formKey.currentState!.validate()) {
      sl<AuthBloc>().add(
        AuthRegisterRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          createAssociation: _createNewAssociation,
          associationId: _selectedAssociationId,
          newAssociationName: _createNewAssociation
              ? _newAssocShortNameController.text.trim()
              : null,
          newAssociationLongName: _createNewAssociation
              ? _newAssocLongNameController.text.trim()
              : null,
          newAssociationEmail:
              _createNewAssociation && _newAssocEmailController.text.isNotEmpty
                  ? _newAssocEmailController.text.trim()
                  : null,
          newAssociationContactName: _createNewAssociation &&
                  _newAssocContactController.text.isNotEmpty
              ? _newAssocContactController.text.trim()
              : null,
          newAssociationPhone:
              _createNewAssociation && _newAssocPhoneController.text.isNotEmpty
                  ? _newAssocPhoneController.text.trim()
                  : null,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // DATOS PERSONALES
            Text(
              'Datos Personales',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            AuthTextFieldWidget(
              controller: _firstNameController,
              label: 'Nombre *',
              prefixIcon: const Icon(Icons.person_outline),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nombre requerido';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            AuthTextFieldWidget(
              controller: _lastNameController,
              label: 'Apellidos *',
              prefixIcon: const Icon(Icons.person_outline),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Apellidos requeridos';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            AuthTextFieldWidget(
              controller: _emailController,
              label: 'Email *',
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
            const SizedBox(height: 12),

            AuthTextFieldWidget(
              controller: _phoneController,
              label: 'Teléfono',
              keyboardType: TextInputType.phone,
              prefixIcon: const Icon(Icons.phone_outlined),
            ),
            const SizedBox(height: 24),

            // CONTRASEÑA
            Text(
              'Contraseña',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            AuthTextFieldWidget(
              controller: _passwordController,
              label: 'Contraseña *',
              obscureText: _obscurePassword,
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
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
            const SizedBox(height: 12),

            AuthTextFieldWidget(
              controller: _confirmPasswordController,
              label: 'Confirmar Contraseña *',
              obscureText: _obscureConfirmPassword,
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () {
                  setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword);
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Confirme su contraseña';
                }
                if (value != _passwordController.text) {
                  return 'Las contraseñas no coinciden';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // ASOCIACIÓN
            Text(
              'Asociación',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            if (!widget.isFirstUser) ...[
              CheckboxListTile(
                title: const Text('Crear nueva asociación'),
                subtitle: const Text('Serás administrador de la asociación'),
                value: _createNewAssociation,
                onChanged: (value) {
                  setState(() {
                    _createNewAssociation = value ?? false;
                    if (_createNewAssociation) {
                      _selectedAssociationId = null;
                    }
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 12),
            ],

            if (_createNewAssociation) ...[
              // FORMULARIO NUEVA ASOCIACIÓN
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isFirstUser
                          ? 'Crear Asociación General (SuperAdmin)'
                          : 'Datos de la Nueva Asociación',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    AuthTextFieldWidget(
                      controller: _newAssocShortNameController,
                      label: 'Nombre Corto *',
                      hint: 'Ej: ASOC2024',
                      validator: (value) {
                        if (_createNewAssociation &&
                            (value == null || value.isEmpty)) {
                          return 'Nombre corto requerido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    AuthTextFieldWidget(
                      controller: _newAssocLongNameController,
                      label: 'Nombre Completo *',
                      hint: 'Ej: Asociación de Vecinos 2024',
                      validator: (value) {
                        if (_createNewAssociation &&
                            (value == null || value.isEmpty)) {
                          return 'Nombre completo requerido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    AuthTextFieldWidget(
                      controller: _newAssocEmailController,
                      label: 'Email de Contacto',
                      keyboardType: TextInputType.emailAddress,
                      hint: 'Opcional (se usará tu email)',
                    ),
                    const SizedBox(height: 12),
                    AuthTextFieldWidget(
                      controller: _newAssocContactController,
                      label: 'Persona de Contacto',
                      hint: 'Opcional (se usará tu nombre)',
                    ),
                    const SizedBox(height: 12),
                    AuthTextFieldWidget(
                      controller: _newAssocPhoneController,
                      label: 'Teléfono de Contacto',
                      keyboardType: TextInputType.phone,
                      hint: 'Opcional (se usará tu teléfono)',
                    ),
                  ],
                ),
              ),
            ] else ...[
              // SELECTOR DE ASOCIACIÓN EXISTENTE
              if (widget.associations.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: const Text(
                    'No hay asociaciones disponibles. Debes crear una nueva.',
                    style: TextStyle(color: Colors.orange),
                  ),
                )
              else
                DropdownButtonFormField<String>(
                  initialValue: _selectedAssociationId,
                  decoration: InputDecoration(
                    labelText: 'Selecciona una Asociación *',
                    prefixIcon: const Icon(Icons.business_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: widget.associations.map((assoc) {
                    return DropdownMenuItem(
                      value: assoc.id,
                      child: Text(assoc.shortName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedAssociationId = value);
                  },
                  validator: (value) {
                    if (!_createNewAssociation &&
                        (value == null || value.isEmpty)) {
                      return 'Selecciona una asociación';
                    }
                    return null;
                  },
                ),
            ],

            const SizedBox(height: 32),

            // BOTÓN REGISTRAR
            ElevatedButton(
              onPressed: _onRegister,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Registrarse',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
