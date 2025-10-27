import 'dart:convert';
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
  }

  Future<void> _onLoadHomeData(
    LoadHomeData event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());

    try {
      final isEditMode =
          state is HomeLoaded && (state as HomeLoaded).isEditMode;

      // For a fresh load, we don't pass a lastDocument
      final articlesResult = await getArticlesUseCase(
          user: event.user, isEditMode: isEditMode, lastDocument: null);
      final categoriesResult = await getCategoriesUseCase();
      final associationsResult = await getAllAssociationsUseCase();

      // Extraer valores o lanzar error
      final articlesData =
          articlesResult.fold((failure) => throw failure, (data) => data);
      _originalArticles = articlesData.item1;
      final lastDocument = articlesData.item2;

      final categories =
          categoriesResult.fold((failure) => throw failure, (data) => data);
      final associations =
          associationsResult.fold((failure) => throw failure, (data) => data);

      List<ArticleEntity> articlesToDisplay = _originalArticles;

      // Si no estamos en modo edición, traducir los artículos
      if (!isEditMode) {
        final authState = authBloc.state;
        String targetLang = 'es'; // Idioma por defecto
        if (authState is AuthAuthenticated) {
          targetLang = authState.user.language;
        }

        // Usamos Future.wait para traducir todos los artículos en paralelo
        articlesToDisplay = await Future.wait(_originalArticles.map((article) =>
            translationService.translateArticle(article, targetLang)));
      }

      emit(HomeLoaded(
        // 'allArticles' ahora contiene la lista para mostrar (traducida o no)
        allArticles: articlesToDisplay,
        // 'filteredArticles' se inicializa con la misma lista
        filteredArticles: articlesToDisplay,
        categories: categories,
        searchTerm: '', // Initialize search term
        associations: associations,
        hasMore: articlesData.item1.length == 20, // Assuming a page size of 20
        lastDocument: lastDocument,
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

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

    articlesResult.fold(
      (failure) => emit(HomeError(failure.message)),
      (articlesData) {
        final newArticles = articlesData.item1;
        final lastDocument = articlesData.item2;

        // Append new articles to the existing list
        final updatedArticles =
            List<ArticleEntity>.from(currentState.allArticles)
              ..addAll(newArticles);

        emit(currentState.copyWith(
          allArticles: updatedArticles,
          filteredArticles: updatedArticles, // Update filtered list as well
          hasMore: newArticles.length == 20, // Assuming a page size of 20
          lastDocument: lastDocument,
        ));
      },
    );
  }

  Future<void> _onToggleEditMode(
      ToggleEditMode event, Emitter<HomeState> emit) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      final newEditMode = !currentState.isEditMode;

      List<ArticleEntity> articlesToDisplay;

      final authState = authBloc.state;
      if (newEditMode) {
        // Al entrar en modo edición, mostramos los artículos originales.
        articlesToDisplay = _originalArticles;
      } else {
        // Al salir del modo edición, traducimos los artículos si es necesario.
        String targetLang = 'es'; // Idioma por defecto
        if (authState is AuthAuthenticated) {
          targetLang = authState.user.language;
        }
        articlesToDisplay = await Future.wait(_originalArticles.map((article) =>
            translationService.translateArticle(article, targetLang)));
      }

      // Aplicamos los filtros existentes a la nueva lista de artículos.
      final newState = currentState.copyWith(
        isEditMode: newEditMode,
        allArticles: articlesToDisplay, // Actualizamos la lista base
      );

      _applyFilters(emit, newState);
    }
  }

  void _onSearchQueryChanged(
      SearchQueryChanged event, Emitter<HomeState> emit) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded; // Update searchTerm in state
      emit(currentState.copyWith(searchTerm: event.query));
      _applyFilters(emit, currentState.copyWith(searchTerm: event.query));
    }
  }

  void _onCategorySelected(CategorySelected event, Emitter<HomeState> emit) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      // Load subcategories for the selected category
      getSubcategoriesUseCase(event.category.id).then((result) {
        result.fold(
          (failure) => emit(HomeError(failure.message)),
          (subcategories) {
            final newState = currentState.copyWith(
              selectedCategory: event.category,
              subcategories: subcategories,
              selectedSubcategory: null, // Limpiar subcategoría
            );
            _applyFilters(emit, newState);
          },
        );
      });
    }
  }

  void _onSubcategorySelected(
      SubcategorySelected event, Emitter<HomeState> emit) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded; // Update subcategory in state
      final newState = currentState.copyWith(
        selectedSubcategory: event.subcategory,
      );
      _applyFilters(emit, newState);
    }
  }

  void _onClearCategoryFilter(
      ClearCategoryFilter event, Emitter<HomeState> emit) {
    if (state is HomeLoaded) {
      final currentState =
          state as HomeLoaded; // Clear all category/subcategory filters
      final newState = currentState.copyWith(
        subcategories: [], // Clear subcategories
        selectedCategory: null,
        selectedSubcategory: null,
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

  // Helper to convert Quill JSON to plain text for search
  String _quillJsonToPlainText(String quillJson) {
    if (quillJson.isEmpty) return '';
    try {
      final doc = quill.Document.fromJson(jsonDecode(quillJson));
      return doc.toPlainText().trim();
    } catch (e) {
      return ''; // Handle malformed JSON gracefully
    }
  }
}
