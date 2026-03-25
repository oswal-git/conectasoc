import 'package:dartz/dartz.dart';
import 'package:conectasoc/core/errors/failures.dart';
import 'package:conectasoc/features/documents/domain/entities/document_entity.dart';
import 'package:conectasoc/features/documents/domain/repositories/document_repository.dart';

class UpdateDocumentUseCase {
  final DocumentRepository repository;

  UpdateDocumentUseCase(this.repository);

  Future<Either<Failure, DocumentEntity>> call(DocumentEntity document) async {
    return await repository.updateDocument(document);
  }
}
