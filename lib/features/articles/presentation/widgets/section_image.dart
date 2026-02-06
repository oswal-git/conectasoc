import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SectionImage extends StatelessWidget {
  final Uint8List? imageBytes;
  final String? imageUrl;

  const SectionImage({
    super.key,
    this.imageBytes,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final isNetworkImage = imageUrl != null &&
        (imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://'));

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ClipRRect(
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
    );
  }
}
