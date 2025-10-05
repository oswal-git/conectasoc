// lib/features/users/domain/repositories/user_repository.dart

import 'package:conectasoc/core/errors/failures.dart';
import 'package:dartz/dartz.dart';

abstract class UserRepository {
  Future<Either<Failure, void>> joinAssociation({
    required String userId,
    required String associationId,
  });
}
