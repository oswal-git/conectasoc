import 'package:dartz/dartz.dart';
import 'package:conectasoc/core/errors/failures.dart';
import 'package:conectasoc/features/documents/domain/repositories/document_repository.dart';

/// Comprueba si un documento está referenciado en algún artículo,
/// ya sea en el campo [documentLink] del artículo o en el [documentLink]
/// de alguna de sus secciones.
///
/// Devuelve [true] si está enlazado (no se puede borrar),
/// [false] si no está enlazado (se puede borrar).
class IsDocumentLinkedUseCase {
  final DocumentRepository repository;

  IsDocumentLinkedUseCase(this.repository);

  Future<Either<Failure, bool>> call(String documentId) {
    return repository.isDocumentLinked(documentId);
  }
}
