// lib/features/auth/presentation/pages/local_user_setup_page.dart

import 'package:conectasoc/app/router/router.dart';
import 'package:conectasoc/app/theme/app_theme.dart';
import 'package:conectasoc/core/widgets/widgets.dart';
import 'package:conectasoc/features/associations/domain/entities/entities.dart';
import 'package:conectasoc/features/auth/presentation/bloc/bloc.dart';
import 'package:conectasoc/features/auth/presentation/widgets/auth_text_field_widget.dart';
import 'package:conectasoc/injection_container.dart';
import 'package:conectasoc/l10n/app_localizations.dart';
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
  String _selectedLanguage = 'es';

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
              language: _selectedLanguage,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Acceso Rápido'),
          elevation: AppTheme.elevationAppBar,
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
                      backgroundColor: AppTheme.error,
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
                      backgroundColor: AppTheme.error,
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
                padding: const EdgeInsets.all(AppTheme.spaceMd),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // INFO
                      Container(
                        padding: const EdgeInsets.all(AppTheme.spaceXs),
                        decoration: BoxDecoration(
                          color: AppTheme.infoBg,
                          borderRadius: AppTheme.borderRadiusDefault,
                          border: Border.all(color: AppTheme.infoBorder),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: AppTheme.infoIcon),
                            const SizedBox(width: AppTheme.spaceXs),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Solo Lectura',
                                    style: AppTheme.infoBannerTitle,
                                  ),
                                  const SizedBox(height: AppTheme.spaceXs),
                                  Text(
                                    'Con esta opción solo podrás ver contenido. No guardaremos tu email ni datos personales.',
                                    style: AppTheme.infoBannerBody,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppTheme.spaceMd),

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

                      const SizedBox(height: AppTheme.spaceMd),

                      _buildAssociationDropdown(),

                      const SizedBox(height: AppTheme.spaceMd),

                      _buildLanguageDropdown(),

                      const SizedBox(height: AppTheme.spaceMd),

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
                              padding: const EdgeInsets.symmetric(
                                  vertical: AppTheme.spaceSm),
                              shape: RoundedRectangleBorder(
                                borderRadius: AppTheme.borderRadiusDefault,
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: AppTheme.loadingIndicatorSize,
                                    width: AppTheme.loadingIndicatorSize,
                                    child: CircularProgressIndicator(
                                      strokeWidth: AppTheme.loadingStrokeWidth,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          AppTheme.onDarkPrimary),
                                    ),
                                  )
                                : const Text(
                                    'Continuar',
                                    style: AppTheme.buttonLabel,
                                  ),
                          );
                        },
                      ),

                      const SizedBox(height: AppTheme.spaceLg),

                      // OPCIÓN REGISTRO
                      Container(
                        padding: const EdgeInsets.all(AppTheme.spaceXs),
                        decoration: BoxDecoration(
                          color: AppTheme.neutralBg,
                          borderRadius: AppTheme.borderRadiusDefault,
                        ),
                        child: Column(
                          children: [
                            Text(
                              '¿Quieres más funcionalidades?',
                              style: AppTheme.infoBannerTitle,
                            ),
                            const SizedBox(height: AppTheme.spaceXs),
                            Text(
                              'Regístrate para crear y editar contenido, recibir notificaciones y más.',
                              style: AppTheme.infoBannerBody,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppTheme.spaceXxs),
                            TextButton(
                              onPressed: () {
                                GoRouter.of(context).go(RouteNames.register);
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
                                padding: const EdgeInsets.only(
                                    bottom: 0.1), // ← separación
                                child: Text('Crear Cuenta Completa',
                                    style: AppTheme.loginSecondaryLink),
                              ),
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
            padding: const EdgeInsets.all(AppTheme.spaceSm),
            decoration: BoxDecoration(
              color: AppTheme.warningBg,
              borderRadius: AppTheme.borderRadiusDefault,
              border: Border.all(color: AppTheme.warningBorder),
            ),
            child: Text(
              'No hay asociaciones disponibles. Debes registrarte para crear una.',
              style: AppTheme.warningBannerBody,
              textAlign: TextAlign.center,
            ),
          );
        }

        return AppDropdownWidget<String>(
          label: 'Asociación *',
          hint: 'Selecciona tu asociación',
          value: _selectedAssociationId,
          prefixIcon: Icon(Icons.business_outlined),
          isExpanded: true,
          customItems: _associations.map((assoc) {
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

  Widget _buildLanguageDropdown() {
    final l10n = AppLocalizations.of(context);
    return AppDropdownWidget<String>(
      key: ValueKey(_selectedLanguage), // Force rebuild to update labels
      value: _selectedLanguage,
      label: '${l10n.language} *',
      hint: l10n.language,
      prefixIcon: const Icon(Icons.language_outlined),
      customItems: [
        DropdownMenuItem(
            value: 'es',
            child: Text(
              l10n.langSpanish,
            )),
        DropdownMenuItem(
            value: 'en',
            child: Text(
              l10n.langEnglish,
            )),
        DropdownMenuItem(
            value: 'ca',
            child: Text(
              l10n.langCatalan,
            )),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedLanguage = value);
          // Cambiar el idioma global de la app inmediatamente
          context.read<AuthBloc>().add(AuthSetLocale(value));
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return l10n.language;
        }
        return null;
      },
    );
  }
}
