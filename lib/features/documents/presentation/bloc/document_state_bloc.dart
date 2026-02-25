import 'package:equatable/equatable.dart';
import 'package:conectasoc/features/articles/domain/entities/entities.dart';
import 'package:conectasoc/features/documents/domain/entities/document_entity.dart';

abstract class DocumentState extends Equatable {
  const DocumentState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class DocumentInitial extends DocumentState {
  const DocumentInitial();
}

/// Cargando documentos
class DocumentLoading extends DocumentState {
  const DocumentLoading();
}

/// Documentos cargados correctamente
class DocumentLoaded extends DocumentState {
  final List<DocumentEntity> allDocuments;
  final List<DocumentEntity> filteredDocuments;
  final String query;
  final String? selectedCategoryId;
  final String? selectedSubcategoryId;
  final List<CategoryEntity> categories;
  final List<SubcategoryEntity> subcategories;

  /// Mensaje de error no fatal (p.ej. fallo al borrar)
  final String? errorMessage;

  const DocumentLoaded({
    required this.allDocuments,
    required this.filteredDocuments,
    required this.query,
    required this.categories,
    required this.subcategories,
    this.selectedCategoryId,
    this.selectedSubcategoryId,
    this.errorMessage,
  });

  DocumentLoaded copyWith({
    List<DocumentEntity>? allDocuments,
    List<DocumentEntity>? filteredDocuments,
    String? query,
    String? selectedCategoryId,
    String? selectedSubcategoryId,
    List<CategoryEntity>? categories,
    List<SubcategoryEntity>? subcategories,
    String? errorMessage,
    bool clearCategory = false,
    bool clearSubcategory = false,
    bool clearError = false,
  }) {
    return DocumentLoaded(
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
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
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
        errorMessage,
      ];
}

/// Error al cargar documentos
class DocumentError extends DocumentState {
  final String message;

  const DocumentError(this.message);

  @override
  List<Object?> get props => [message];
}
