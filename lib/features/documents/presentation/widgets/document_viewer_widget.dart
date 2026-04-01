import 'package:conectasoc/app/theme/theme.dart';
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Header con título y botón cerrar ──────────────────────────
        Container(
          padding: AppTheme.paddingContainer,
          decoration: BoxDecoration(
            color: _extensionColor(document.fileExtension).withAlpha(10),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppTheme.documentContainerRadius),
            ),
          ),
          child: Row(
            children: [
              Icon(
                _extensionIcon(document.fileExtension),
                color: _extensionColor(document.fileExtension),
                size: AppTheme.documentExtensionIconSize,
              ),
              AppTheme.sizedBoxWidthSeparator,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.fileName,
                      style: AppTheme.documentFileName(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppTheme.sizedBoxHeightSeparatorSm,
                    Text(
                      '${document.fileExtension.toUpperCase()} • ${document.formattedFileSize}',
                      style: AppTheme.documentExtension(context),
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
        AppTheme.sizedBoxHeightSeparatorSm,
        const Divider(height: 1),
        if (document.descDoc.isNotEmpty)
          Container(
            padding: AppTheme.paddingCard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTheme.sizedBoxHeightSeparatorXxs,
                Text(
                  l10n.documentDescription,
                  style: AppTheme.documentFileName(context),
                ),
                Padding(
                  padding: AppTheme.paddingLeftIndent,
                  child: Text(
                    document.descDoc,
                    style: AppTheme.documentDescription(context),
                  ),
                ),
              ],
            ),
          ),

        const Divider(height: 1),

        // ── Botones de acción ─────────────────────────────────────────
        Padding(
          padding: AppTheme.paddingContainer,
          child: Row(
            mainAxisAlignment: MainAxisAlignment
                .spaceEvenly, // espacio igual entre botones y laterales
            children: [
              // Botón: Ver en navegador
              Tooltip(
                message: 'Visualizar documento',
                child: ElevatedButton(
                  onPressed: () => _openDocument(context, document.urlDoc),
                  style: ElevatedButton.styleFrom(
                    padding: AppTheme.paddingVerticalSsm,
                    minimumSize:
                        const Size(128, 48), // ancho mínimo, alto mínimo
                  ),
                  child:
                      const Icon(Icons.visibility, size: AppTheme.iconSizeXs),
                ),
              ),
              AppTheme.sizedBoxWidthSeparator,

              // Botón: Descargar (solo si canDownload)
              document.canDownload
                  ? Tooltip(
                      message: 'Descargar documento',
                      child: ElevatedButton(
                        onPressed: () => _downloadDocument(
                            context, document.urlDoc, document.fileName),
                        style: ElevatedButton.styleFrom(
                          padding: AppTheme.paddingVerticalSsm,
                          minimumSize: const Size(128, 48),
                        ),
                        child: const Icon(Icons.download,
                            size: AppTheme.iconSizeXs),
                      ),
                    )
                  : Tooltip(
                      message: 'Descarga deshabilitada para este documento',
                      child: ElevatedButton(
                        onPressed: null,
                        style: ElevatedButton.styleFrom(
                          padding: AppTheme.paddingVerticalSsm,
                          minimumSize:
                              const Size(128, 48), // ancho mínimo, alto mínimo
                        ),
                        child: const Icon(Icons.lock_outline,
                            size: AppTheme.iconSizeXs),
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThumbnail(BuildContext context) {
    if (document.urlThumb.isEmpty) {
      // Placeholder con icono
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _extensionIcon(document.fileExtension),
              size: AppTheme.iconSizeApp,
              color: _extensionColor(document.fileExtension).withAlpha(50),
            ),
            AppTheme.sizedBoxHeightSeparatorSsm,
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
      );
    }

    // Mostrar thumbnail real
    return CachedNetworkImage(
      imageUrl: document.urlThumb,
      fit: BoxFit.contain,
      placeholder: (_, __) => const Center(
        child: CircularProgressIndicator(),
      ),
      errorWidget: (_, __, ___) => Center(
        child: Icon(
          _extensionIcon(document.fileExtension),
          size: AppTheme.iconSizeApp,
          color: _extensionColor(document.fileExtension).withAlpha(50),
        ),
      ),
      httpHeaders: {
        'Cache-Control': 'max-age=86400', // 24 horas
      },
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
        return AppTheme.fileTypePdf;
      case 'doc':
      case 'docx':
        return AppTheme.fileTypeWord;
      case 'xls':
      case 'xlsx':
        return AppTheme.fileTypeExcel;
      case 'ppt':
      case 'pptx':
        return AppTheme.fileTypePpt;
      default:
        return AppTheme.fileTypeDefault;
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
