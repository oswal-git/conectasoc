// lib/features/users/domain/repositories/user_repository.dart

import 'dart:typed_data';
import 'package:conectasoc/core/errors/failures.dart';
import 'package:conectasoc/features/auth/domain/entities/user_entity.dart';
import 'package:conectasoc/features/users/domain/entities/entities.dart';
import 'package:dartz/dartz.dart';

abstract class UserRepository {
  Future<Either<Failure, void>> joinAssociation({
    required String userId,
    required String associationId,
  });

  Future<Either<Failure, List<UserEntity>>> getUsersByAssociation(
      String associationId);

  Future<Either<Failure, UserEntity>> getUserById(String userId);

  Future<Either<Failure, List<UserEntity>>> getAllUsers();

  Future<Either<Failure, ProfileEntity>> updateUser({
    required ProfileEntity user,
    Uint8List? newImageBytes,
    DateTime? expectedDateUpdated,
  });

  Future<Either<Failure, void>> updateUserDetails(UserEntity user,
      {DateTime? expectedDateUpdated});

  Future<Either<Failure, void>> deleteUser(String userId);

  Future<Either<Failure, void>> removeMembership({
    required String userId,
    required String associationId,
  });
}
