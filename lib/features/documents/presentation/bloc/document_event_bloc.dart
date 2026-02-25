import 'package:equatable/equatable.dart';

abstract class DocumentEvent extends Equatable {
  const DocumentEvent();

  @override
  List<Object?> get props => [];
}

/// Carga inicial de documentos para una asociación
class LoadDocuments extends DocumentEvent {
  final String? associationId; // null = superadmin (ve todos)
  final bool isSuperAdmin;
  final String? userAssociationId;
  final String? userRole;

  const LoadDocuments({
    this.associationId,
    this.isSuperAdmin = false,
    this.userAssociationId,
    this.userRole,
  });

  @override
  List<Object?> get props =>
      [associationId, isSuperAdmin, userAssociationId, userRole];
}

/// Cambio en el campo de búsqueda
class DocumentQueryChanged extends DocumentEvent {
  final String query;

  const DocumentQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

/// Cambio en el filtro de categoría
class DocumentCategoryFilterChanged extends DocumentEvent {
  final String? categoryId; // null = todas

  const DocumentCategoryFilterChanged(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

/// Cambio en el filtro de subcategoría
class DocumentSubcategoryFilterChanged extends DocumentEvent {
  final String? subcategoryId; // null = todas

  const DocumentSubcategoryFilterChanged(this.subcategoryId);

  @override
  List<Object?> get props => [subcategoryId];
}

/// Limpiar todos los filtros
class DocumentFiltersCleared extends DocumentEvent {
  const DocumentFiltersCleared();
}

/// Eliminar un documento
class DeleteDocument extends DocumentEvent {
  final String documentId;

  const DeleteDocument(this.documentId);

  @override
  List<Object?> get props => [documentId];
}

/// Recargar la lista
class RefreshDocuments extends DocumentEvent {
  const RefreshDocuments();
}
