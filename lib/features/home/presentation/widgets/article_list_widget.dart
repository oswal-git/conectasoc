import 'package:conectasoc/core/widgets/user_friendly_error_widget.dart';
import 'package:conectasoc/features/home/presentation/widgets/article_card_widget.dart';
import 'package:conectasoc/features/users/domain/entities/entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:conectasoc/features/auth/domain/entities/entities.dart';
import 'package:conectasoc/features/auth/presentation/bloc/bloc.dart';
import 'package:conectasoc/features/home/presentation/bloc/bloc.dart';
import 'package:conectasoc/l10n/app_localizations.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ArticleListWidget extends StatefulWidget {
  const ArticleListWidget({super.key});

  @override
  ArticleListWidgetState createState() => ArticleListWidgetState();
}

class ArticleListWidgetState extends State<ArticleListWidget> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  Future<void> _refreshHomeData(bool isEditMode) async {
    final authState = context.read<AuthBloc>().state;
    IUser? user;
    MembershipEntity? membership;
    if (authState is AuthAuthenticated) {
      user = authState.user;
      membership = authState.currentMembership;
    } else if (authState is AuthLocalUser) {
      user = authState.localUser;
    }

    final homeBloc = context.read<HomeBloc>();
    // Definimos el future ANTES de añadir el evento para evitar perder el estado.
    final future = homeBloc.stream.firstWhere((state) =>
        (state is HomeLoaded && !state.isLoading) || state is HomeError);

    homeBloc.add(LoadHomeData(
      user: user,
      membership: membership,
      isEditMode: isEditMode,
      forceReload: true,
    ));

    await future;
  }

  @override
  void initState() {
    super.initState();
    _itemPositionsListener.itemPositions.addListener(_onScroll);
  }

  @override
  void dispose() {
    _itemPositionsListener.itemPositions.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) return;

    // Obtener el índice más alto visible
    final maxIndex = positions
        .map((p) => p.index)
        .reduce((value, element) => value > element ? value : element);

    final homeState = context.read<HomeBloc>().state;
    if (homeState is HomeLoaded &&
        maxIndex >= homeState.filteredArticles.length - 2) {
      if (homeState.hasMore && !homeState.isLoading) {
        final authState = context.read<AuthBloc>().state;
        IUser? user;
        if (authState is AuthAuthenticated) {
          user = authState.user;
        } else if (authState is AuthLocalUser) {
          user = authState.localUser;
        }
        context.read<HomeBloc>().add(LoadMoreArticles(user: user));
      }
    }
  }

  /// Desplaza la lista hasta el artículo con el ID especificado.
  void scrollToArticle(String articleId) {
    if (!mounted) return;
    final state = context.read<HomeBloc>().state;
    if (state is! HomeLoaded) return;

    final index = state.filteredArticles.indexWhere((a) => a.id == articleId);
    if (index != -1) {
      _itemScrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
        alignment: 0.3, // Centrar un poco el elemento en pantalla
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading || state is HomeInitial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is HomeError) {
          return UserFriendlyErrorWidget(
            errorMessage: state.message,
            onRetry: () {
              final authState = context.read<AuthBloc>().state;
              IUser? user;
              MembershipEntity? membership;
              if (authState is AuthAuthenticated) {
                user = authState.user;
                membership = authState.currentMembership;
              } else if (authState is AuthLocalUser) {
                user = authState.localUser;
              }
              context.read<HomeBloc>().add(LoadHomeData(
                    user: user,
                    membership: membership,
                    forceReload: true,
                  ));
            },
          );
        }
        if (state is HomeLoaded) {
          if (state.filteredArticles.isEmpty) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return RefreshIndicator(
                  onRefresh: () => _refreshHomeData(state.isEditMode),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Center(
                        child: Text(
                          state.searchTerm.isNotEmpty
                              ? AppLocalizations.of(context).noResultsFound
                              : AppLocalizations.of(context).noArticlesYet,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return RefreshIndicator(
            onRefresh: () => _refreshHomeData(state.isEditMode),
            child: ScrollablePositionedList.builder(
              itemScrollController: _itemScrollController,
              itemPositionsListener: _itemPositionsListener,
              padding: const EdgeInsets.only(bottom: 80), // For FAB
              physics:
                  const AlwaysScrollableScrollPhysics(), // Ensure refresh works even with short lists
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
                return ArticleCardWidget(
                  article: article,
                  onDetailNavigated: scrollToArticle,
                );
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
