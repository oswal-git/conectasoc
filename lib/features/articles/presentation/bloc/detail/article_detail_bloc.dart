import 'package:conectasoc/features/articles/domain/entities/entities.dart';
import 'package:flutter/foundation.dart';
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
    on<LoadArticleDetail>((event, emit) =>
        _loadArticle(event.articleId, emit, forceRefresh: false));
    on<RefreshArticleDetail>((event, emit) =>
        _loadArticle(event.articleId, emit, forceRefresh: true));
  }

  Future<void> _loadArticle(
    String articleId,
    Emitter<ArticleDetailState> emit, {
    required bool forceRefresh,
  }) async {
    // En refresh, mantener el contenido actual visible mientras recarga.
    if (!forceRefresh || state is! ArticleDetailLoaded) {
      emit(ArticleDetailLoading());
    }

    final result = await _getArticleByIdUseCase(
      articleId,
      forceRefresh: forceRefresh,
    );

    // Use a pattern that allows awaiting the async operations inside.
    await result.fold(
      (failure) async => emit(ArticleDetailError(failure.message)),
      (article) async {
        final authState = _authBloc.state;
        String targetLang = 'es';
        if (authState is AuthAuthenticated) {
          targetLang = authState.user.language;
        } else if (authState is AuthLocalUser) {
          targetLang = authState.localUser.language;
        } else if (authState is AuthUnauthenticated &&
            authState.language != null) {
          targetLang = authState.language!;
        }

        final sameLanguage = article.originalLanguage == targetLang || kIsWeb;

        if (sameLanguage) {
          // No hay nada que traducir — emitir directamente.
          emit(ArticleDetailLoaded(
            article.copyWith(isTranslated: true),
          ));
          return;
        }

        // ── FASE 1: mostrar el artículo original inmediatamente ────────────
        // El usuario ve el contenido sin esperar ninguna traducción.
        emit(ArticleDetailLoaded(
          article.copyWith(isTranslated: false),
          isTranslating: true,
        ));

        try {
          // ── FASE 2a: traducir campos visibles "above the fold" ────────────
          // Título, abstract y metadatos — lo que el usuario ve primero.
          final translatedTitle = await _translationService.translateField(
              article.title, article.originalLanguage, targetLang,
              isQuillJson: true);
          final translatedAbstract = await _translationService.translateField(
              article.abstractContent, article.originalLanguage, targetLang,
              isQuillJson: true);
          final translatedCategory = await _translationService.translateField(
              article.categoryName, article.originalLanguage, targetLang);
          final translatedSubcategory =
              await _translationService.translateField(article.subcategoryName,
                  article.originalLanguage, targetLang);

          if (isClosed) return;

          // Emitir con header traducido, secciones aún en original.
          ArticleEntity current = article.copyWith(
            title: translatedTitle,
            abstractContent: translatedAbstract,
            categoryName: translatedCategory,
            subcategoryName: translatedSubcategory,
            isTranslated: false, // secciones aún pendientes
          );
          emit(ArticleDetailLoaded(current, isTranslating: true));

          // ── FASE 2b: traducir secciones una a una ─────────────────────────
          final translatedSections =
              List<ArticleSection>.from(article.sections);

          for (int i = 0; i < translatedSections.length; i++) {
            if (isClosed) return;
            final section = translatedSections[i];
            if (section.richTextContent != null &&
                section.richTextContent!.isNotEmpty) {
              final translatedContent =
                  await _translationService.translateField(
                      section.richTextContent!,
                      article.originalLanguage,
                      targetLang,
                      isQuillJson: true);
              translatedSections[i] =
                  section.copyWith(richTextContent: translatedContent);

              // Emitir tras cada sección para que aparezca progresivamente.
              current = current.copyWith(
                sections: List.from(translatedSections),
                // Solo marcamos isTranslated: true en la última sección.
                isTranslated: i == article.sections.length - 1,
              );
              emit(ArticleDetailLoaded(
                current,
                isTranslating: i < article.sections.length - 1,
              ));
            }
          }

          // Si no había secciones con texto, marcar como traducido aquí.
          if (!isClosed && state is ArticleDetailLoaded) {
            final s = state as ArticleDetailLoaded;
            if (s.isTranslating) {
              emit(s.copyWith(
                article: s.article.copyWith(isTranslated: true),
                isTranslating: false,
              ));
            }
          }
        } catch (e) {
          // En caso de error mostrar el original — nunca dejar congelado.
          debugPrint('ArticleDetailBloc translation error: $e');
          if (!isClosed) {
            emit(ArticleDetailLoaded(
              article.copyWith(isTranslated: true),
              isTranslating: false,
            ));
          }
        }
      },
    );
  }
}
