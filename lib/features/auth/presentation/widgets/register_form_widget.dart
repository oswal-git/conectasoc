// lib/features/auth/presentation/widgets/register_form.dart

import 'package:conectasoc/features/associations/domain/entities/association_entity.dart';
import 'package:conectasoc/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:conectasoc/features/auth/presentation/bloc/auth_event.dart';
import 'package:conectasoc/features/auth/presentation/widgets/auth_text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:conectasoc/l10n/app_localizations.dart';

class RegisterFormWidget extends StatefulWidget {
  final List<AssociationEntity> associations;
  final bool isFirstUser;

  final AuthBloc authBloc; // Acepta la instancia del AuthBloc

  const RegisterFormWidget({
    super.key,
    required this.associations,
    this.isFirstUser = false,
    required this.authBloc, // Requiere la instancia del AuthBloc
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
      widget.authBloc.add(
        // Usa la instancia del AuthBloc que se le pasó
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
    final l10n = AppLocalizations.of(context);
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // DATOS PERSONALES
            Text(
              l10n.personalData,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            AuthTextFieldWidget(
              controller: _firstNameController,
              label: '${l10n.name} *',
              prefixIcon: const Icon(Icons.person_outline),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.requiredField;
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            AuthTextFieldWidget(
              controller: _lastNameController,
              label: '${l10n.lastname} *',
              prefixIcon: const Icon(Icons.person_outline),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.requiredField;
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            AuthTextFieldWidget(
              controller: _emailController,
              label: '${l10n.email} *',
              hint: l10n.emailHint,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.email_outlined),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.requiredField;
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value)) {
                  return l10n.invalidEmailFormat;
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            AuthTextFieldWidget(
              controller: _phoneController,
              label: l10n.phone,
              keyboardType: TextInputType.phone,
              prefixIcon: const Icon(Icons.phone_outlined),
            ),
            const SizedBox(height: 24),

            // CONTRASEÑA
            Text(
              l10n.password,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            AuthTextFieldWidget(
              controller: _passwordController,
              label: '${l10n.password} *',
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
                  return l10n.requiredField;
                }
                if (value.length < 6) {
                  return l10n.passwordMinLength;
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            AuthTextFieldWidget(
              controller: _confirmPasswordController,
              label: l10n.confirmPassword,
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
                  return l10n.requiredField;
                }
                if (value != _passwordController.text) {
                  return l10n.passwordsDoNotMatch;
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // ASOCIACIÓN
            Text(
              l10n.association,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            if (!widget.isFirstUser) ...[
              CheckboxListTile(
                title: Text(l10n.createNewAssociation),
                subtitle: Text(l10n.youWillBeAdmin),
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
                          ? l10n.createGeneralAssociation
                          : l10n.newAssociationData,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    AuthTextFieldWidget(
                      controller: _newAssocShortNameController,
                      label: '${l10n.shortName} *',
                      hint: l10n.shortNameHint,
                      validator: (value) {
                        if (_createNewAssociation &&
                            (value == null || value.isEmpty)) {
                          return l10n.requiredField;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    AuthTextFieldWidget(
                      controller: _newAssocLongNameController,
                      label: '${l10n.longName} *',
                      hint: l10n.longNameHint,
                      validator: (value) {
                        if (_createNewAssociation &&
                            (value == null || value.isEmpty)) {
                          return l10n.requiredField;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    AuthTextFieldWidget(
                      controller: _newAssocEmailController,
                      label: l10n.contactEmail,
                      keyboardType: TextInputType.emailAddress,
                      hint: l10n.optionalUseYourEmail,
                    ),
                    const SizedBox(height: 12),
                    AuthTextFieldWidget(
                      controller: _newAssocContactController,
                      label: l10n.contactPerson,
                      hint: l10n.optionalUseYourName,
                    ),
                    const SizedBox(height: 12),
                    AuthTextFieldWidget(
                      controller: _newAssocPhoneController,
                      label: l10n.contactPhone,
                      keyboardType: TextInputType.phone,
                      hint: l10n.optionalUseYourPhone,
                      validator: (value) {
                        if (_createNewAssociation &&
                            _phoneController.text.trim().isEmpty &&
                            (value == null || value.trim().isEmpty)) {
                          return 'Teléfono de contacto requerido si no proporcionas el tuyo';
                        }
                        return null;
                      },
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
                  child: Text(
                    l10n.noAssociationsAvailableToJoin,
                    style: TextStyle(color: Colors.orange),
                  ),
                )
              else
                DropdownButtonFormField<String>(
                  initialValue: _selectedAssociationId,
                  decoration: InputDecoration(
                    labelText: '${l10n.selectAssociation} *',
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
                      return l10n.mustSelectAnAssociation;
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
              child: Text(
                l10n.register,
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
