import 'package:dartz/dartz.dart';
import 'package:conectasoc/core/errors/failures.dart';
import 'package:conectasoc/features/documents/domain/entities/document_entity.dart';

/// Repository interface for document operations
abstract class DocumentRepository {
  /// Create a new document
  Future<Either<Failure, DocumentEntity>> createDocument(
    DocumentEntity document,
  );

  /// Get document by ID
  Future<Either<Failure, DocumentEntity>> getDocumentById(String documentId);

  /// Get all documents by association
  /// If associationId is null, get all documents (superadmin)
  Future<Either<Failure, List<DocumentEntity>>> getDocumentsByAssociation({
    String? associationId,
    String? categoryId,
    String? subcategoryId,
    required bool isSuperAdmin,
    String? userAssociationId,
    String? userRole,
  });

  /// Search documents by query
  Future<Either<Failure, List<DocumentEntity>>> searchDocuments({
    required String query,
    String? associationId,
    String? categoryId,
    String? subcategoryId,
    required bool isSuperAdmin,
    String? userAssociationId,
    String? userRole,
  });

  /// Update document
  Future<Either<Failure, DocumentEntity>> updateDocument(
    DocumentEntity document,
  );

  /// Delete document
  Future<Either<Failure, void>> deleteDocument(String documentId);

  /// Get documents by category
  Future<Either<Failure, List<DocumentEntity>>> getDocumentsByCategory({
    required String categoryId,
    String? associationId,
  });

  /// Get documents by subcategory
  Future<Either<Failure, List<DocumentEntity>>> getDocumentsBySubcategory({
    required String subcategoryId,
    String? associationId,
  });

  /// Comprueba si el documento está referenciado en algún artículo
  /// (campo raíz documentLink o en alguna sección).
  /// Devuelve true si está enlazado, false si no lo está.
  Future<Either<Failure, bool>> isDocumentLinked(String documentId);
}
