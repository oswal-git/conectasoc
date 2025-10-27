// lib/features/home/presentation/pages/home_page.dart

import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:conectasoc/app/router/route_names.dart';
import 'package:conectasoc/features/articles/domain/entities/entities.dart';
import 'package:conectasoc/features/associations/domain/entities/entities.dart';
import 'package:conectasoc/features/auth/domain/entities/entities.dart';
import 'package:conectasoc/features/auth/presentation/bloc/bloc.dart';
import 'package:conectasoc/features/home/presentation/bloc/bloc.dart';
import 'package:conectasoc/features/home/presentation/widgets/widgets.dart';
import 'package:conectasoc/injection_container.dart';
import 'package:conectasoc/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    UserEntity? user;
    MembershipEntity? membership;
    bool canEdit = false;

    if (authState is AuthAuthenticated) {
      user = authState.user;
      membership = authState.currentMembership;
      final role = membership?.role;
      canEdit = role == 'superadmin' || role == 'admin' || role == 'editor';
    }

    return BlocProvider(
      create: (context) => // Pass isEditMode to HomeBloc
          sl<HomeBloc>()..add(LoadHomeData(user: user, membership: membership)),
      child: _HomePageView(canEdit: canEdit),
    );
  }
}

class _HomePageView extends StatelessWidget {
  final bool canEdit;
  const _HomePageView({required this.canEdit});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    return Scaffold(
      appBar: AppBar(
        // El título ahora se construye aquí, con acceso a ambos BLoCs.
        title: _buildAppBarTitle(context, authState),
        actions: [
          if (canEdit)
            BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                final isEditMode =
                    state is HomeLoaded ? state.isEditMode : false;
                return IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, animation) {
                      return RotationTransition(
                        turns: animation,
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                    child: Icon(
                      isEditMode ? Icons.check_circle : Icons.edit_outlined,
                      key: ValueKey(isEditMode),
                      color: isEditMode ? Colors.green : null,
                    ),
                  ),
                  onPressed: () =>
                      context.read<HomeBloc>().add(ToggleEditMode()),
                  tooltip: isEditMode
                      ? AppLocalizations.of(context)!.saveChanges
                      : AppLocalizations.of(context)!.editMode,
                );
              },
            ),
        ],
      ),
      drawer: const HomeDrawer(), // El drawer se define aquí.
      body: const _HomeView(),
      floatingActionButton: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          // Obtenemos el estado de AuthBloc para acceder a la info del usuario.
          final authState = context.read<AuthBloc>().state;

          final bool canCreate = (state is HomeLoaded) &&
              (authState is AuthAuthenticated) &&
              state.isEditMode &&
              (authState.user.canEditContent);

          if (canCreate) {
            return FloatingActionButton(
              onPressed: () {
                context.goNamed(RouteNames.articleCreate);
              },
              tooltip: AppLocalizations.of(context)!.createArticle,
              child: const Icon(Icons.add),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  Widget _buildAppBarTitle(BuildContext context, AuthState authState) {
    final l10n = AppLocalizations.of(context)!;
    final homeState = context.watch<HomeBloc>().state;

    if (authState is AuthAuthenticated) {
      String associationName = l10n.unknownAssociation;
      if (homeState is HomeLoaded) {
        try {
          associationName = homeState.associations
              .firstWhere((assoc) =>
                  assoc.id == authState.currentMembership?.associationId)
              .shortName;
        } catch (e) {
          // Asociación no encontrada, se usa el nombre por defecto
        }
      }

      if (authState.user.memberships.length > 1) {
        return InkWell(
          onTap: () => _showMembershipSwitcher(context, authState, homeState),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  associationName,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down, size: 24),
            ],
          ),
        );
      }
      // Envolver también en una Row y Flexible para manejar el overflow
      // cuando solo hay una asociación.
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
              child: Text(associationName, overflow: TextOverflow.ellipsis))
        ],
      );
    }

    return Text(l10n.homePage);
  }

  void _showMembershipSwitcher(
      BuildContext context, AuthAuthenticated authState, HomeState homeState) {
    if (homeState is! HomeLoaded) return;

    if (!context.mounted) return;

    final authBloc = context.read<AuthBloc>();
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) {
        final memberships = authState.user.memberships.entries.toList();
        return AlertDialog(
          title: Text(l10n.changeAssociation),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: memberships.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final membershipEntry = memberships[index];
                final membership = MembershipEntity(
                  userId: authState.user.uid,
                  associationId: membershipEntry.key,
                  role: membershipEntry.value,
                );
                final isCurrent = membership.associationId ==
                    authState.currentMembership!.associationId;

                AssociationEntity? association;
                try {
                  association = homeState.associations.firstWhere(
                      (assoc) => assoc.id == membership.associationId);
                } catch (e) {
                  // Asociación no encontrada
                }

                final logoUrl = association?.logoUrl;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey[200],
                    backgroundImage: (logoUrl != null && logoUrl.isNotEmpty)
                        ? CachedNetworkImageProvider(logoUrl)
                        : null,
                    child: (logoUrl == null || logoUrl.isEmpty)
                        ? const Icon(Icons.group, color: Colors.grey)
                        : null,
                  ),
                  title: Text(association?.longName ?? l10n.unknownAssociation),
                  subtitle: Text(l10n.role(membership.role)),
                  trailing: isCurrent
                      ? const Icon(Icons.check_circle,
                          color: Colors.blue, size: 28)
                      : IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          onPressed: () {
                            Navigator.of(dialogContext)
                                .pop(); // Cierra el diálogo actual
                            _confirmLeaveAssociation(context, membership);
                          },
                        ),
                  onTap: () {
                    if (!isCurrent) {
                      authBloc.add(AuthSwitchMembership(membership));
                    }
                    Navigator.of(dialogContext).pop();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    );
  }

  void _confirmLeaveAssociation(
      BuildContext context, MembershipEntity membership) {
    final l10n = AppLocalizations.of(context)!;
    final homeState = context.read<HomeBloc>().state;
    String associationName = l10n.unknownAssociation;

    if (homeState is HomeLoaded) {
      try {
        associationName = homeState.associations
            .firstWhere((assoc) => assoc.id == membership.associationId)
            .longName;
      } catch (e) {
        // Si no se encuentra, se usa el nombre por defecto.
      }
    }

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.leaveAssociationConfirmationTitle),
        content:
            Text(l10n.leaveAssociationConfirmationMessage(associationName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(AuthLeaveAssociation(membership));
              Navigator.of(dialogContext).pop();
            },
            child: Text(l10n.leave, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();
  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  // Debounce timer for search input
  static Timer? _searchDebounce;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: TextEditingController(
                text: (context.watch<HomeBloc>().state is HomeLoaded)
                    ? (context.watch<HomeBloc>().state as HomeLoaded).searchTerm
                    : ''),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.search,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            ),
            onChanged: (query) {
              _searchDebounce?.cancel();
              _searchDebounce = Timer(const Duration(milliseconds: 300), () {
                context.read<HomeBloc>().add(SearchQueryChanged(query));
              });
            },
          ),
        ),
        const _CategoryFilterBar(),
        Expanded(
          child: _ArticleList(),
        ),
      ],
    );
  }
}

