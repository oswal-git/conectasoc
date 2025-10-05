// lib/features/auth/domain/usecases/login_usecase.dart

import 'package:conectasoc/core/errors/failures.dart';
import 'package:conectasoc/features/auth/domain/entities/user_entity.dart';
import 'package:conectasoc/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
// lib/features/auth/domain/usecases/login_usecase.dart

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
  }) async {
    // Validaciones
    if (email.isEmpty || password.isEmpty) {
      return const Left(ValidationFailure('Email y contraseña son requeridos'));
    }

    if (!_isValidEmail(email)) {
      return const Left(ValidationFailure('Email inválido'));
    }

    if (password.length < 6) {
      return const Left(
          ValidationFailure('Contraseña debe tener al menos 6 caracteres'));
    }

    return await repository.signInWithEmail(
      email: email,
      password: password,
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
