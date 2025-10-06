// lib/features/users/domain/repositories/user_repository.dart

import 'dart:io';
import 'package:conectasoc/core/errors/failures.dart';
import 'package:conectasoc/features/users/domain/entities/entities.dart';
import 'package:dartz/dartz.dart';

abstract class UserRepository {
  Future<Either<Failure, void>> joinAssociation({
    required String userId,
    required String associationId,
  });

  Future<Either<Failure, ProfileEntity>> updateUser({
    required ProfileEntity user,
    File? newImageFile,
  });
}
