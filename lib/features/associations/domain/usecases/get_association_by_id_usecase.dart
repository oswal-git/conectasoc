import 'package:dartz/dartz.dart';

import 'package:conectasoc/core/errors/failures.dart';
import 'package:conectasoc/features/associations/domain/entities/association_entity.dart';
import 'package:conectasoc/features/associations/domain/repositories/association_repository.dart';

class GetAssociationByIdUseCase {
  final AssociationRepository repository;

  GetAssociationByIdUseCase(this.repository);

  Future<Either<Failure, AssociationEntity>> call(String id) async {
    if (id.isEmpty) {
      return const Left(ValidationFailure('associationIdCannotBeEmpty'));
    }
    return await repository.getAssociationById(id);
  }
}
