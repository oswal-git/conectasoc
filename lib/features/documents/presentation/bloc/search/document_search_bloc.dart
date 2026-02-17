import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:conectasoc/features/articles/domain/usecases/get_categories_usecase.dart';
import 'package:conectasoc/features/articles/domain/usecases/get_subcategories_usecase.dart';
import 'package:conectasoc/features/documents/domain/entities/document_entity.dart';
import 'package:conectasoc/features/documents/domain/usecases/usecases.dart';
import 'package:conectasoc/features/documents/presentation/bloc/search/document_search_event_bloc.dart';
import 'package:conectasoc/features/documents/presentation/bloc/search/document_search_state_bloc.dart';

class DocumentSearchBloc
    extends Bloc<DocumentSearchEvent, DocumentSearchState> {
  final GetDocumentsByAssociationUseCase getDocumentsByAssociationUseCase;
  final SearchDocumentsUseCase searchDocumentsUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;
  final GetSubcategoriesUseCase getSubcategoriesUseCase;

  // Para no lanzar búsqueda en cada tecla
  Timer? _debounceTimer;

  // Guardamos el associationId para reutilizarlo en refrescos y filtros
  String? _associationId;

  DocumentSearchBloc({
    required this.getDocumentsByAssociationUseCase,
    required this.searchDocumentsUseCase,
    required this.getCategoriesUseCase,
    required this.getSubcategoriesUseCase,
  }) : super(const DocumentSearchInitial()) {
    on<InitializeDocumentSearch>(_onInitialize);
    on<DocumentSearchQueryChanged>(_onQueryChanged);
    on<DocumentSearchCategoryChanged>(_onCategoryChanged);
    on<DocumentSearchSubcategoryChanged>(_onSubcategoryChanged);
    on<DocumentSearchFiltersCleared>(_onFiltersCleared);
    on<DocumentSearchRefreshed>(_onRefreshed);
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }

  // ─────────────────────────────────────────────
  // Handlers
  // ─────────────────────────────────────────────

  Future<void> _onInitialize(
    InitializeDocumentSearch event,
    Emitter<DocumentSearchState> emit,
  ) async {
    _associationId = event.associationId;
    emit(const DocumentSearchLoading());

    // Llamadas separadas para preservar tipos genéricos de Dartz.
    // Future.wait mezcla tipos y provoca List<Equatable> en getOrElse.
    final categoriesResult = await getCategoriesUseCase();
    final documentsResult = await getDocumentsByAssociationUseCase(
      associationId: _associationId,
    );

    if (categoriesResult.isLeft()) {
      emit(DocumentSearchError(
          categoriesResult.fold((f) => f.message, (_) => '')));
      return;
    }
    if (documentsResult.isLeft()) {
      emit(DocumentSearchError(
          documentsResult.fold((f) => f.message, (_) => '')));
      return;
    }

    final categories = categoriesResult.getOrElse(() => []);
    final documents = documentsResult.getOrElse(() => []);

    emit(DocumentSearchLoaded(
      allDocuments: documents,
      filteredDocuments: documents,
      query: '',
      categories: categories,
      subcategories: const [],
    ));
  }

  void _onQueryChanged(
    DocumentSearchQueryChanged event,
    Emitter<DocumentSearchState> emit,
  ) {
    if (state is! DocumentSearchLoaded) return;
    final current = state as DocumentSearchLoaded;

    // Actualizar query inmediatamente para que el campo de texto responda
    emit(current.copyWith(
      query: event.query,
      filteredDocuments: _applyFilters(
        documents: current.allDocuments,
        query: event.query,
        categoryId: current.selectedCategoryId,
        subcategoryId: current.selectedSubcategoryId,
      ),
    ));

    // Debounce para búsqueda remota (500ms)
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (event.query.isNotEmpty) {
        add(DocumentSearchQueryChanged(event.query)); // re-dispara con debounce
      }
    });
  }

  Future<void> _onCategoryChanged(
    DocumentSearchCategoryChanged event,
    Emitter<DocumentSearchState> emit,
  ) async {
    if (state is! DocumentSearchLoaded) return;
    final current = state as DocumentSearchLoaded;

    // Si se deselecciona la categoría, limpiamos subcategoría también
    if (event.categoryId == null) {
      emit(current.copyWith(
        clearCategory: true,
        clearSubcategory: true,
        subcategories: const [],
        filteredDocuments: _applyFilters(
          documents: current.allDocuments,
          query: current.query,
          categoryId: null,
          subcategoryId: null,
        ),
      ));
      return;
    }

    // Cargar subcategorías de la categoría seleccionada
    final subcatResult = await getSubcategoriesUseCase(event.categoryId!);

    subcatResult.fold(
      (failure) {
        // Aplicar filtro sin subcategorías si falla
        emit(current.copyWith(
          selectedCategoryId: event.categoryId,
          clearSubcategory: true,
          subcategories: const [],
          filteredDocuments: _applyFilters(
            documents: current.allDocuments,
            query: current.query,
            categoryId: event.categoryId,
            subcategoryId: null,
          ),
        ));
      },
      (subcategories) {
        emit(current.copyWith(
          selectedCategoryId: event.categoryId,
          clearSubcategory: true,
          subcategories: subcategories,
          filteredDocuments: _applyFilters(
            documents: current.allDocuments,
            query: current.query,
            categoryId: event.categoryId,
            subcategoryId: null,
          ),
        ));
      },
    );
  }

  void _onSubcategoryChanged(
    DocumentSearchSubcategoryChanged event,
    Emitter<DocumentSearchState> emit,
  ) {
    if (state is! DocumentSearchLoaded) return;
    final current = state as DocumentSearchLoaded;

    if (event.subcategoryId == null) {
      emit(current.copyWith(
        clearSubcategory: true,
        filteredDocuments: _applyFilters(
          documents: current.allDocuments,
          query: current.query,
          categoryId: current.selectedCategoryId,
          subcategoryId: null,
        ),
      ));
      return;
    }

    emit(current.copyWith(
      selectedSubcategoryId: event.subcategoryId,
      filteredDocuments: _applyFilters(
        documents: current.allDocuments,
        query: current.query,
        categoryId: current.selectedCategoryId,
        subcategoryId: event.subcategoryId,
      ),
    ));
  }

  void _onFiltersCleared(
    DocumentSearchFiltersCleared event,
    Emitter<DocumentSearchState> emit,
  ) {
    if (state is! DocumentSearchLoaded) return;
    final current = state as DocumentSearchLoaded;

    emit(current.copyWith(
      query: '',
      clearCategory: true,
      clearSubcategory: true,
      subcategories: const [],
      filteredDocuments: current.allDocuments,
    ));
  }

  Future<void> _onRefreshed(
    DocumentSearchRefreshed event,
    Emitter<DocumentSearchState> emit,
  ) async {
    if (state is! DocumentSearchLoaded) return;
    final current = state as DocumentSearchLoaded;

    final result = await getDocumentsByAssociationUseCase(
      associationId: _associationId,
      categoryId: current.selectedCategoryId,
      subcategoryId: current.selectedSubcategoryId,
    );

    result.fold(
      (failure) => emit(DocumentSearchError(failure.message)),
      (documents) => emit(current.copyWith(
        allDocuments: documents,
        filteredDocuments: _applyFilters(
          documents: documents,
          query: current.query,
          categoryId: current.selectedCategoryId,
          subcategoryId: current.selectedSubcategoryId,
        ),
      )),
    );
  }

  // ─────────────────────────────────────────────
  // Helper de filtrado local
  // ─────────────────────────────────────────────

  List<DocumentEntity> _applyFilters({
    required List<DocumentEntity> documents,
    required String query,
    required String? categoryId,
    required String? subcategoryId,
  }) {
    return documents.where((doc) {
      // Filtro por texto (descripción o nombre de archivo)
      final matchesQuery = query.isEmpty ||
          doc.descDoc.toLowerCase().contains(query.toLowerCase()) ||
          doc.fileName.toLowerCase().contains(query.toLowerCase());

      // Filtro por categoría
      final matchesCategory =
          categoryId == null || doc.categoryId == categoryId;

      // Filtro por subcategoría
      final matchesSubcategory =
          subcategoryId == null || doc.subcategoryId == subcategoryId;

      return matchesQuery && matchesCategory && matchesSubcategory;
    }).toList();
  }
}
