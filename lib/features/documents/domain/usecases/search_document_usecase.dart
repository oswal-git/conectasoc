import 'package:dartz/dartz.dart';
import 'package:conectasoc/core/errors/failures.dart';
import 'package:conectasoc/features/documents/domain/entities/document_entity.dart';
import 'package:conectasoc/features/documents/domain/repositories/document_repository.dart';

/// Use case for searching documents
class SearchDocumentsUseCase {
  final DocumentRepository repository;

  SearchDocumentsUseCase(this.repository);

  Future<Either<Failure, List<DocumentEntity>>> call({
    required String query,
    String? associationId,
    String? categoryId,
    String? subcategoryId,
  }) async {
    return await repository.searchDocuments(
      query: query,
      associationId: associationId,
      categoryId: categoryId,
      subcategoryId: subcategoryId,
    );
  }
}
