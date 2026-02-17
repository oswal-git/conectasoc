import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:conectasoc/features/auth/presentation/bloc/bloc.dart';
import 'package:conectasoc/features/documents/domain/entities/document_entity.dart';
import 'package:conectasoc/features/documents/domain/entities/document_link_entity.dart';
import 'package:conectasoc/features/documents/presentation/pages/pages.dart';
import 'package:conectasoc/features/documents/presentation/widgets/document_search_dialog.dart';
import 'package:conectasoc/features/documents/presentation/widgets/widgets.dart';
import 'package:conectasoc/l10n/app_localizations.dart';

/// Widget de selección de documento.
///
/// Muestra:
///  - El documento ya enlazado (thumbnail + descripción + botón quitar)
///  - O los dos botones para buscar / subir uno nuevo
///
/// Callback [onDocumentSelected] recibe el [DocumentLinkEntity] cuando el usuario
/// elige un documento (o null cuando lo elimina).
class DocumentPickerWidget extends StatelessWidget {
  final DocumentLinkEntity? currentDocumentLink;
  final bool isEnabled;
  final void Function(DocumentLinkEntity?) onDocumentSelected;

  const DocumentPickerWidget({
    super.key,
    required this.currentDocumentLink,
    required this.isEnabled,
    required this.onDocumentSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Etiqueta de sección
        Row(
          children: [
            const Icon(Icons.attach_file, size: 18),
            const SizedBox(width: 6),
            Text(
              l10n.linkDocument,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Documento ya enlazado
        if (currentDocumentLink != null)
          _LinkedDocumentCard(
            documentLink: currentDocumentLink!,
            isEnabled: isEnabled,
            onRemove: () => onDocumentSelected(null),
          )
        // Sin documento: mostrar opciones de selección
        else if (isEnabled)
          _SelectionButtons(onDocumentSelected: onDocumentSelected),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Tarjeta del documento ya seleccionado
// ─────────────────────────────────────────────

class _LinkedDocumentCard extends StatelessWidget {
  final DocumentLinkEntity documentLink;
  final bool isEnabled;
  final VoidCallback onRemove;

  const _LinkedDocumentCard({
    required this.documentLink,
    required this.isEnabled,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ext = documentLink.fileExtension.toLowerCase();
    final color = _extensionColor(ext);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: color.withAlpha(40)),
        borderRadius: BorderRadius.circular(8),
        color: color.withAlpha(50),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(8)),
            child: SizedBox(
              width: 56,
              height: 72,
              child: documentLink.urlThumb.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: documentLink.urlThumb,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) =>
                          _IconFallback(ext: ext, color: color),
                    )
                  : _IconFallback(ext: ext, color: color),
            ),
          ),

          // Descripción
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    documentLink.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withAlpha(120),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      ext.toUpperCase(),
                      style: TextStyle(
                          fontSize: 10,
                          color: color,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Botón quitar
          if (isEnabled)
            IconButton(
              icon: const Icon(Icons.link_off, color: Colors.red),
              tooltip: l10n.removeDocumentLink,
              onPressed: onRemove,
            ),
        ],
      ),
    );
  }

  Color _extensionColor(String ext) {
    switch (ext) {
      case 'pdf':
        return Colors.red.shade600;
      case 'doc':
      case 'docx':
        return Colors.blue.shade600;
      case 'xls':
      case 'xlsx':
        return Colors.green.shade600;
      case 'ppt':
      case 'pptx':
        return Colors.orange.shade600;
      default:
        return Colors.grey.shade600;
    }
  }
}

class _IconFallback extends StatelessWidget {
  final String ext;
  final Color color;

  const _IconFallback({required this.ext, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.insert_drive_file, color: Colors.white, size: 24),
          const SizedBox(height: 2),
          Text(
            ext.toUpperCase(),
            style: const TextStyle(
                color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Botones de selección (buscar / subir nuevo)
// ─────────────────────────────────────────────

class _SelectionButtons extends StatelessWidget {
  final void Function(DocumentLinkEntity?) onDocumentSelected;

  const _SelectionButtons({required this.onDocumentSelected});

  String? _associationId(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      return authState.user.isSuperAdmin
          ? null // superadmin ve todos
          : authState.currentMembership?.associationId;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        // Botón: buscar documento existente
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              final doc = await showDocumentSearchDialog(
                context: context,
                associationId: _associationId(context),
              );
              if (doc != null) {
                onDocumentSelected(_documentToLink(doc));
              }
            },
            icon: const Icon(Icons.search, size: 18),
            label:
                Text(l10n.searchDocument, style: const TextStyle(fontSize: 13)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Botón: subir documento nuevo
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              final doc = await Navigator.of(context).push<DocumentEntity>(
                MaterialPageRoute(
                  builder: (_) => const DocumentUploadPage(),
                  fullscreenDialog: true,
                ),
              );
              if (doc != null) {
                onDocumentSelected(_documentToLink(doc));
              }
            },
            icon: const Icon(Icons.upload_file, size: 18),
            label: Text(l10n.uploadNewDocument,
                style: const TextStyle(fontSize: 13)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ),
      ],
    );
  }

  DocumentLinkEntity _documentToLink(DocumentEntity doc) {
    return DocumentLinkEntity(
      documentId: doc.id,
      description: doc.descDoc,
      urlThumb: doc.urlThumb,
      urlDoc: doc.urlDoc,
      fileExtension: doc.fileExtension,
    );
  }
}
