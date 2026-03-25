import 'package:conectasoc/app/theme/app_theme.dart';
import 'package:conectasoc/core/widgets/widgets.dart';
import 'package:conectasoc/features/auth/presentation/bloc/bloc.dart';
import 'package:conectasoc/features/documents/domain/entities/entities.dart';
import 'package:conectasoc/features/documents/presentation/bloc/bloc.dart';
import 'package:conectasoc/injection_container.dart';
import 'package:conectasoc/l10n/app_localizations.dart';
import 'package:conectasoc/services/snackbar_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class DocumentEditPage extends StatelessWidget {
  final DocumentEntity document;

  const DocumentEditPage({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;

    if (authState is! AuthAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar documento')),
        body: const Center(child: Text('Debe iniciar sesión')),
      );
    }

    final user = authState.user;
    final membership = authState.currentMembership;
    final associationId =
        user.isSuperAdmin ? 'Todas' : (membership?.associationId ?? '');

    return BlocProvider(
      create: (context) => sl<DocumentEditBloc>()
        ..add(LoadDocumentForEdit(
          document: document,
          associationId: associationId,
        )),
      child: const DocumentEditView(),
    );
  }
}

class DocumentEditView extends StatefulWidget {
  const DocumentEditView({super.key});

  @override
  State<DocumentEditView> createState() => _DocumentEditViewState();
}

class _DocumentEditViewState extends State<DocumentEditView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop(DocumentEditReady state) async {
    if (!state.hasChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descartar cambios'),
        content: const Text(
            'Tienes cambios sin guardar. ¿Estás seguro de que quieres salir?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<DocumentEditBloc, DocumentEditState>(
      listener: (context, state) {
        if (state is DocumentEditReady && _descriptionController.text.isEmpty) {
          _descriptionController.text = state.description;
        }
        if (state is DocumentEditSuccess) {
          SnackBarService.showSnackBar('Documento actualizado correctamente');
          context.pop(true);
        } else if (state is DocumentEditFailure) {
          SnackBarService.showSnackBar(state.message, isError: true);
        }
      },
      builder: (context, state) {
        if (state is DocumentEditReady) {
          return PopScope(
            canPop: !state.hasChanges,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) return;
              final shouldPop = await _onWillPop(state);
              if (shouldPop && mounted && context.mounted) {
                context.pop();
              }
            },
            child: Scaffold(
              appBar: AppBar(
                title: Text(l10n.edit),
                actions: [
                  if (state.hasChanges)
                    IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: () => context
                          .read<DocumentEditBloc>()
                          .add(const SubmitDocumentEdit()),
                    ),
                ],
              ),
              body: SingleChildScrollView(
                padding: AppTheme.paddingPage,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Document Info Header (Read-only)
                      _buildInfoHeader(state),
                      AppTheme.sizedBoxHeightWidget,

                      // Description
                      _buildDescriptionField(state, l10n),
                      AppTheme.sizedBoxHeightWidget,

                      // Category
                      _buildCategorySelector(state, l10n),
                      AppTheme.sizedBoxHeightSeparatorSsm,

                      // Subcategory
                      _buildSubcategorySelector(state, l10n),
                      AppTheme.sizedBoxHeightWidget,

                      // Download Permission
                      _buildDownloadPermissionSwitch(state, l10n),
                      AppTheme.sizedBoxHeightWidgetXl,

                      // Submit Button
                      ElevatedButton(
                        onPressed: state.hasChanges
                            ? () => context
                                .read<DocumentEditBloc>()
                                .add(const SubmitDocumentEdit())
                            : null,
                        child: const Text('Guardar cambios'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text(l10n.edit)),
          body: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildInfoHeader(DocumentEditReady state) {
    return Card(
      child: Padding(
        padding: AppTheme.paddingContainer,
        child: Row(
          children: [
            const Icon(Icons.description, color: AppTheme.primary, size: 40),
            AppTheme.sizedBoxWidthSeparator,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.originalDocument.fileName,
                    style: AppTheme.documentFileName(context),
                  ),
                  Text(
                    '${state.originalDocument.fileExtension.toUpperCase()} · ${state.originalDocument.formattedFileSize}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionField(
      DocumentEditReady state, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.documentDescription,
            style: Theme.of(context).textTheme.labelMedium),
        AppTheme.sizedBoxHeightSeparatorXs,
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Introduce una descripción...',
          ),
          onChanged: (value) => context
              .read<DocumentEditBloc>()
              .add(EditDescriptionChanged(value)),
        ),
      ],
    );
  }

  Widget _buildCategorySelector(
      DocumentEditReady state, AppLocalizations l10n) {
    return AppDropdownWidget<String>(
      label: l10n.category,
      value: state.categoryId.isEmpty ? null : state.categoryId,
      items: [
        AppDropdownItem(value: null, label: 'Seleccionar categoría'),
        ...state.categories
            .map((c) => AppDropdownItem(value: c.id, label: c.name)),
      ],
      onChanged: (value) {
        if (value != null) {
          context.read<DocumentEditBloc>().add(EditCategoryChanged(value));
        }
      },
    );
  }

  Widget _buildSubcategorySelector(
      DocumentEditReady state, AppLocalizations l10n) {
    return AppDropdownWidget<String>(
      label: l10n.subcategory,
      value: state.subcategoryId.isEmpty ? null : state.subcategoryId,
      enabled: state.categoryId.isNotEmpty,
      items: [
        AppDropdownItem(value: null, label: 'Seleccionar subcategoría'),
        ...state.subcategories
            .map((s) => AppDropdownItem(value: s.id, label: s.name)),
      ],
      onChanged: (value) {
        if (value != null) {
          context.read<DocumentEditBloc>().add(EditSubcategoryChanged(value));
        }
      },
    );
  }

  Widget _buildDownloadPermissionSwitch(
      DocumentEditReady state, AppLocalizations l10n) {
    return SwitchListTile(
      title: const Text('Permitir descarga'),
      subtitle:
          const Text('Los usuarios podrán descargar o compartir el archivo'),
      value: state.canDownload,
      activeThumbColor: AppTheme.primary,
      onChanged: (value) => context
          .read<DocumentEditBloc>()
          .add(EditDownloadPermissionChanged(value)),
    );
  }
}
