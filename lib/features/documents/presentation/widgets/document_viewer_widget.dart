import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:conectasoc/features/documents/domain/entities/document_entity.dart';
import 'package:conectasoc/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Widget para visualizar documentos.
///
/// Muestra:
/// - Thumbnail del documento
/// - Nombre y descripción
/// - Botones: Ver en navegador / Descargar (si canDownload)
/// - Metadata: extensión, tamaño, fecha
class DocumentViewerWidget extends StatelessWidget {
  final DocumentEntity document;
  final VoidCallback? onClose;

  const DocumentViewerWidget({
    super.key,
    required this.document,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header con título y botón cerrar ──────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _extensionColor(document.fileExtension).withAlpha(10),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _extensionIcon(document.fileExtension),
                  color: _extensionColor(document.fileExtension),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        document.fileName,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${document.fileExtension.toUpperCase()} • ${document.formattedFileSize}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                    ],
                  ),
                ),
                if (onClose != null)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onClose,
                  ),
              ],
            ),
          ),

          // ── Thumbnail o placeholder ───────────────────────────────────
          Expanded(
            child: _buildThumbnail(context),
          ),

          // ── Descripción ───────────────────────────────────────────────
          if (document.descDoc.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.documentDescription,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    document.descDoc,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),

          const Divider(height: 1),

          // ── Botones de acción ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Botón: Ver en navegador
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openDocument(context, document.urlDoc),
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: Text(l10n.viewDocument),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Botón: Descargar (solo si canDownload)
                if (document.canDownload)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _downloadDocument(
                          context, document.urlDoc, document.fileName),
                      icon: const Icon(Icons.download, size: 18),
                      label: Text(l10n.downloadDocument),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: Tooltip(
                      message: 'Descarga deshabilitada para este documento',
                      child: OutlinedButton.icon(
                        onPressed: null,
                        icon: const Icon(Icons.lock_outline, size: 18),
                        label: const Text('Descarga bloqueada'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context) {
    if (document.urlThumb.isEmpty) {
      // Placeholder con icono
      return Container(
        color: _extensionColor(document.fileExtension).withAlpha(10),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _extensionIcon(document.fileExtension),
                size: 80,
                color: _extensionColor(document.fileExtension).withAlpha(50),
              ),
              const SizedBox(height: 12),
              Text(
                document.fileExtension.toUpperCase(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _extensionColor(document.fileExtension),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Mostrar thumbnail real
    return Container(
      color: Colors.grey.shade100,
      child: CachedNetworkImage(
        imageUrl: document.urlThumb,
        fit: BoxFit.contain,
        placeholder: (_, __) => const Center(
          child: CircularProgressIndicator(),
        ),
        errorWidget: (_, __, ___) => Center(
          child: Icon(
            _extensionIcon(document.fileExtension),
            size: 80,
            color: _extensionColor(document.fileExtension).withAlpha(50),
          ),
        ),
        httpHeaders: {
          'Cache-Control': 'max-age=86400', // 24 horas
        },
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

  Future<void> _openDocument(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);

      final launched = await launchUrl(
        uri,
        mode: kIsWeb
            ? LaunchMode.platformDefault // Web: pestaña nueva
            : LaunchMode.externalApplication, // Desktop: app externa
      );

      if (!launched && context.mounted) {
        _showErrorDialog(
          context,
          'No se pudo abrir el documento',
          'Copia esta URL y ábrela en tu navegador:\n\n$url',
          showCopyButton: true,
          url: url,
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorDialog(
          context,
          'Error al abrir el documento',
          'Error: $e\n\nCopia esta URL...',
          showCopyButton: true,
          url: url,
        );
      }
    }
  }

  Future<void> _downloadDocument(
      BuildContext context, String url, String filename) async {
    try {
      final uri = Uri.parse(url);

      // Intentar descargar
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
      );

      if (!launched && context.mounted) {
        _showErrorDialog(
          context,
          'No se pudo descargar el documento',
          'Copia esta URL y pégala en tu navegador para descargar:\n\n$url',
          showCopyButton: true,
          url: url,
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorDialog(
          context,
          'Error al descargar',
          'Error: $e\n\nCopia esta URL y pégala en tu navegador:\n\n$url',
          showCopyButton: true,
          url: url,
        );
      }
    }
  }

// ✨ Diálogo de error mejorado con opción de copiar URL
  void _showErrorDialog(
    BuildContext context,
    String title,
    String message, {
    bool showCopyButton = false,
    String? url,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.orange.shade700),
            const SizedBox(width: 12),
            Expanded(child: Text(title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            if (showCopyButton && url != null) ...[
              const SizedBox(height: 16),
              SelectableText(
                url,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cerrar'),
          ),
          if (showCopyButton && url != null)
            ElevatedButton.icon(
              onPressed: () {
                // Copiar al portapapeles
                _copyToClipboard(context, url);
                Navigator.of(dialogContext).pop();
              },
              icon: const Icon(Icons.copy, size: 18),
              label: const Text('Copiar URL'),
            ),
        ],
      ),
    );
  }

  // ✨ Copiar URL al portapapeles
  Future<void> _copyToClipboard(BuildContext context, String text) async {
    try {
      // Importar Clipboard de flutter/services
      await Clipboard.setData(ClipboardData(text: text));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('URL copiada al portapapeles'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo copiar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
