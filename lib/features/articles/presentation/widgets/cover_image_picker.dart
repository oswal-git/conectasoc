import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:conectasoc/core/services/image_picker_service.dart';

class CoverImagePicker extends StatelessWidget {
  final bool isEnabled;
  final String currentCoverUrl;
  final Uint8List? newImageBytes;
  final Function(Uint8List?) onImageSelected;
  final Function() onImageCleared;

  const CoverImagePicker({
    super.key,
    required this.isEnabled,
    required this.currentCoverUrl,
    required this.newImageBytes,
    required this.onImageSelected,
    required this.onImageCleared,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (newImageBytes != null)
          Stack(
            children: [
              Image.memory(newImageBytes!,
                  height: 200, width: double.infinity, fit: BoxFit.cover),
              if (isEnabled)
                Positioned(
                  right: 8,
                  top: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: onImageCleared,
                  ),
                ),
            ],
          )
        else if (currentCoverUrl.isNotEmpty)
          Stack(
            children: [
              CachedNetworkImage(
                imageUrl: currentCoverUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              if (isEnabled)
                Positioned(
                  right: 8,
                  top: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: onImageCleared,
                  ),
                ),
            ],
          ),
        if (isEnabled)
          TextButton.icon(
            onPressed: () async {
              final imagePickerService = ImagePickerService();
              final bytes = await imagePickerService.pickImage(context);
              if (bytes != null) {
                onImageSelected(bytes);
              }
            },
            icon: const Icon(Icons.image),
            label: Text(newImageBytes == null && currentCoverUrl.isEmpty
                ? 'Seleccionar Imagen de Portada'
                : 'Cambiar Imagen de Portada'),
          ),
      ],
    );
  }
}
