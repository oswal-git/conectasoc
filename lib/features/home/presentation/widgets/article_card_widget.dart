import 'package:conectasoc/core/utils/article_permissions.dart'; // Import permissions
import 'package:conectasoc/features/home/presentation/widgets/clickable_category_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:conectasoc/app/router/route_names.dart';
import 'package:conectasoc/core/utils/quill_helpers.dart';
import 'package:conectasoc/features/articles/domain/entities/entities.dart';
import 'package:conectasoc/features/auth/presentation/bloc/bloc.dart';
import 'package:conectasoc/features/home/presentation/bloc/bloc.dart';

class ArticleCardWidget extends StatelessWidget {
  final ArticleEntity article;

  const ArticleCardWidget({super.key, required this.article});

  // Determine background color based on article status
  Color _getBackgroundColor(ArticleStatus status) {
    switch (status) {
      case ArticleStatus.redaccion:
        return Colors.blue.shade50;
      case ArticleStatus.revision:
        return Colors.yellow.shade50;
      case ArticleStatus.expirado:
        return Colors.orange.shade50;
      case ArticleStatus.anulado:
        return Colors.red.shade50;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleText = quillJsonToPlainText(article.title);
    final bool isLongTitle = titleText.length > 50;

    // Get auth data to check permissions
    final authState = context.read<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;
    final currentMembership =
        authState is AuthAuthenticated ? authState.currentMembership : null;

    final bool canEdit = ArticlePermissions.canEdit(
      article: article,
      user: user,
      membership: currentMembership,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getBackgroundColor(article.status),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => context.pushNamed(RouteNames.articleDetail,
              pathParameters: {'articleId': article.id}),
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Imagen principal a la izquierda
                if (article.coverUrl.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade300, // Color del borde
                          width: 1.5, // Grosor del borde
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: CachedNetworkImage(
                          imageUrl: article.coverUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                // Columna de contenido a la derecha
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Título
                      Text(
                        titleText.toUpperCase(),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isLongTitle ? 12.0 : 16.0,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Subtítulo (Resumen)
                      Text(
                        quillJsonToPlainText(article.abstractContent),
                        textAlign: TextAlign.left,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.0,
                          color: Colors.grey.shade700,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Fila de categoría/subcategoría
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 4.0,
                        children: [
                          ClickableCategoryWidget(
                              name: article.categoryName,
                              onTap: () {
                                // Lógica para filtrar por categoría
                              }),
                          const Text('/',
                              style: TextStyle(
                                  fontSize: 10.0, color: Colors.grey)),
                          ClickableCategoryWidget(
                              name: article.subcategoryName,
                              onTap: () {
                                // Lógica para filtrar por subcategoría
                              }),
                        ],
                      ),
                    ],
                  ),
                ),
                // Botón de editar (si está en modo edición y tiene permisos)
                if (canEdit &&
                    context.watch<HomeBloc>().state is HomeLoaded &&
                    (context.watch<HomeBloc>().state as HomeLoaded).isEditMode)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: IconButton(
                      icon: const Icon(Icons.edit_note,
                          size: 24, color: Colors.blue),
                      onPressed: () async {
                        await context.pushNamed(RouteNames.articleEdit,
                            pathParameters: {'id': article.id});
                        if (context.mounted) {
                          final authState = context.read<AuthBloc>().state;
                          final homeState = context.read<HomeBloc>().state;
                          final user = authState is AuthAuthenticated
                              ? authState.user
                              : null;
                          final isEditMode = homeState is HomeLoaded
                              ? homeState.isEditMode
                              : false;
                          context.read<HomeBloc>().add(LoadHomeData(
                                user: user,
                                isEditMode: isEditMode,
                                forceReload: true,
                              ));
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
