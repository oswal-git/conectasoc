import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:conectasoc/features/articles/presentation/bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:conectasoc/features/articles/domain/entities/entities.dart';
import 'package:conectasoc/features/documents/domain/entities/document_link_entity.dart';
import 'package:conectasoc/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

/// Preview de una sección de artículo.
///
/// Soporta:
/// - Imagen + texto enriquecido (modo clásico)
/// - Documento enlazado (modo nuevo)
class PreviewSection extends StatelessWidget {
  final ArticleEditLoaded state;
  final ArticleSection section;

  const PreviewSection({
    super.key,
    required this.state,
    required this.section,
  });

  @override
  Widget build(BuildContext context) {
    // Si tiene documento enlazado, mostrar el preview del documento
    if (section.documentLink != null) {
      return _buildDocumentPreview(context, section.documentLink!);
    }

    // Si no, mostrar imagen + texto (modo clásico)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (section.imageUrl != null && section.imageUrl!.isNotEmpty)
          _buildSectionImage(section.imageUrl!),
        if (section.richTextContent != null &&
            section.richTextContent!.isNotEmpty)
          _buildRichText(section.richTextContent!),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Preview de documento enlazado
  // ─────────────────────────────────────────────

  Widget _buildDocumentPreview(
      BuildContext context, DocumentLinkEntity documentLink) {
    final l10n = AppLocalizations.of(context);
    final color = _extensionColor(documentLink.fileExtension);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _openDocument(documentLink.urlDoc),
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  width: 80,
                  height: 100,
                  child: documentLink.urlThumb.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: documentLink.urlThumb,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => _buildIconFallback(
                              documentLink.fileExtension, color),
                          httpHeaders: {
                            'Cache-Control': 'max-age=86400', // 24 horas
                          },
                        )
                      : _buildIconFallback(documentLink.fileExtension, color),
                ),
              ),
              const SizedBox(width: 14),

              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge de tipo de archivo
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withAlpha(15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: color.withAlpha(40)),
                      ),
                      child: Text(
                        documentLink.fileExtension.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Descripción
                    Text(
                      documentLink.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Botón "Ver documento"
                    Row(
                      children: [
                        Icon(Icons.open_in_new, size: 14, color: color),
                        const SizedBox(width: 4),
                        Text(
                          l10n.viewDocument,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconFallback(String ext, Color color) {
    return Container(
      color: color,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_extensionIcon(ext), color: Colors.white, size: 32),
          const SizedBox(height: 4),
          Text(
            ext.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Preview clásico (imagen + texto)
  // ─────────────────────────────────────────────

  Widget _buildSectionImage(String imageUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          placeholder: (context, url) => Container(
            height: 200,
            color: Colors.grey.shade200,
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => Container(
            height: 200,
            color: Colors.grey.shade300,
            child: const Center(child: Icon(Icons.error)),
          ),
        ),
      ),
    );
  }

  Widget _buildRichText(String richTextJson) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: quill.QuillEditor.basic(
        controller: quill.QuillController(
          document: quill.Document.fromJson(jsonDecode(richTextJson)),
          selection: const TextSelection.collapsed(offset: 0),
          readOnly: true,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────

  IconData _extensionIcon(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _extensionColor(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return Colors.red.shade700;
      case 'doc':
      case 'docx':
        return Colors.blue.shade700;
      case 'xls':
      case 'xlsx':
        return Colors.green.shade700;
      case 'ppt':
      case 'pptx':
        return Colors.orange.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  Future<void> _openDocument(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
