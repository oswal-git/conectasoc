import 'dart:typed_data';

import 'package:conectasoc/core/errors/failures.dart';
import 'package:conectasoc/features/users/domain/entities/entities.dart';
import 'package:conectasoc/features/users/domain/repositories/repositories.dart';
import 'package:dartz/dartz.dart';

class UpdateUserUseCase {
  final UserRepository repository;

  UpdateUserUseCase(this.repository, {Uint8List? newImageBytes});

  Future<Either<Failure, ProfileEntity>> call({
    required ProfileEntity user,
    Uint8List? newImageBytes,
  }) async {
    return await repository.updateUser(
        user: user, newImageBytes: newImageBytes);
  }
}
