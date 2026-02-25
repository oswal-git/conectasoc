import 'package:equatable/equatable.dart';
import 'package:conectasoc/features/articles/domain/entities/entities.dart';
import 'package:conectasoc/features/documents/domain/entities/document_entity.dart';

abstract class DocumentSearchState extends Equatable {
  const DocumentSearchState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial antes de cualquier carga
class DocumentSearchInitial extends DocumentSearchState {
  const DocumentSearchInitial();
}

/// Cargando la lista de documentos
class DocumentSearchLoading extends DocumentSearchState {
  const DocumentSearchLoading();
}

/// Lista cargada y lista para mostrar/filtrar
class DocumentSearchLoaded extends DocumentSearchState {
  /// Todos los documentos disponibles para la asociación
  final List<DocumentEntity> allDocuments;

  /// Documentos filtrados por query + categoría + subcategoría
  final List<DocumentEntity> filteredDocuments;

  /// Texto de búsqueda actual
  final String query;

  /// Categoría seleccionada como filtro (null = todas)
  final String? selectedCategoryId;

  /// Subcategoría seleccionada como filtro (null = todas)
  final String? selectedSubcategoryId;

  /// Categorías disponibles para los filtros
  final List<CategoryEntity> categories;

  /// Subcategorías disponibles según la categoría seleccionada
  final List<SubcategoryEntity> subcategories;

  const DocumentSearchLoaded({
    required this.allDocuments,
    required this.filteredDocuments,
    required this.query,
    required this.categories,
    required this.subcategories,
    this.selectedCategoryId,
    this.selectedSubcategoryId,
  });

  DocumentSearchLoaded copyWith({
    List<DocumentEntity>? allDocuments,
    List<DocumentEntity>? filteredDocuments,
    String? query,
    String? selectedCategoryId,
    String? selectedSubcategoryId,
    List<CategoryEntity>? categories,
    List<SubcategoryEntity>? subcategories,
    bool clearCategory = false,
    bool clearSubcategory = false,
  }) {
    return DocumentSearchLoaded(
      allDocuments: allDocuments ?? this.allDocuments,
      filteredDocuments: filteredDocuments ?? this.filteredDocuments,
      query: query ?? this.query,
      categories: categories ?? this.categories,
      subcategories: subcategories ?? this.subcategories,
      selectedCategoryId: clearCategory
          ? null
          : (selectedCategoryId ?? this.selectedCategoryId),
      selectedSubcategoryId: clearSubcategory
          ? null
          : (selectedSubcategoryId ?? this.selectedSubcategoryId),
    );
  }

  bool get hasActiveFilters =>
      query.isNotEmpty ||
      selectedCategoryId != null ||
      selectedSubcategoryId != null;

  @override
  List<Object?> get props => [
        allDocuments,
        filteredDocuments,
        query,
        selectedCategoryId,
        selectedSubcategoryId,
        categories,
        subcategories,
      ];
}

/// Error al cargar documentos
class DocumentSearchError extends DocumentSearchState {
  final String message;

  const DocumentSearchError(this.message);

  @override
  List<Object?> get props => [message];
}
