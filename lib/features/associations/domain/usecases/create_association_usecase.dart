import 'package:conectasoc/core/errors/failures.dart';
import 'dart:typed_data';
import 'package:conectasoc/features/associations/domain/entities/association_entity.dart';
import 'package:conectasoc/features/associations/domain/repositories/association_repository.dart';
import 'package:dartz/dartz.dart';

class CreateAssociationUseCase {
  final AssociationRepository repository;

  CreateAssociationUseCase(this.repository);

  Future<Either<Failure, AssociationEntity>> call({
    required String shortName,
    required String longName,
    required String email,
    required String contactName,
    required String phone,
    String? creatorId,
    String? contactUserId,
    Uint8List? logoBytes,
  }) async {
    return await repository.createAssociation(
      shortName: shortName,
      longName: longName,
      email: email,
      contactName: contactName,
      phone: phone,
      creatorId: creatorId,
      contactUserId: contactUserId,
      logoBytes: logoBytes,
    );
  }
}
