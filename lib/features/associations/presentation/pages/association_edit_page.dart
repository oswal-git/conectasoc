import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:conectasoc/core/services/image_picker_service.dart';
import 'package:conectasoc/features/associations/domain/entities/entities.dart';
import 'package:conectasoc/features/associations/presentation/bloc/bloc.dart';
import 'package:conectasoc/features/auth/presentation/bloc/bloc.dart';
import 'package:conectasoc/injection_container.dart';
import 'package:conectasoc/l10n/app_localizations.dart';
import 'package:conectasoc/services/snackbar_service.dart';

class AssociationEditPage extends StatelessWidget {
  final String associationId;

  const AssociationEditPage({super.key, required this.associationId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<AssociationEditBloc>()..add(LoadAssociationDetails(associationId)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).association),
        ),
        body: const AssociationEditView(),
      ),
    );
  }
}

class AssociationEditView extends StatefulWidget {
  const AssociationEditView({super.key});

  @override
  State<AssociationEditView> createState() => _AssociationEditViewState();
}

class _AssociationEditViewState extends State<AssociationEditView> {
  // Usamos controladores para gestionar el estado de los campos de texto.
  // Esto evita que pierdan el foco durante las reconstrucciones del BLoC.
  final _shortNameController = TextEditingController();
  final _longNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    // Es importante liberar los controladores cuando el widget se destruye.
    _shortNameController.dispose();
    _longNameController.dispose();
    _emailController.dispose();
    _contactNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _updateControllers(AssociationEntity association) {
    // Sincronizamos los controladores con los datos del estado del BLoC.
    _shortNameController.text = association.shortName;
    _longNameController.text = association.longName;
    _emailController.text = association.email ?? '';
    _contactNameController.text = association.contactName ?? '';
    _phoneController.text = association.phone ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocListener<AssociationEditBloc, AssociationEditState>(
      listener: (context, state) {
        if (state is AssociationEditSuccess) {
          _handleSuccess(context, l10n);
        } else if (state is AssociationDeleteSuccess) {
          _handleDeleteSuccess(context, l10n);
        } else if (state is AssociationEditLoaded) {
          // Mostrar error solo si el estado es Loaded y tiene un mensaje de error
          if (state.errorMessage != null) {
            _handleError(context, state.errorMessage!, l10n);
          } else {
            // Si no hay error, actualizamos los controladores.
            // Esto es clave para que los campos se actualicen al cambiar la persona de contacto.
            _updateControllers(state.association);
          }
        }
      },
      child: BlocBuilder<AssociationEditBloc, AssociationEditState>(
        builder: (context, state) {
          if (state is AssociationEditLoading ||
              state is AssociationEditInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AssociationEditLoaded) {
            return _buildForm(context, state, l10n);
          }
          if (state is AssociationEditFailure) {
            // Este es un fallo irrecuperable (ej. al cargar los datos iniciales)
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _handleError(
      BuildContext context, String errorMessage, AppLocalizations l10n) {
    String message;
    switch (errorMessage) {
      case 'shortAndLongNameRequired':
        message = l10n.shortAndLongNameRequired;
        break;
      case 'invalidEmailFormat':
        message = l10n.invalidEmailFormat;
        break;
      default:
        message = errorMessage;
    }
    SnackBarService.showSnackBar(message, isError: true);
  }

  void _handleSuccess(BuildContext context, AppLocalizations l10n) {
    SnackBarService.showSnackBar(l10n.changesSavedSuccessfully);
    // Refresca el estado de autenticación por si los roles o membresías cambiaron
    context.read<AuthBloc>().add(AuthUserRefreshRequested());
    // Vuelve a la pantalla anterior (lista de asociaciones o home)
    Navigator.of(context).pop();
  }

  void _handleDeleteSuccess(BuildContext context, AppLocalizations l10n) {
    SnackBarService.showSnackBar(l10n.associationDeletedSuccessfully);
    // Refresca el estado de autenticación por si el usuario ya no tiene membresías
    context.read<AuthBloc>().add(AuthCheckRequested());
    // Cierra la página de edición para volver a la lista
    Navigator.of(context).pop();
  }

  Widget _buildForm(BuildContext context, AssociationEditLoaded state,
      AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _LogoPicker(
            logoUrl: state.association.logoUrl,
            newImageBytes: state.newImageBytes,
            onImageSelected: (bytes) {
              context.read<AssociationEditBloc>().add(LogoChanged(bytes));
            },
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _shortNameController,
            decoration: InputDecoration(labelText: l10n.shortName),
            onChanged: (value) => context
                .read<AssociationEditBloc>()
                .add(ShortNameChanged(value)),
          ),
          const SizedBox(height: 16),
          // --- Selector de Persona de Contacto ---
          if (state.associationUsers.isNotEmpty) ...[
            DropdownButtonFormField<String>(
              // Asegurarnos de que el valor exista en la lista de items para evitar errores.
              initialValue: state.associationUsers
                      .any((u) => u.uid == state.association.contactUserId)
                  ? state.association.contactUserId
                  : null,
              decoration: InputDecoration(
                labelText: l10n.contactPerson,
                prefixIcon: const Icon(Icons.person_pin_outlined),
              ),
              items: state.associationUsers.map((user) {
                return DropdownMenuItem<String>(
                  value: user.uid,
                  child: Text(user.fullName),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  context
                      .read<AssociationEditBloc>()
                      .add(ContactPersonChanged(newValue));
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n
                      .mustSelectAnAssociation; // Reutilizamos un texto, idealmente sería uno específico.
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
          ],
          const SizedBox(height: 16),
          TextFormField(
            controller: _longNameController,
            decoration: InputDecoration(labelText: l10n.longName),
            onChanged: (value) =>
                context.read<AssociationEditBloc>().add(LongNameChanged(value)),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(labelText: l10n.email),
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) =>
                context.read<AssociationEditBloc>().add(EmailChanged(value)),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _contactNameController,
            decoration: InputDecoration(labelText: l10n.contactName),
            onChanged: (value) => context
                .read<AssociationEditBloc>()
                .add(ContactNameChanged(value)),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(labelText: l10n.phone),
            keyboardType: TextInputType.phone,
            onChanged: (value) =>
                context.read<AssociationEditBloc>().add(PhoneChanged(value)),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: state.isSaving
                ? null
                : () {
                    if (state.isCreating) {
                      context
                          .read<AssociationEditBloc>()
                          .add(CreateAssociation());
                    } else {
                      context.read<AssociationEditBloc>().add(SaveChanges());
                    }
                  },
            child: state.isSaving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(state.isCreating
                    ? l10n.createAssociation
                    : l10n.saveChanges),
          ),
          const SizedBox(height: 16),
          // Solo mostrar el botón de borrar si estamos editando (no creando)
          if (!state.isCreating)
            TextButton.icon(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              label: Text(
                l10n.deleteAssociation,
                style: const TextStyle(color: Colors.red),
              ),
              onPressed: state.isSaving
                  ? null
                  : () => _showDeleteConfirmation(
                      context, state.association.shortName, l10n),
            ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, String associationName, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteAssociation),
        content: Text(l10n.deleteAssociationConfirmation(associationName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(); // Cierra el diálogo
              context
                  .read<AssociationEditBloc>()
                  .add(DeleteCurrentAssociation());
            },
            child: Text(
              l10n.delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoPicker extends StatelessWidget {
  final String? logoUrl;
  final Uint8List? newImageBytes;
  final Function(Uint8List) onImageSelected;

  const _LogoPicker({
    this.logoUrl,
    this.newImageBytes,
    required this.onImageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final imagePickerService = ImagePickerService();

    ImageProvider? backgroundImage;
    if (newImageBytes != null) {
      backgroundImage = MemoryImage(newImageBytes!);
    } else if (logoUrl != null && logoUrl!.isNotEmpty) {
      backgroundImage = CachedNetworkImageProvider(logoUrl!);
    }

    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey[200],
            backgroundImage: backgroundImage,
            child: backgroundImage == null
                ? Icon(Icons.business, size: 60, color: Colors.grey[400])
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () async {
                final imageBytes = await imagePickerService.pickImage(context);
                if (imageBytes != null) {
                  onImageSelected(imageBytes);
                }
              },
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Theme.of(context).primaryColor,
                child: const Icon(Icons.edit, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
