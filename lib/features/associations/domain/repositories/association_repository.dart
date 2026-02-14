import 'dart:typed_data';

import 'package:conectasoc/core/errors/failures.dart';
import 'package:conectasoc/features/associations/domain/entities/association_entity.dart';
import 'package:dartz/dartz.dart';

abstract class AssociationRepository {
  Future<Either<Failure, List<AssociationEntity>>> getAllAssociations();

  Future<Either<Failure, AssociationEntity>> getAssociationById(String id);

  Future<Either<Failure, AssociationEntity>> updateAssociation({
    required AssociationEntity association,
    Uint8List? logoBytes,
    DateTime? expectedDateUpdated,
  });

  Future<Either<Failure, AssociationEntity>> createAssociation({
    required String shortName,
    required String longName,
    required String email,
    required String contactName,
    required String phone,
    String? creatorId,
    String? contactUserId,
    Uint8List? logoBytes,
  });

  Future<Either<Failure, void>> deleteAssociation(String associationId);

  Future<Either<Failure, void>> undoDeleteAssociation(String id);
}
