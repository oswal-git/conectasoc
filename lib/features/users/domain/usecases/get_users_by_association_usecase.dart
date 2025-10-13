// lib/features/users/domain/usecases/get_users_by_association_usecase.dart

import 'package:conectasoc/core/errors/failures.dart';
import 'package:conectasoc/features/auth/domain/entities/user_entity.dart';
import 'package:conectasoc/features/users/domain/repositories/repositories.dart';
import 'package:dartz/dartz.dart';

class GetUsersByAssociationUseCase {
  final UserRepository repository;

  GetUsersByAssociationUseCase(this.repository);

  Future<Either<Failure, List<UserEntity>>> call(String associationId) async {
    return await repository.getUsersByAssociation(associationId);
  }
}
