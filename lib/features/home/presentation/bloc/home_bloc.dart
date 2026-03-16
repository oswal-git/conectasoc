import 'dart:convert';
import 'package:conectasoc/features/associations/domain/entities/entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

import 'package:conectasoc/core/services/translation_service.dart';
import 'package:conectasoc/features/articles/domain/entities/entities.dart';
import 'package:conectasoc/features/articles/domain/usecases/usecases.dart';
import 'package:conectasoc/features/associations/domain/usecases/usecases.dart';
import 'package:conectasoc/features/auth/presentation/bloc/bloc.dart';
import 'package:conectasoc/features/home/presentation/bloc/bloc.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetArticlesUseCase getArticlesUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;
  final GetSubcategoriesUseCase getSubcategoriesUseCase;
  final GetAllAssociationsUseCase getAllAssociationsUseCase;
  final TranslationService translationService;
  final AuthBloc authBloc;

  // Lista interna para mantener los artículos originales sin traducir
  List<ArticleEntity> _originalArticles = [];

  HomeBloc({
    required this.getArticlesUseCase,
    required this.getCategoriesUseCase,
    required this.getSubcategoriesUseCase,
    required this.getAllAssociationsUseCase,
    required this.translationService,
    required this.authBloc,
  }) : super(HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<ToggleEditMode>(_onToggleEditMode);
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<CategorySelected>(_onCategorySelected);
    on<SubcategorySelected>(_onSubcategorySelected);
    on<ClearCategoryFilter>(_onClearCategoryFilter);
    on<LoadMoreArticles>(_onLoadMoreArticles);
    on<ToggleSearch>(_onToggleSearch);
    on<ToggleFilter>(_onToggleFilter);
  }

// ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _targetLang(AuthState authState) {
    if (authState is AuthAuthenticated) return authState.user.language;
    if (authState is AuthLocalUser) return authState.localUser.language;
    if (authState is AuthUnauthenticated && authState.language != null) {
      return authState.language!;
    }
    return 'es';
  }

  /// Marks every article in the list as "pending translation" (isTranslated: false).
  List<ArticleEntity> _markPending(List<ArticleEntity> articles) =>
      articles.map((a) => a.copyWith(isTranslated: false)).toList();

  // ---------------------------------------------------------------------------
  // LoadHomeData
  // ---------------------------------------------------------------------------

  Future<void> _onLoadHomeData(
    LoadHomeData event,
    Emitter<HomeState> emit,
  ) async {
    final currentState = state;

    // Use a background loading state if we are already loaded (e.g., for pull-to-refresh)
    if (currentState is HomeLoaded) {
      emit(currentState.copyWith(isLoading: true));
    } else {
      emit(HomeLoading()); // Full screen loader for initial load
    }

    try {
      final authState = authBloc.state;
      String? assocId = event.membership?.associationId;
      if (assocId == null) {
        if (authState is AuthAuthenticated) {
          assocId = authState.currentMembership?.associationId;
        } else if (authState is AuthLocalUser) {
          assocId = authState.localUser.associationId;
        }
      }

      // Carga de artículos y categorías siempre se hace al inicio.
      final articlesResult = await getArticlesUseCase(
          user: event.user, isEditMode: event.isEditMode, lastDocument: null);
      final categoriesResult = await getCategoriesUseCase(assocId: assocId);

      // Lógica para recargar las asociaciones solo cuando es necesario.
      final List<AssociationEntity> associations;
      if (event.forceReload || currentState is! HomeLoaded) {
        // Si se fuerza la recarga o no hay estado previo, se obtienen de la BD.
        final associationsResult = await getAllAssociationsUseCase();
        associations =
            associationsResult.fold((failure) => throw failure, (data) => data);
      } else {
        // Si no, se reutilizan las asociaciones del estado anterior.
        associations = currentState.associations;
      }

      final articlesData =
          articlesResult.fold((failure) => throw failure, (data) => data);
      _originalArticles = articlesData.item1;
      final lastDocument = articlesData.item2;

      final categoriesOriginal =
          categoriesResult.fold((failure) => throw failure, (data) => data);

      final targetLang = _targetLang(authState);
      final needsTranslation = !event.isEditMode;

      // ── FIRST EMIT: show articles immediately, marked as pending ──────────
      // In edit mode we show the originals as-is (no translation needed).
      final articlesToDisplay = needsTranslation
          ? _markPending(_originalArticles)
          : _originalArticles;

      // Emitir primero el estado con el contenido original (sin traducir)
      emit(HomeLoaded(
        allArticles: articlesToDisplay,
        filteredArticles: articlesToDisplay,
        categories: categoriesOriginal,
        searchTerm: '', // Initialize search term
        isEditMode: event.isEditMode,
        associations: associations,
        hasMore: articlesData.item1.length == 20, // Assuming a page size of 20
        lastDocument: lastDocument,
      ));

      // ── BACKGROUND TRANSLATION ────────────────────────────────────────────
      if (needsTranslation) {
        // Translate article-by-article and emit each one as it finishes.
        // This way the first translated card appears immediately without
        // waiting for all 20 to be done.
        for (int i = 0; i < _originalArticles.length; i++) {
          if (isClosed) break;
          final translated = await translationService.translateArticle(
              _originalArticles[i], targetLang);

          if (!isClosed && state is HomeLoaded) {
            final latest = state as HomeLoaded;
            final updatedAll = List<ArticleEntity>.from(latest.allArticles)
              ..[i] = translated;
            final newState = latest.copyWith(allArticles: updatedAll);
            _applyFilters(emit, newState);
          }
        }

        // Translate categories after articles
        if (!isClosed && state is HomeLoaded) {
          final translatedCategories = await translationService
              .translateCategories(categoriesOriginal, targetLang);
          if (!isClosed && state is HomeLoaded) {
            _applyFilters(
                emit,
                (state as HomeLoaded)
                    .copyWith(categories: translatedCategories));
          }
        }
      }
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // LoadMoreArticles
  // ---------------------------------------------------------------------------

  Future<void> _onLoadMoreArticles(
    LoadMoreArticles event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeLoaded) return;
    final currentState = state as HomeLoaded;

    // Prevent multiple fetches if we're already loading or have no more data
    if (!currentState.hasMore) return;

    final articlesResult = await getArticlesUseCase(
      user: event.user,
      isEditMode: currentState.isEditMode,
      lastDocument: currentState.lastDocument,
    );

    await articlesResult.fold(
      (failure) async => emit(HomeError(failure.message)),
      (articlesData) async {
        final newArticles = articlesData.item1;
        final lastDocument = articlesData.item2;

        // Append new original articles to the internal list
        _originalArticles.addAll(newArticles);

        // Append new original articles to the existing list for fast UI update
        final needsTranslation = !currentState.isEditMode;
        final pendingNew =
            needsTranslation ? _markPending(newArticles) : newArticles;

        final updatedArticles =
            List<ArticleEntity>.from(currentState.allArticles)
              ..addAll(pendingNew);

        final initialNewState = currentState.copyWith(
          allArticles: updatedArticles,
          hasMore: newArticles.length == 20, // Assuming a page size of 20
          lastDocument: lastDocument,
        );

        _applyFilters(emit, initialNewState);

        // Si no estamos en modo edición, traducimos los nuevos artículos en segundo plano
        if (needsTranslation) {
          final authState = authBloc.state;
          final targetLang = _targetLang(authState);
          final offset =
              updatedArticles.length - newArticles.length; // index of first new
          for (int i = 0; i < newArticles.length; i++) {
            if (isClosed) break;
            final translated = await translationService.translateArticle(
                _originalArticles[offset + i], targetLang);

            if (!isClosed && state is HomeLoaded) {
              final latest = state as HomeLoaded;
              final updatedAll = List<ArticleEntity>.from(latest.allArticles)
                ..[offset + i] = translated;

              _applyFilters(emit, latest.copyWith(allArticles: updatedAll));
            }
          }
        }
      },
    );
  }

  // ---------------------------------------------------------------------------
  // ToggleEditMode
  // ---------------------------------------------------------------------------

  Future<void> _onToggleEditMode(
    ToggleEditMode event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeLoaded) return;
    final currentState = state as HomeLoaded;
    final authState = authBloc.state;
    final newEditMode = !currentState.isEditMode;

    final articlesResult = await getArticlesUseCase(
      user: event.user,
      isEditMode: newEditMode,
      lastDocument: null,
    );

    await articlesResult.fold(
      (failure) async => emit(HomeError(failure.message)),
      (articlesData) async {
        _originalArticles = articlesData.item1;

        final needsTranslation = !newEditMode;
        final articlesToDisplay = needsTranslation
            ? _markPending(_originalArticles)
            : _originalArticles;

        final categoriesOriginal = currentState.categories;

        final initialNewState = currentState.copyWith(
          allArticles: articlesToDisplay,
          isEditMode: newEditMode,
          hasMore: articlesData.item1.length == 20,
          lastDocument: articlesData.item2,
          searchTerm: '',
          clearSelectedCategory: true,
          clearSelectedSubcategory: true,
        );

        _applyFilters(emit, initialNewState);

        if (needsTranslation) {
          final targetLang = _targetLang(authState);

          for (int i = 0; i < _originalArticles.length; i++) {
            if (isClosed) break;
            final translated = await translationService.translateArticle(
                _originalArticles[i], targetLang);

            if (!isClosed && state is HomeLoaded) {
              final latest = state as HomeLoaded;
              final updatedAll = List<ArticleEntity>.from(latest.allArticles)
                ..[i] = translated;
              _applyFilters(emit, latest.copyWith(allArticles: updatedAll));
            }
          }

          if (!isClosed && state is HomeLoaded) {
            final translatedCategories = await translationService
                .translateCategories(categoriesOriginal, targetLang);
            if (!isClosed && state is HomeLoaded) {
              _applyFilters(
                  emit,
                  (state as HomeLoaded)
                      .copyWith(categories: translatedCategories));
            }
          }
        }
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Filters / Search
  // ---------------------------------------------------------------------------

  void _onSearchQueryChanged(
      SearchQueryChanged event, Emitter<HomeState> emit) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded; // Update searchTerm in state
      _applyFilters(emit, currentState.copyWith(searchTerm: event.query));
    }
  }

  Future<void> _onCategorySelected(
      CategorySelected event, Emitter<HomeState> emit) async {
    if (state is! HomeLoaded) return;
    final currentState = state as HomeLoaded;
    final authState = authBloc.state;

    String? assocId;
    if (authState is AuthAuthenticated) {
      assocId = authState.currentMembership?.associationId;
    } else if (authState is AuthLocalUser) {
      assocId = authState.localUser.associationId;
    }

    final result =
        await getSubcategoriesUseCase(event.category.id, assocId: assocId);

    await result.fold(
      (failure) async {
        debugPrint(
            'DEBUG: CategorySelected - Failed to load subcategories: ${failure.message}');
        emit(HomeError(failure.message));
      },
      (subcategories) async {
        debugPrint(
            'DEBUG: CategorySelected - Loaded ${subcategories.length} subcategories');
        List<SubcategoryEntity> subcategoriesToDisplay = subcategories;

        // Si no estamos en modo edición, traducir las subcategorías
        if (!currentState.isEditMode) {
          final targetLang = _targetLang(authState);

          debugPrint(
              'DEBUG: CategorySelected - Translating subcategories to $targetLang');
          subcategoriesToDisplay = await translationService
              .translateSubcategories(subcategories, targetLang);
          debugPrint(
              'DEBUG: CategorySelected - Translation complete. First subcategory: ${subcategoriesToDisplay.isNotEmpty ? subcategoriesToDisplay.first.name : "none"}');
        }

        final newState = currentState.copyWith(
          selectedCategory: event.category,
          subcategories: subcategoriesToDisplay,
          clearSelectedSubcategory: true, // Limpiar subcategoría explícitamente
        );

        debugPrint(
            'DEBUG: CategorySelected - Emitting new state with ${newState.subcategories.length} subcategories');
        _applyFilters(emit, newState);
      },
    );
  }

  void _onSubcategorySelected(
      SubcategorySelected event, Emitter<HomeState> emit) {
    if (state is HomeLoaded) {
      _applyFilters(
          emit,
          (state as HomeLoaded)
              .copyWith(selectedSubcategory: event.subcategory));
    }
  }

  void _onClearCategoryFilter(
      ClearCategoryFilter event, Emitter<HomeState> emit) {
    if (state is HomeLoaded) {
      final newState = (state as HomeLoaded).copyWith(
        subcategories: [],
        clearSelectedCategory: true,
        clearSelectedSubcategory: true,
      );
      _applyFilters(emit, newState);
    }
  }

  // Helper method to apply all active filters
  void _applyFilters(Emitter<HomeState> emit, HomeLoaded currentState) {
    List<ArticleEntity> filtered = List.from(currentState.allArticles);

    // Apply search term filter
    if (currentState.searchTerm.isNotEmpty) {
      final query = currentState.searchTerm.toLowerCase();
      filtered = filtered.where((article) {
        // Render rich text to plain text for search
        final titlePlain = _quillJsonToPlainText(article.title);
        final abstractPlain = _quillJsonToPlainText(article.abstractContent);
        final sectionsPlain = article.sections
            .map((s) => _quillJsonToPlainText(s.richTextContent ?? ''))
            .join(' ');

        return titlePlain.toLowerCase().contains(query) ||
            abstractPlain.toLowerCase().contains(query) ||
            sectionsPlain.toLowerCase().contains(query);
      }).toList();
    }

    // Apply category filter
    if (currentState.selectedCategory != null) {
      filtered = filtered
          .where((article) =>
              article.categoryId == currentState.selectedCategory!.id)
          .toList();
    }

    // Apply subcategory filter
    if (currentState.selectedSubcategory != null) {
      filtered = filtered
          .where((article) =>
              article.subcategoryId == currentState.selectedSubcategory!.id)
          .toList();
    }

    emit(currentState.copyWith(filteredArticles: filtered));
  }

  String _quillJsonToPlainText(String quillJson) {
    if (quillJson.isEmpty) return '';
    try {
      final doc = quill.Document.fromJson(jsonDecode(quillJson));
      return doc.toPlainText().trim();
    } catch (e) {
      return ''; // Handle malformed JSON gracefully
    }
  }

  void _onToggleSearch(ToggleSearch event, Emitter<HomeState> emit) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      emit(currentState.copyWith(showSearch: !currentState.showSearch));
    }
  }

  void _onToggleFilter(ToggleFilter event, Emitter<HomeState> emit) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      emit(currentState.copyWith(showFilter: !currentState.showFilter));
    }
  }
}
