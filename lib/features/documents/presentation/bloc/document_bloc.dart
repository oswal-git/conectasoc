import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:conectasoc/features/articles/domain/usecases/get_categories_usecase.dart';
import 'package:conectasoc/features/articles/domain/usecases/get_subcategories_usecase.dart';
import 'package:conectasoc/features/documents/domain/entities/document_entity.dart';
import 'package:conectasoc/features/documents/domain/usecases/usecases.dart';
import 'package:conectasoc/features/documents/presentation/bloc/document_event_bloc.dart';
import 'package:conectasoc/features/documents/presentation/bloc/document_state_bloc.dart';

/// BLoC principal de documentos.
/// Gestiona la lista paginada de documentos de una asociación
/// con filtros de categoría / subcategoría y búsqueda.
class DocumentBloc extends Bloc<DocumentEvent, DocumentState> {
  final GetDocumentsByAssociationUseCase getDocumentsByAssociationUseCase;
  final SearchDocumentsUseCase searchDocumentsUseCase;
  final DeleteDocumentUseCase deleteDocumentUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;
  final GetSubcategoriesUseCase getSubcategoriesUseCase;

  Timer? _debounceTimer;
  String? _associationId;

  DocumentBloc({
    required this.getDocumentsByAssociationUseCase,
    required this.searchDocumentsUseCase,
    required this.deleteDocumentUseCase,
    required this.getCategoriesUseCase,
    required this.getSubcategoriesUseCase,
  }) : super(const DocumentInitial()) {
    on<LoadDocuments>(_onLoadDocuments);
    on<DocumentQueryChanged>(_onQueryChanged);
    on<DocumentCategoryFilterChanged>(_onCategoryFilterChanged);
    on<DocumentSubcategoryFilterChanged>(_onSubcategoryFilterChanged);
    on<DocumentFiltersCleared>(_onFiltersCleared);
    on<DeleteDocument>(_onDeleteDocument);
    on<RefreshDocuments>(_onRefreshDocuments);
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }

  // ─────────────────────────────────────────────
  // Handlers
  // ─────────────────────────────────────────────

  Future<void> _onLoadDocuments(
    LoadDocuments event,
    Emitter<DocumentState> emit,
  ) async {
    _associationId = event.associationId;
    emit(const DocumentLoading());

    // Llamadas separadas para preservar los tipos genéricos de Dartz.
    // Future.wait mezcla los tipos y provoca List<Equatable> en getOrElse.
    final categoriesResult = await getCategoriesUseCase();
    final documentsResult = await getDocumentsByAssociationUseCase(
      associationId: _associationId,
    );

    if (categoriesResult.isLeft()) {
      emit(DocumentError(categoriesResult.fold((f) => f.message, (_) => '')));
      return;
    }
    if (documentsResult.isLeft()) {
      emit(DocumentError(documentsResult.fold((f) => f.message, (_) => '')));
      return;
    }

    final categories = categoriesResult.getOrElse(() => []);
    final documents = documentsResult.getOrElse(() => []);

    emit(DocumentLoaded(
      allDocuments: documents,
      filteredDocuments: documents,
      query: '',
      categories: categories,
      subcategories: const [],
    ));
  }

  void _onQueryChanged(
    DocumentQueryChanged event,
    Emitter<DocumentState> emit,
  ) {
    if (state is! DocumentLoaded) return;
    final current = state as DocumentLoaded;

    emit(current.copyWith(
      query: event.query,
      filteredDocuments: _applyFilters(
        documents: current.allDocuments,
        query: event.query,
        categoryId: current.selectedCategoryId,
        subcategoryId: current.selectedSubcategoryId,
      ),
    ));
  }

  Future<void> _onCategoryFilterChanged(
    DocumentCategoryFilterChanged event,
    Emitter<DocumentState> emit,
  ) async {
    if (state is! DocumentLoaded) return;
    final current = state as DocumentLoaded;

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

    final subcatResult = await getSubcategoriesUseCase(event.categoryId!);

    subcatResult.fold(
      (_) {
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

  void _onSubcategoryFilterChanged(
    DocumentSubcategoryFilterChanged event,
    Emitter<DocumentState> emit,
  ) {
    if (state is! DocumentLoaded) return;
    final current = state as DocumentLoaded;

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
    DocumentFiltersCleared event,
    Emitter<DocumentState> emit,
  ) {
    if (state is! DocumentLoaded) return;
    final current = state as DocumentLoaded;

    emit(current.copyWith(
      query: '',
      clearCategory: true,
      clearSubcategory: true,
      subcategories: const [],
      filteredDocuments: current.allDocuments,
    ));
  }

  Future<void> _onDeleteDocument(
    DeleteDocument event,
    Emitter<DocumentState> emit,
  ) async {
    if (state is! DocumentLoaded) return;
    final current = state as DocumentLoaded;

    final result = await deleteDocumentUseCase(event.documentId);

    result.fold(
      (failure) => emit(current.copyWith(errorMessage: failure.message)),
      (_) {
        final updatedAll = current.allDocuments
            .where((d) => d.id != event.documentId)
            .toList();
        final updatedFiltered = current.filteredDocuments
            .where((d) => d.id != event.documentId)
            .toList();
        emit(current.copyWith(
          allDocuments: updatedAll,
          filteredDocuments: updatedFiltered,
        ));
      },
    );
  }

  Future<void> _onRefreshDocuments(
    RefreshDocuments event,
    Emitter<DocumentState> emit,
  ) async {
    if (state is! DocumentLoaded) return;
    final current = state as DocumentLoaded;

    final result = await getDocumentsByAssociationUseCase(
      associationId: _associationId,
      categoryId: current.selectedCategoryId,
      subcategoryId: current.selectedSubcategoryId,
    );

    result.fold(
      (failure) => emit(DocumentError(failure.message)),
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
      final matchesQuery = query.isEmpty ||
          doc.descDoc.toLowerCase().contains(query.toLowerCase()) ||
          doc.fileName.toLowerCase().contains(query.toLowerCase());

      final matchesCategory =
          categoryId == null || doc.categoryId == categoryId;

      final matchesSubcategory =
          subcategoryId == null || doc.subcategoryId == subcategoryId;

      return matchesQuery && matchesCategory && matchesSubcategory;
    }).toList();
  }
}
