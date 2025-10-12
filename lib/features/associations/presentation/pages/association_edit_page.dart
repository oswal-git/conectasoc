import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:conectasoc/core/services/image_picker_service.dart';
import 'package:conectasoc/features/associations/presentation/bloc/bloc.dart';
import 'package:conectasoc/features/auth/presentation/bloc/bloc.dart';
import 'package:conectasoc/injection_container.dart';
import 'package:conectasoc/l10n/app_localizations.dart';
import 'package:conectasoc/services/snackbar_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
          title: Text(AppLocalizations.of(context)!.association),
        ),
        body: const AssociationEditView(),
      ),
    );
  }
}

class AssociationEditView extends StatelessWidget {
  const AssociationEditView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocListener<AssociationEditBloc, AssociationEditState>(
      listenWhen: (previous, current) {
        // Escuchar solo cuando una operación de guardado termina (con éxito o no)
        // o cuando aparece un nuevo mensaje de error.
        final wasSaving =
            previous is AssociationEditLoaded && previous.isSaving;
        final justFinishedSaving =
            current is AssociationEditLoaded && !current.isSaving;
        final hasNewError = current is AssociationEditLoaded &&
            current.errorMessage != null &&
            (previous is! AssociationEditLoaded ||
                previous.errorMessage != current.errorMessage);
        return (wasSaving && justFinishedSaving) || hasNewError;
      },
      listener: (context, state) {
        if (state is AssociationEditLoaded) {
          // Caso 1: Hay un error que mostrar
          if (state.errorMessage != null) {
            _handleError(context, state.errorMessage!, l10n);
          }
          // Caso 2: Se acaba de terminar de guardar (crear o actualizar)
          else if (!state.isSaving) {
            _handleSuccess(context, l10n);
          }
        } else if (state is AssociationDeleteSuccess) {
          // Caso 3: Se ha borrado con éxito
          _handleDeleteSuccess(context, l10n);
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
    context.read<AuthBloc>().add(AuthCheckRequested());
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
            newImagePath: state.newImagePath,
            onImageSelected: (path) {
              context.read<AssociationEditBloc>().add(LogoChanged(path));
            },
          ),
          const SizedBox(height: 24),
          TextFormField(
            initialValue: state.association.shortName,
            decoration: InputDecoration(labelText: l10n.shortName),
            onChanged: (value) => context
                .read<AssociationEditBloc>()
                .add(ShortNameChanged(value)),
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: state.association.longName,
            decoration: InputDecoration(labelText: l10n.longName),
            onChanged: (value) =>
                context.read<AssociationEditBloc>().add(LongNameChanged(value)),
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: state.association.email,
            decoration: InputDecoration(labelText: l10n.email),
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) =>
                context.read<AssociationEditBloc>().add(EmailChanged(value)),
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: state.association.contactName,
            decoration: InputDecoration(labelText: l10n.contactName),
            onChanged: (value) => context
                .read<AssociationEditBloc>()
                .add(ContactNameChanged(value)),
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: state.association.phone,
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
  final String? newImagePath;
  final Function(String) onImageSelected;

  const _LogoPicker({
    this.logoUrl,
    this.newImagePath,
    required this.onImageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final imagePickerService = ImagePickerService();

    ImageProvider? backgroundImage;
    if (newImagePath != null) {
      backgroundImage = FileImage(File(newImagePath!));
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
                final path = await imagePickerService.pickImage(context);
                if (path != null) {
                  onImageSelected(path);
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
