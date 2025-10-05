// lib/features/users/domain/usecases/join_association_usecase.dart

import 'package:conectasoc/core/errors/errors.dart';
import 'package:conectasoc/features/users/domain/repositories/repositories.dart';
import 'package:dartz/dartz.dart';

class JoinAssociationUseCase {
  final UserRepository repository;

  JoinAssociationUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String userId,
    required String associationId,
  }) async {
    return await repository.joinAssociation(
      userId: userId,
      associationId: associationId,
    );
  }
}
