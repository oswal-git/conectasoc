import 'package:dartz/dartz.dart';
import 'package:conectasoc/core/errors/failures.dart';
import 'package:conectasoc/features/documents/domain/entities/document_entity.dart';
import 'package:conectasoc/features/documents/domain/repositories/document_repository.dart';

/// Use case for getting documents by association
class GetDocumentsByAssociationUseCase {
  final DocumentRepository repository;

  GetDocumentsByAssociationUseCase(this.repository);

  Future<Either<Failure, List<DocumentEntity>>> call({
    String? associationId,
    String? categoryId,
    String? subcategoryId,
  }) async {
    return await repository.getDocumentsByAssociation(
      associationId: associationId,
      categoryId: categoryId,
      subcategoryId: subcategoryId,
    );
  }
}
