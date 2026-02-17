import 'package:equatable/equatable.dart';

abstract class DocumentSearchEvent extends Equatable {
  const DocumentSearchEvent();

  @override
  List<Object?> get props => [];
}

/// Carga inicial: categorías + documentos de la asociación
class InitializeDocumentSearch extends DocumentSearchEvent {
  final String? associationId; // null = superadmin (ve todos)

  const InitializeDocumentSearch({this.associationId});

  @override
  List<Object?> get props => [associationId];
}

/// El usuario escribe en el campo de búsqueda
class DocumentSearchQueryChanged extends DocumentSearchEvent {
  final String query;

  const DocumentSearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

/// El usuario selecciona una categoría en el filtro
class DocumentSearchCategoryChanged extends DocumentSearchEvent {
  final String? categoryId; // null = todas las categorías

  const DocumentSearchCategoryChanged(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

/// El usuario selecciona una subcategoría en el filtro
class DocumentSearchSubcategoryChanged extends DocumentSearchEvent {
  final String? subcategoryId; // null = todas las subcategorías

  const DocumentSearchSubcategoryChanged(this.subcategoryId);

  @override
  List<Object?> get props => [subcategoryId];
}

/// El usuario limpia todos los filtros
class DocumentSearchFiltersCleared extends DocumentSearchEvent {
  const DocumentSearchFiltersCleared();
}

/// Recargar resultados (pull-to-refresh)
class DocumentSearchRefreshed extends DocumentSearchEvent {
  const DocumentSearchRefreshed();
}
