import 'package:dartz/dartz.dart';

import 'package:conectasoc/core/errors/failures.dart';
import 'package:conectasoc/features/associations/domain/entities/association_entity.dart';
import 'package:conectasoc/features/associations/domain/repositories/association_repository.dart';

class GetAllAssociationsUseCase {
  final AssociationRepository repository;

  GetAllAssociationsUseCase(this.repository);

  Future<Either<Failure, List<AssociationEntity>>> call() async {
    return await repository.getAllAssociations();
  }
}