class _ArticleList extends StatefulWidget {
  @override
  __ArticleListState createState() => __ArticleListState();
}

class __ArticleListState extends State<_ArticleList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      final authState = context.read<AuthBloc>().state;
      UserEntity? user;
      if (authState is AuthAuthenticated) {
        user = authState.user;
      }
      context.read<HomeBloc>().add(LoadMoreArticles(user: user));
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    // Trigger loading a bit before reaching the absolute end
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading || state is HomeInitial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is HomeError) {
          return Center(child: Text(state.message));
        }
        if (state is HomeLoaded) {
          if (state.filteredArticles.isEmpty) {
            return Center(
                child: Text(
              state.searchTerm.isNotEmpty
                  ? AppLocalizations.of(context)!.noResultsFound
                  : AppLocalizations.of(context)!.noArticlesYet,
              textAlign: TextAlign.center,
            ));
          }
          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.only(bottom: 80), // For FAB
            itemCount: state.hasMore
                ? state.filteredArticles.length + 1
                : state.filteredArticles.length,
            itemBuilder: (context, index) {
              if (index >= state.filteredArticles.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              final article = state.filteredArticles[index];
              return _ArticleCard(article: article);
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _CategoryFilterBar extends StatelessWidget {
  const _CategoryFilterBar();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      // buildWhen para evitar reconstrucciones innecesarias
      buildWhen: (previous, current) =>
          previous is! HomeLoaded ||
          (current is HomeLoaded &&
              (previous.categories != current.categories ||
                  previous.subcategories != current.subcategories ||
                  previous.selectedCategory != current.selectedCategory ||
                  previous.selectedSubcategory != current.selectedSubcategory)),
      builder: (context, state) {
        if (state is! HomeLoaded) {
          return const SizedBox(height: 50);
        }

        final loadedState = state;

        // Si hay una categoría seleccionada, mostramos las subcategorías
        if (loadedState.selectedCategory != null) {
          return _buildFilterList(
            context: context,
            items: loadedState.subcategories,
            onItemSelected: (item) => context
                .read<HomeBloc>()
                .add(SubcategorySelected(item as SubcategoryEntity)),
            onClear: () => context.read<HomeBloc>().add(ClearCategoryFilter()),
            selectedItem: loadedState.selectedSubcategory,
            clearText: AppLocalizations.of(context)!.all,
          );
        }

        // Si no, mostramos las categorías principales
        return _buildFilterList(
          context: context,
          items: loadedState.categories,
          onItemSelected: (item) =>
              context.read<HomeBloc>().add(CategorySelected(item)),
          selectedItem: loadedState.selectedCategory,
        );
      },
    );
  }

  Widget _buildFilterList({
    required BuildContext context,
    required List<CategoryEntity> items,
    required Function(CategoryEntity) onItemSelected,
    CategoryEntity? selectedItem,
    VoidCallback? onClear,
    String? clearText,
  }) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          if (onClear != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ChoiceChip(
                label: Text(clearText!),
                selected: selectedItem == null,
                onSelected: (_) => onClear(),
              ),
            ),
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ChoiceChip(
                label: Text(item.name),
                selected: selectedItem?.id == item.id,
                onSelected: (_) => onItemSelected(item),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final ArticleEntity article;

  const _ArticleCard({required this.article});

  // Helper to convert Quill JSON to plain text
  String _quillJsonToPlainText(String quillJson) {
    if (quillJson.isEmpty) return '';
    try {
      final doc = quill.Document.fromJson(jsonDecode(quillJson));
      return doc.toPlainText().trim();
    } catch (e) {
      return ''; // Handle malformed JSON gracefully
    }
  }

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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: _getBackgroundColor(article.status),
      child: InkWell(
        onTap: () {
          // Navigate to article detail or edit page
          final homeState = context.read<HomeBloc>().state;
          if (homeState is HomeLoaded && homeState.isEditMode) {
            context.goNamed(RouteNames.articleEdit,
                pathParameters: {'articleId': article.id});
          } else {
            context.goNamed(RouteNames.articleDetail,
                pathParameters: {'articleId': article.id});
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
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
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _quillJsonToPlainText(
                          article.title), // Render rich text as plain
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _quillJsonToPlainText(
                          article.abstractContent), // Render rich text as plain
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${article.categoryId} > ${article.subcategoryId} - ${DateFormat.yMd().format(article.publishDate)}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                        if (context.read<HomeBloc>().state is HomeLoaded &&
                            (context.read<HomeBloc>().state as HomeLoaded)
                                .isEditMode)
                          const Icon(Icons.edit, size: 18, color: Colors.blue),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
