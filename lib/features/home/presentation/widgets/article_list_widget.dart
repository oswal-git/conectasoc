import 'package:conectasoc/features/home/presentation/widgets/article_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:conectasoc/features/auth/domain/entities/entities.dart';
import 'package:conectasoc/features/auth/presentation/bloc/bloc.dart';
import 'package:conectasoc/features/home/presentation/bloc/bloc.dart';
import 'package:conectasoc/l10n/app_localizations.dart';

class ArticleListWidget extends StatefulWidget {
  const ArticleListWidget({super.key});

  @override
  ArticleListWidgetState createState() => ArticleListWidgetState();
}

class ArticleListWidgetState extends State<ArticleListWidget> {
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
                  ? AppLocalizations.of(context).noResultsFound
                  : AppLocalizations.of(context).noArticlesYet,
              textAlign: TextAlign.center,
            ));
          }
          return RefreshIndicator(
            onRefresh: () async {
              final authState = context.read<AuthBloc>().state;
              UserEntity? user;
              MembershipEntity? membership;
              if (authState is AuthAuthenticated) {
                user = authState.user;
                membership = authState.currentMembership;
              }

              final homeBloc = context.read<HomeBloc>();
              homeBloc.add(LoadHomeData(
                user: user,
                membership: membership,
                isEditMode: state.isEditMode,
                forceReload: true,
              ));

              // We wait until the state is no longer loading
              await homeBloc.stream.firstWhere(
                  (state) => state is! HomeLoaded || !state.isLoading);
            },
            child: ListView.builder(
              controller: _scrollController,
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
                return ArticleCardWidget(article: article);
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
