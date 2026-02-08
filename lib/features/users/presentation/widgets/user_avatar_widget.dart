import 'package:cached_network_image/cached_network_image.dart';
import 'package:conectasoc/features/auth/domain/entities/user_entity.dart';
import 'package:conectasoc/features/users/domain/usecases/usecases.dart';
import 'package:conectasoc/injection_container.dart';
import 'package:flutter/material.dart';

class UserAvatarWidget extends StatelessWidget {
  final String userId;
  final double radius;

  const UserAvatarWidget({
    super.key,
    required this.userId,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserEntity>(
      // We use GetUserByIdUseCase from sl (service locator)
      future: sl<GetUserByIdUseCase>().call(userId).then(
            (result) => result.fold(
              (failure) => throw failure,
              (user) => user,
            ),
          ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircleAvatar(
            radius: radius,
            child: const CircularProgressIndicator(strokeWidth: 2),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return CircleAvatar(
            radius: radius,
            child: Icon(Icons.person, size: radius),
          );
        }

        final avatarUrl = snapshot.data?.avatarUrl;

        return CircleAvatar(
          radius: radius,
          backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
              ? CachedNetworkImageProvider(avatarUrl)
              : null,
          child: (avatarUrl == null || avatarUrl.isEmpty)
              ? Icon(Icons.person, size: radius)
              : null,
        );
      },
    );
  }
}
