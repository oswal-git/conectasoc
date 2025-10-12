import 'package:dartz/dartz.dart';

import 'package:conectasoc/core/errors/failures.dart';
import 'package:conectasoc/features/associations/domain/entities/association_entity.dart';
import 'package:conectasoc/features/associations/domain/repositories/association_repository.dart';

class CreateAssociationUseCase {
  final AssociationRepository repository;

  CreateAssociationUseCase(this.repository);

  Future<Either<Failure, AssociationEntity>> call({
    required String shortName,
    required String longName,
    required String email,
    required String contactName,
    required String phone,
    required String creatorId,
  }) async {
    if (shortName.isEmpty || longName.isEmpty) {
      return const Left(ValidationFailure('shortAndLongNameRequired'));
    }

    return await repository.createAssociation(
      shortName: shortName,
      longName: longName,
      email: email,
      contactName: contactName,
      phone: phone,
      creatorId: creatorId,
    );
  }
}
