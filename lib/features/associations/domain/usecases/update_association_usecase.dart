import 'dart:typed_data';

import 'package:dartz/dartz.dart';

import 'package:conectasoc/core/errors/failures.dart';
import 'package:conectasoc/features/associations/domain/entities/association_entity.dart';
import 'package:conectasoc/features/associations/domain/repositories/association_repository.dart';

class UpdateAssociationUseCase {
  final AssociationRepository repository;

  UpdateAssociationUseCase(this.repository);

  Future<Either<Failure, AssociationEntity>> call({
    required AssociationEntity association,
    Uint8List? logoBytes,
    DateTime? expectedDateUpdated,
  }) async {
    // Validaciones
    if (association.shortName.isEmpty || association.longName.isEmpty) {
      return const Left(ValidationFailure('shortAndLongNameRequired'));
    }

    if (association.email != null &&
        association.email!.isNotEmpty &&
        !_isValidEmail(association.email!)) {
      return const Left(ValidationFailure('invalidEmailFormat'));
    }

    return await repository.updateAssociation(
      association: association,
      logoBytes: logoBytes,
      expectedDateUpdated: expectedDateUpdated,
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
