// lib/features/auth/domain/usecases/save_local_user_usecase.dart

import 'package:conectasoc/core/errors/errors.dart';
import 'package:conectasoc/features/auth/domain/repositories/repositories.dart';
import 'package:dartz/dartz.dart';

class SaveLocalUserUseCase {
  final AuthRepository repository;

  SaveLocalUserUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String displayName,
    required String associationId,
    required String language,
  }) async {
    if (displayName.isEmpty) {
      return const Left(ValidationFailure('El nombre es requerido'));
    }

    if (associationId.isEmpty) {
      return const Left(ValidationFailure('Debe seleccionar una asociación'));
    }

    if (language.isEmpty) {
      return const Left(ValidationFailure('El idioma es requerido'));
    }

    return await repository.saveLocalUser(
      displayName: displayName,
      associationId: associationId,
      language: language,
    );
  }
}
