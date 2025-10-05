// lib/features/auth/domain/usecases/register_usecase.dart

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    bool createAssociation = false,
    String? associationId,
    String? newAssociationName,
    String? newAssociationLongName,
    String? newAssociationEmail,
    String? newAssociationContactName,
    String? newAssociationPhone,
  }) async {
    // Validaciones
    if (email.isEmpty ||
        password.isEmpty ||
        firstName.isEmpty ||
        lastName.isEmpty) {
      return const Left(
          ValidationFailure('Todos los campos obligatorios deben completarse'));
    }

    if (!_isValidEmail(email)) {
      return const Left(ValidationFailure('Email inválido'));
    }

    if (password.length < 6) {
      return const Left(
          ValidationFailure('Contraseña debe tener al menos 6 caracteres'));
    }

    if (createAssociation) {
      if (newAssociationName == null || newAssociationName.isEmpty) {
        return const Left(ValidationFailure(
            'Debe proporcionar el nombre de la nueva asociación'));
      }
      if (newAssociationLongName == null || newAssociationLongName.isEmpty) {
        return const Left(ValidationFailure(
            'Debe proporcionar el nombre completo de la asociación'));
      }
    } else {
      if (associationId == null || associationId.isEmpty) {
        return const Left(
            ValidationFailure('Debe seleccionar una asociación existente'));
      }
    }

    return await repository.registerWithEmail(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      associationId: associationId,
      createAssociation: createAssociation,
      newAssociationName: newAssociationName,
      newAssociationLongName: newAssociationLongName,
      newAssociationEmail: newAssociationEmail,
      newAssociationContactName: newAssociationContactName,
      newAssociationPhone: newAssociationPhone,
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
