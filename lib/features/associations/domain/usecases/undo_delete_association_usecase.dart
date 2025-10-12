import 'package:conectasoc/core/errors/failures.dart';
import 'package:conectasoc/features/associations/domain/repositories/association_repository.dart';
import 'package:dartz/dartz.dart';

class UndoDeleteAssociationUseCase {
  final AssociationRepository repository;

  UndoDeleteAssociationUseCase(this.repository);

  Future<Either<Failure, void>> call(String associationId) async {
    return await repository.undoDeleteAssociation(associationId);
  }
}
