import 'dart:io';

import 'package:conectasoc/core/errors/failures.dart';
import 'package:conectasoc/features/associations/domain/entities/association_entity.dart';
import 'package:dartz/dartz.dart';

abstract class AssociationRepository {
  Future<Either<Failure, List<AssociationEntity>>> getAllAssociations();

  Future<Either<Failure, AssociationEntity>> getAssociationById(String id);

  Future<Either<Failure, AssociationEntity>> updateAssociation({
    required AssociationEntity association,
    File? newLogoFile,
  });

  Future<Either<Failure, AssociationEntity>> createAssociation({
    required String shortName,
    required String longName,
    required String email,
    required String contactName,
    required String phone,
    required String creatorId,
  });

  Future<Either<Failure, void>> deleteAssociation(String associationId);
}
