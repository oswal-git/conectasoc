import 'package:conectasoc/app/theme/theme.dart';
import 'package:conectasoc/core/utils/utils.dart';
import 'package:conectasoc/services/snackbar_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:conectasoc/features/documents/domain/entities/document_entity.dart';
import 'package:conectasoc/features/documents/domain/usecases/usecases.dart';
import 'package:conectasoc/features/documents/presentation/widgets/document_viewer_widget.dart';
import 'package:conectasoc/injection_container.dart';
import 'package:conectasoc/l10n/app_localizations.dart';

class DocumentViewPage extends StatefulWidget {
  final String documentId;

  const DocumentViewPage({super.key, required this.documentId});

  @override
  State<DocumentViewPage> createState() => _DocumentViewPageState();
}

class _DocumentViewPageState extends State<DocumentViewPage> {
  late Future<DocumentEntity?> _documentFuture;

  @override
  void initState() {
    super.initState();
    _documentFuture = _loadDocument(widget.documentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).documentDetails),
        actions: [
          FutureBuilder<DocumentEntity?>(
            future: _documentFuture,
            builder: (context, snapshot) {
              if (snapshot.data == null) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Eliminar documento',
                onPressed: () {
                  _confirmDelete(context, snapshot.data!);
                },
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<DocumentEntity?>(
        future: _documentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline,
                      size: 56, color: Colors.red.shade400),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }

          final document = snapshot.data;
          if (document == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.description_outlined,
                      size: 56, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context).documentNotAvailable,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          return _DocumentViewContent(document: document);
        },
      ),
    );
  }

  Future<DocumentEntity?> _loadDocument(String documentId) async {
    final getDocumentUseCase = sl<GetDocumentByIdUseCase>();
    final result = await getDocumentUseCase(documentId);
    return result.fold(
      (failure) => null,
      (document) => document,
    );
  }
}

Future<void> _confirmDelete(
    BuildContext context, DocumentEntity document) async {
  // Primero comprobar si el documento está enlazado en algún artículo
  final isLinked = await _isDocumentLinked(document.id);

  if (!context.mounted) return;

  if (isLinked) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.link, color: Colors.orange.shade700),
            const SizedBox(width: 12),
            const Expanded(child: Text('No se puede eliminar')),
          ],
        ),
        content: const Text(
          'Este documento está enlazado en uno o más artículos. '
          'Desvincula el documento de los artículos antes de eliminarlo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
    return;
  }

  // Confirmación de borrado
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Row(
        children: [
          Icon(Icons.delete_outline, color: Colors.red.shade700),
          const SizedBox(width: 12),
          const Expanded(child: Text('Eliminar documento')),
        ],
      ),
      content: Text(
        '¿Estás seguro de que quieres eliminar "${document.fileName}"? '
        'Esta acción no se puede deshacer.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade700,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) return;

  final result = await sl<DeleteDocumentUseCase>()(document.id);
  if (!context.mounted) return;

  result.fold(
    (failure) => SnackBarService.showSnackBar(failure.message, isError: true),
    (_) {
      SnackBarService.showSnackBar('Documento eliminado correctamente');
      if (context.mounted) {
        context.pop(true); // Volver a la lista con resultado true
      }
    },
  );
}

Future<bool> _isDocumentLinked(String documentId) async {
  final useCase = sl<IsDocumentLinkedUseCase>();
  final result = await useCase(documentId);
  return result.fold(
    (failure) {
      debugPrint(
          'Error al comprobar si el documento está enlazado: not isLinked');
      return false;
    }, // Si falla la comprobación, permitimos el flujo (o podrías manejarlo distinto)
    (isLinked) {
      debugPrint('El documento está enlazado: isLinked');
      return isLinked;
    },
  );
}

// ─── Widget de contenido ──────────────────────────────────────────────────────
class _DocumentViewContent extends StatelessWidget {
  final DocumentEntity document;

  const _DocumentViewContent({required this.document});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: AppTheme.paddingContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Visor principal ───────────────────────────────────────────
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 600),
            child: DocumentViewerWidget(document: document),
          ),
          // AppTheme.sizedBoxHeightSeparatorMd,

          // ── Metadata ──────────────────────────────────────────────────
          _buildMetadataSection(context, l10n, document),
        ],
      ),
    );
  }

  Widget _buildMetadataSection(
    BuildContext context,
    AppLocalizations l10n,
    DocumentEntity doc,
  ) {
    return Padding(
      padding: AppTheme.paddingCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información del documento',
            style: AppTheme.informationFileName(context),
          ),
          AppTheme.sizedBoxHeightSeparatorSsm,
          _buildMetadataRow(
            context,
            icon: Icons.category_outlined,
            label: l10n.category,
            value: '${doc.categoryName} › ${doc.subcategoryName}',
          ),
          AppTheme.sizedBoxHeightWidget,
          _buildMetadataRow(
            context,
            icon: Icons.storage_outlined,
            label: l10n.fileSize,
            value: doc.formattedFileSize,
          ),
          AppTheme.sizedBoxHeightWidget,
          _buildMetadataRow(
            context,
            icon: Icons.calendar_today_outlined,
            label: 'Fecha de subida',
            value: formatUploadDate(context, doc.dateCreation),
          ),
          AppTheme.sizedBoxHeightWidget,
          _buildMetadataRow(
            context,
            icon: Icons.person_outline,
            label: l10n.uploadedBy,
            value: doc.uploaderName,
          ),
          AppTheme.sizedBoxHeightWidget,
          _buildMetadataRow(
            context,
            icon: Icons.download_outlined,
            label: l10n.canDownload,
            value: doc.canDownload ? 'Sí' : 'No',
          ),
          AppTheme.sizedBoxHeightWidgetXl,
        ],
      ),
    );
  }

  Widget _buildMetadataRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon,
            size: AppTheme.iconSizeSmall,
            color: AppColors.of(context).iconLabel),
        AppTheme.sizedBoxWidthSeparator,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.drawerSectionLabel,
              ),
              AppTheme.sizedBoxHeightSeparatorXxxs,
              Text(
                value,
                style: AppTheme.documentDescription(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
