import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:conectasoc/features/documents/domain/entities/document_entity.dart';

/// Muestra el thumbnail de un documento con icono de fallback según extensión
class DocumentThumbnailWidget extends StatelessWidget {
  final DocumentEntity document;
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const DocumentThumbnailWidget({
    super.key,
    required this.document,
    this.width = 64,
    this.height = 80,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(6);

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: width,
        height: height,
        child: document.urlThumb.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: document.urlThumb,
                fit: BoxFit.cover,
                placeholder: (_, __) => _buildPlaceholder(context),
                errorWidget: (_, __, ___) => _buildIconFallback(context),
              )
            : _buildIconFallback(context),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  Widget _buildIconFallback(BuildContext context) {
    final config = _extensionConfig(document.fileExtension);
    return Container(
      color: config.backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(config.icon, color: Colors.white, size: 28),
          const SizedBox(height: 4),
          Text(
            document.fileExtension.toUpperCase(),
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

  _ExtensionConfig _extensionConfig(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return _ExtensionConfig(Colors.red.shade700, Icons.picture_as_pdf);
      case 'doc':
      case 'docx':
        return _ExtensionConfig(Colors.blue.shade700, Icons.description);
      case 'xls':
      case 'xlsx':
        return _ExtensionConfig(Colors.green.shade700, Icons.table_chart);
      case 'ppt':
      case 'pptx':
        return _ExtensionConfig(Colors.orange.shade700, Icons.slideshow);
      default:
        return _ExtensionConfig(Colors.grey.shade700, Icons.insert_drive_file);
    }
  }
}

class _ExtensionConfig {
  final Color backgroundColor;
  final IconData icon;
  const _ExtensionConfig(this.backgroundColor, this.icon);
}
