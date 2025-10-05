// lib/features/auth/domain/usecases/get_associations_usecase.dart

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/association_entity.dart';
import '../repositories/auth_repository.dart';

class GetAssociationsUseCase {
  final AuthRepository repository;

  GetAssociationsUseCase(this.repository);

  Future<Either<Failure, List<AssociationEntity>>> call() async {
    return await repository.getAllAssociations();
  }
}
