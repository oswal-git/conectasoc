import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SectionImage extends StatelessWidget {
  final Uint8List? imageBytes;
  final String? imageUrl;
  final VoidCallback? onRemove;

  const SectionImage({
    super.key,
    this.imageBytes,
    this.imageUrl,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isNetworkImage = imageUrl != null &&
        (imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://'));

    final hasImage = imageBytes != null || isNetworkImage;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: imageBytes != null
                ? Image.memory(
                    imageBytes!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : isNetworkImage
                    ? CachedNetworkImage(
                        imageUrl: imageUrl!,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      )
                    : const SizedBox.shrink(),
          ),
          if (onRemove != null && hasImage)
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
