import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AssociationAvatarWidget extends StatelessWidget {
  final String? logoUrl;
  final double radius;

  const AssociationAvatarWidget({
    super.key,
    required this.logoUrl,
    this.radius = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    final hasLogo = logoUrl != null && logoUrl!.isNotEmpty;

    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      backgroundImage: hasLogo ? CachedNetworkImageProvider(logoUrl!) : null,
      child: !hasLogo
          ? Icon(
              Icons.business_rounded,
              size: radius,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            )
          : null,
    );
  }
}
