import 'dart:async';

import 'package:conectasoc/features/articles/domain/usecases/get_articles_usecase.dart';
import 'package:conectasoc/features/articles/presentation/bloc/article_event_bloc.dart';
import 'package:conectasoc/features/articles/presentation/bloc/article_state_bloc.dart';
import 'package:conectasoc/features/auth/presentation/bloc/bloc.dart';
import 'package:conectasoc/features/users/domain/entities/entities.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ArticleBloc extends Bloc<ArticleEvent, ArticleState> {
  final GetArticlesUseCase _getArticlesUseCase;
  final AuthBloc _authBloc;
  StreamSubscription? _authSubscription;

  ArticleBloc({
    required GetArticlesUseCase getArticlesUseCase,
    required AuthBloc authBloc,
  })  : _getArticlesUseCase = getArticlesUseCase,
        _authBloc = authBloc,
        super(ArticleInitial()) {
    on<LoadArticles>(_onLoadArticles);

    // Listen to auth changes to reload articles with correct permissions
    _authSubscription = _authBloc.stream.listen((authState) {
      add(LoadArticles());
    });
  }

  Future<void> _onLoadArticles(
    LoadArticles event,
    Emitter<ArticleState> emit,
  ) async {
    emit(ArticleLoading());
    final authState = _authBloc.state;
    IUser? user;
    if (authState is AuthAuthenticated) {
      user = authState.user;
    } else if (authState is AuthLocalUser) {
      user = authState.localUser;
    }

    final result = await _getArticlesUseCase(
      user: user,
      categoryId: event.filter.categoryId,
      subcategoryId: event.filter.subcategoryId,
      searchTerm: event.filter.searchTerm,
    );
    result.fold(
      (failure) => emit(ArticleError(failure.message)),
      (articlesData) {
        final articles = articlesData.item1;
        // hasMore could be used for pagination in this BLoC if needed in the future.
        final hasMore = articles.length == 20;
        emit(ArticleLoaded(
            articles: articles, filter: event.filter, hasMore: hasMore));
      },
    );
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
