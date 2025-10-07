import 'package:conectasoc/core/errors/failures.dart';
import 'package:conectasoc/features/associations/domain/entities/association_entity.dart';
import 'package:conectasoc/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class GetAllAssociationsUseCase {
  final AuthRepository repository;

  GetAllAssociationsUseCase(this.repository);

  Future<Either<Failure, List<AssociationEntity>>> call() {
    return repository.getAllAssociations();
  }
}
