import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:conectasoc/features/auth/presentation/bloc/bloc.dart';
import 'package:conectasoc/features/documents/presentation/bloc/upload/document_upload_bloc.dart';
import 'package:conectasoc/features/documents/presentation/bloc/upload/document_upload_event_bloc.dart';
import 'package:conectasoc/features/documents/presentation/bloc/upload/document_upload_state_bloc.dart';
import 'package:conectasoc/injection_container.dart';
import 'package:conectasoc/l10n/app_localizations.dart';
import 'package:conectasoc/services/snackbar_service.dart';

class DocumentUploadPage extends StatelessWidget {
  const DocumentUploadPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;

    if (authState is! AuthAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Subir documento')),
        body: const Center(child: Text('Debe iniciar sesión')),
      );
    }

    final user = authState.user;
    final membership = authState.currentMembership;
    final associationId =
        user.isSuperAdmin ? 'Todas' : (membership?.associationId ?? '');

    return BlocProvider(
      create: (context) => sl<DocumentUploadBloc>()
        ..add(InitializeUpload(
          associationId: associationId,
          categoryId: '',
          subcategoryId: '',
          userId: user.uid,
        )),
      child: const DocumentUploadView(),
    );
  }
}

class DocumentUploadView extends StatefulWidget {
  const DocumentUploadView({super.key});

  @override
  State<DocumentUploadView> createState() => _DocumentUploadViewState();
}

class _DocumentUploadViewState extends State<DocumentUploadView> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx'],
        withData: true, // Important for web
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          if (!mounted) return;
          context.read<DocumentUploadBloc>().add(
                FileSelected(
                  fileBytes: file.bytes!,
                  fileName: file.name,
                ),
              );
        }
      }
    } catch (e) {
      SnackBarService.showSnackBar('Error al seleccionar archivo: $e',
          isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.uploadDocuments),
      ),
      body: BlocConsumer<DocumentUploadBloc, DocumentUploadState>(
        listener: (context, state) {
          if (state is DocumentUploadSuccess) {
            SnackBarService.showSnackBar(l10n.documentUploaded);
            Navigator.of(context).pop(state.document);
          } else if (state is DocumentUploadFailure) {
            SnackBarService.showSnackBar(state.error, isError: true);
          }
        },
        builder: (context, state) {
          if (state is DocumentUploadInitial ||
              state is DocumentUploadInProgress) {
            return _buildProgressIndicator(state);
          }

          if (state is DocumentUploadReady) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // File picker section
                    _buildFilePickerSection(context, state, l10n),
                    const SizedBox(height: 24),

                    // Description field
                    _buildDescriptionField(context, state, l10n),
                    const SizedBox(height: 24),

                    // Category selector
                    _buildCategorySelector(context, state, l10n),
                    const SizedBox(height: 16),

                    // Subcategory selector
                    _buildSubcategorySelector(context, state, l10n),
                    const SizedBox(height: 24),

                    // Download permission toggle
                    _buildDownloadPermissionToggle(context, state, l10n),
                    const SizedBox(height: 32),

                    // Upload button
                    _buildUploadButton(context, state, l10n),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildProgressIndicator(DocumentUploadState state) {
    final progress = state is DocumentUploadInProgress ? state.progress : null;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (progress != null) ...[
              LinearProgressIndicator(value: progress),
              const SizedBox(height: 16),
              Text(
                progress < 0.4
                    ? 'Subiendo documento...'
                    : progress < 0.8
                        ? 'Generando miniatura...'
                        : 'Guardando...',
              ),
            ] else
              const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePickerSection(
    BuildContext context,
    DocumentUploadReady state,
    AppLocalizations l10n,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.attach_file, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.selectDocument,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (state.selectedFileName == null)
              OutlinedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.folder_open),
                label: Text(l10n.selectDocument),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.selectedFileName!,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${state.fileSizeMB?.toStringAsFixed(2)} MB',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _pickFile,
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Cambiar archivo',
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
    BuildContext context,
    DocumentUploadReady state,
    AppLocalizations l10n,
  ) {
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: l10n.documentDescription,
        hintText: l10n.documentDescriptionHint,
        prefixIcon: const Icon(Icons.description),
        counterText: '${state.description.length}/200',
        border: const OutlineInputBorder(),
      ),
      maxLength: 200,
      maxLines: 3,
      onChanged: (value) {
        context.read<DocumentUploadBloc>().add(DescriptionChanged(value));
      },
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'La descripción es requerida';
        }
        return null;
      },
    );
  }

  Widget _buildCategorySelector(
    BuildContext context,
    DocumentUploadReady state,
    AppLocalizations l10n,
  ) {
    return DropdownButtonFormField<String>(
      initialValue: state.categoryId.isEmpty ? null : state.categoryId,
      decoration: InputDecoration(
        labelText: l10n.category,
        prefixIcon: const Icon(Icons.category),
        border: const OutlineInputBorder(),
      ),
      items: state.categories.map((category) {
        return DropdownMenuItem(
          value: category.id,
          child: Text(category.name),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          context.read<DocumentUploadBloc>().add(CategoryChanged(value));
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Seleccione una categoría';
        }
        return null;
      },
    );
  }

  Widget _buildSubcategorySelector(
    BuildContext context,
    DocumentUploadReady state,
    AppLocalizations l10n,
  ) {
    return DropdownButtonFormField<String>(
      initialValue: state.subcategoryId.isEmpty ? null : state.subcategoryId,
      decoration: InputDecoration(
        labelText: l10n.subcategory,
        prefixIcon: const Icon(Icons.subdirectory_arrow_right),
        border: const OutlineInputBorder(),
      ),
      items: state.subcategories.map((subcategory) {
        return DropdownMenuItem(
          value: subcategory.id,
          child: Text(subcategory.name),
        );
      }).toList(),
      onChanged: state.categoryId.isEmpty
          ? null
          : (value) {
              if (value != null) {
                context
                    .read<DocumentUploadBloc>()
                    .add(SubcategoryChanged(value));
              }
            },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Seleccione una subcategoría';
        }
        return null;
      },
    );
  }

  Widget _buildDownloadPermissionToggle(
    BuildContext context,
    DocumentUploadReady state,
    AppLocalizations l10n,
  ) {
    return SwitchListTile(
      title: Text(l10n.downloadDocument),
      subtitle: const Text('Permitir descargar este documento'),
      value: state.canDownload,
      onChanged: (value) {
        context
            .read<DocumentUploadBloc>()
            .add(DownloadPermissionChanged(value));
      },
      secondary: const Icon(Icons.download),
    );
  }

  Widget _buildUploadButton(
    BuildContext context,
    DocumentUploadReady state,
    AppLocalizations l10n,
  ) {
    return ElevatedButton.icon(
      onPressed: state.isValid
          ? () {
              if (_formKey.currentState!.validate()) {
                context
                    .read<DocumentUploadBloc>()
                    .add(const SubmitDocumentUpload());
              }
            }
          : null,
      icon: const Icon(Icons.cloud_upload),
      label: Text(l10n.uploadDocuments),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(16),
      ),
    );
  }
}
