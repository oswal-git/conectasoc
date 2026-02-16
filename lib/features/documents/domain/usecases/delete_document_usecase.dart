import 'package:dartz/dartz.dart';
import 'package:conectasoc/core/errors/failures.dart';
import 'package:conectasoc/features/documents/domain/repositories/document_repository.dart';

/// Use case for deleting a document
class DeleteDocumentUseCase {
  final DocumentRepository repository;

  DeleteDocumentUseCase(this.repository);

  Future<Either<Failure, void>> call(String documentId) async {
    return await repository.deleteDocument(documentId);
  }
}
