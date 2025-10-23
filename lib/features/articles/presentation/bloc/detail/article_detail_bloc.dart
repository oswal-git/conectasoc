import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:conectasoc/features/articles/domain/usecases/usecases.dart';
import 'package:conectasoc/features/articles/presentation/bloc/bloc.dart';
import 'package:conectasoc/features/auth/presentation/bloc/bloc.dart';
import 'package:conectasoc/core/services/translation_service.dart';

class ArticleDetailBloc extends Bloc<ArticleDetailEvent, ArticleDetailState> {
  final GetArticleByIdUseCase _getArticleByIdUseCase;
  final TranslationService _translationService;
  final AuthBloc _authBloc;

  ArticleDetailBloc(
      {required GetArticleByIdUseCase getArticleByIdUseCase,
      required TranslationService translationService,
      required AuthBloc authBloc})
      : _getArticleByIdUseCase = getArticleByIdUseCase,
        _translationService = translationService,
        _authBloc = authBloc,
        super(ArticleDetailInitial()) {
    on<LoadArticleDetail>(_onLoadArticleDetail);
  }

  Future<void> _onLoadArticleDetail(
    LoadArticleDetail event,
    Emitter<ArticleDetailState> emit,
  ) async {
    emit(ArticleDetailLoading());
    final result = await _getArticleByIdUseCase(event.articleId);
    result.fold(
      (failure) => emit(ArticleDetailError(failure.message)),
      (article) async {
        final authState = _authBloc.state;
        String targetLang = 'es'; // Default language
        if (authState is AuthAuthenticated) {
          targetLang = authState.user.language;
        }

        // Translate the article if the language differs
        final finalArticle =
            await _translationService.translateArticle(article, targetLang);

        emit(ArticleDetailLoaded(finalArticle));
      },
    );
  }
}
