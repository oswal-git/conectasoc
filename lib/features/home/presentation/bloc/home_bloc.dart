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
  }

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
      // Carga de artículos y categorías siempre se hace al inicio.
      final articlesResult = await getArticlesUseCase(
          user: event.user, isEditMode: event.isEditMode, lastDocument: null);
      final categoriesResult = await getCategoriesUseCase();

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

      List<ArticleEntity> articlesToDisplay = _originalArticles;
      List<CategoryEntity> categoriesToDisplay = categoriesOriginal;

      // Obtener el idioma del usuario
      final authState = authBloc.state;
      String targetLang = 'es'; // Idioma por defecto
      if (authState is AuthAuthenticated) {
        targetLang = authState.user.language;
      }

      // Si no estamos en modo edición, traducir los artículos
      if (!event.isEditMode) {
        // Usamos Future.wait para traducir todos los artículos en paralelo
        articlesToDisplay = await Future.wait(_originalArticles.map((article) =>
            translationService.translateArticle(article, targetLang)));

        // Traducir categorías en paralelo
        categoriesToDisplay = await translationService.translateCategories(
            categoriesOriginal, targetLang);
      }

      emit(HomeLoaded(
        // 'allArticles' ahora contiene la lista para mostrar (traducida o no)
        allArticles: articlesToDisplay,
        // 'filteredArticles' se inicializa con la misma lista
        filteredArticles: articlesToDisplay,
        categories: categoriesToDisplay,
        searchTerm: '', // Initialize search term
        isEditMode: event.isEditMode,
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
    if (state is! HomeLoaded) return;
    final currentState = state as HomeLoaded;
    final newEditMode = !currentState.isEditMode;

    // Emitimos un estado de carga parcial para dar feedback al usuario
    emit(currentState.copyWith(isLoading: true));

    final authState = authBloc.state;
    final user =
        event.user ?? (authState is AuthAuthenticated ? authState.user : null);

    debugPrint(
        'DEBUG: ToggleEditMode - Calling getArticlesUseCase for newEditMode=$newEditMode with user=${user?.uid}');
    // Volvemos a cargar los artículos desde el principio con el nuevo modo de edición
    final articlesResult =
        await getArticlesUseCase(user: user, isEditMode: newEditMode);

    await articlesResult.fold(
      (failure) async => emit(HomeError(failure.message)),
      (articlesData) async {
        _originalArticles = articlesData.item1;
        final lastDocument = articlesData.item2;
        List<ArticleEntity> articlesToDisplay = _originalArticles;

        // Si salimos del modo edición, traducimos los artículos
        if (!newEditMode && user != null) {
          articlesToDisplay = await Future.wait(_originalArticles
              .map((article) =>
                  translationService.translateArticle(article, user.language))
              .toList());
        }

        debugPrint(
            'DEBUG: ToggleEditMode success. Articles fetched: ${articlesData.item1.length}');

        final newState = currentState.copyWith(
          isEditMode: newEditMode,
          allArticles: articlesToDisplay,
          filteredArticles: articlesToDisplay, // Sincronizamos inmediatamente
          lastDocument: lastDocument,
          hasMore: articlesData.item1.length == 20,
          isLoading: false,
          // Al cambiar de modo, limpiamos los filtros para asegurar visibilidad
          searchTerm: '',
          clearSelectedCategory: true,
          clearSelectedSubcategory: true,
        );

        // Volvemos a aplicar filtros por si acaso (aunque los acabamos de limpiar)
        _applyFilters(emit, newState);
      },
    );
  }

  void _onSearchQueryChanged(
      SearchQueryChanged event, Emitter<HomeState> emit) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded; // Update searchTerm in state
      emit(currentState.copyWith(searchTerm: event.query));
      _applyFilters(emit, currentState.copyWith(searchTerm: event.query));
    }
  }

  Future<void> _onCategorySelected(
      CategorySelected event, Emitter<HomeState> emit) async {
    if (state is! HomeLoaded) return;
    final currentState = state as HomeLoaded;

    final result = await getSubcategoriesUseCase(event.category.id);

    result.fold(
      (failure) => emit(HomeError(failure.message)),
      (subcategories) {
        final newState = currentState.copyWith(
          selectedCategory: event.category,
          subcategories: subcategories,
          clearSelectedSubcategory: true, // Limpiar subcategoría explícitamente
        );
        _applyFilters(emit, newState);
      },
    );
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
