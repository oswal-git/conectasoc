import 'package:conectasoc/app/theme/theme.dart';
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
  final Function(String articleId)? onDetailNavigated;

  const ArticleCardWidget({
    super.key,
    required this.article,
    this.onDetailNavigated,
  });

  // Determine background color based on article status
  Color _getBackgroundColor(ArticleStatus status) {
    switch (status) {
      case ArticleStatus.redaccion:
        return AppTheme.redaccion;
      case ArticleStatus.revision:
        return AppTheme.revision;
      case ArticleStatus.expirado:
        return AppTheme.expirado;
      case ArticleStatus.anulado:
        return AppTheme.anulado;
      default:
        return AppColors.of(context).iconLabel;
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleText = quillJsonToPlainText(article.title);
    final bool isLongTitle = titleText.length > 50;
    final bool translating = !(article.isTranslated ?? true);

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
      margin: AppTheme.margingCard,
      decoration: BoxDecoration(
        color: _getBackgroundColor(article.status),
        // borderRadius: BorderRadius.circular(16),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withValues(alpha: 0.1),
        //     blurRadius: 2,
        //     offset: const Offset(0, 2),
        //   ),
        // ],
        // border: Border.all(
        //   color: AppColors.of(context).iconLabel, // Colors.grey.withValues(alpha: 0.2),
        //   width: 1,
        // ),
      ),
      child: ClipRRect(
        borderRadius: AppTheme.borderRadiusCard,
        child: InkWell(
          onTap: () async {
            final homeState = context.read<HomeBloc>().state;
            if (homeState is! HomeLoaded) return;

            final result = await context.pushNamed<String>(
              RouteNames.articleDetail,
              pathParameters: {'articleId': article.id},
              extra: {
                'articles': homeState.filteredArticles,
                'initialId': article.id,
              },
            );

            if (result != null && onDetailNavigated != null) {
              onDetailNavigated!(result);
            }
          },
          child: Padding(
            padding: AppTheme.paddingCard,
            child: Row(
              children: [
                // Imagen principal a la izquierda
                if (article.coverUrl.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: article.coverUrl,
                    imageBuilder: (context, imageProvider) => Padding(
                      padding: AppTheme.paddingOnlyRight,
                      child: Container(
                        width: AppTheme.containerWidth,
                        height: AppTheme.containerHeight,
                        decoration: BoxDecoration(
                          // border: Border.all(
                          //   color: Colors.grey.shade300,
                          //   width: 1.5,
                          // ),
                          // borderRadius: BorderRadius.circular(12.0),
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    placeholder: (context, url) => Padding(
                      padding: AppTheme.paddingOnlyRight,
                      child: SizedBox(
                        width: AppTheme.containerWidth,
                        height: AppTheme.containerHeight,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                    ),
                    errorWidget: (context, url, error) =>
                        const SizedBox.shrink(),
                  ),
                // Columna de contenido a la derecha
                Expanded(
                  child: Padding(
                    padding: AppTheme.paddingCardHorizontal,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Title — shimmer while translating
                        translating
                            ? _ShimmerBox(
                                width: double.infinity,
                                height: isLongTitle ? 32 : 20,
                              )
                            : Text(
                                titleText.toUpperCase(),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: AppTheme.fontWeightBold,
                                  fontSize: isLongTitle ? 12.0 : 16.0,
                                  color: AppColors.of(context).textPrimary,
                                ),
                              ),
                        const SizedBox(height: 6),
                        // Abstract — shimmer while translating
                        translating
                            ? const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _ShimmerBox(
                                      width: double.infinity, height: 13),
                                  SizedBox(height: 4),
                                  _ShimmerBox(width: 160, height: 13),
                                ],
                              )
                            : Text(
                                quillJsonToPlainText(article.abstractContent),
                                textAlign: TextAlign.justify,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTheme.articleAbstract(context),
                              ),
                        const SizedBox(height: 8),
                        // Category / subcategory row — shimmer while translating
                        translating
                            ? Row(
                                children: const [
                                  _ShimmerBox(width: 60, height: 12),
                                  SizedBox(width: 6),
                                  _ShimmerBox(width: 60, height: 12),
                                ],
                              )
                            : Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 4.0,
                                children: [
                                  ClickableCategoryWidget(
                                    name: article.categoryName,
                                    onTap: () {
                                      final homeBloc = context.read<HomeBloc>();
                                      final homeState = homeBloc.state;

                                      if (homeState is HomeLoaded) {
                                        if (!homeState.showFilter) {
                                          homeBloc.add(ToggleFilter());
                                        }
                                        homeBloc.add(CategorySelected(
                                          CategoryEntity(
                                            id: article.categoryId,
                                            name: article.categoryName,
                                            order: 0,
                                          ),
                                        ));
                                      }
                                    },
                                  ),
                                  Text(
                                    '/',
                                    style: AppTheme.articleCategory(context),
                                  ),
                                  ClickableCategoryWidget(
                                    name: article.subcategoryName,
                                    onTap: () {
                                      final homeBloc = context.read<HomeBloc>();
                                      final homeState = homeBloc.state;

                                      if (homeState is HomeLoaded) {
                                        if (!homeState.showFilter) {
                                          homeBloc.add(ToggleFilter());
                                        }
                                        // Usamos un único evento para seleccionar categoría y subcategoría
                                        homeBloc.add(CategorySelected(
                                          CategoryEntity(
                                            id: article.categoryId,
                                            name: article.categoryName,
                                            order: 0,
                                          ),
                                          subcategory: SubcategoryEntity(
                                            id: article.subcategoryId,
                                            name: article.subcategoryName,
                                            order: 0,
                                            categoryId: article.categoryId,
                                          ),
                                        ));
                                      }
                                    },
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                ),
                // Botón de editar (si está en modo edición y tiene permisos)
                if (canEdit &&
                    context.watch<HomeBloc>().state is HomeLoaded &&
                    (context.watch<HomeBloc>().state as HomeLoaded).isEditMode)
                  IconButton(
                    icon: const Icon(Icons.edit_note,
                        size: AppTheme.iconSizeXs,
                        color: AppColors.of(context).primary),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shimmer placeholder — pure Flutter, no extra package needed
// ---------------------------------------------------------------------------

class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;

  const _ShimmerBox({required this.width, required this.height});

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: AppColors.of(context)
              .neutralText
              .withValues(alpha: _animation.value),
          borderRadius: BorderRadius.circular(AppTheme.spaceXxs),
        ),
      ),
    );
  }
}
