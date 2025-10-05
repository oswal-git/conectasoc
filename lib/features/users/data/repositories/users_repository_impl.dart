// lib/features/users/data/repositories/user_repository_impl.dart

import 'package:conectasoc/core/errors/exceptions.dart';
import 'package:conectasoc/core/errors/failures.dart';
import 'package:conectasoc/features/auth/data/models/models.dart';
import 'package:conectasoc/features/users/data/datasources/users_remote_datasource.dart';
import 'package:conectasoc/features/users/domain/repositories/users_repository.dart';
import 'package:dartz/dartz.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> joinAssociation(
      {required String userId, required String associationId}) async {
    try {
      final newMembership = MembershipModel(
        associationId: associationId,
        role: 'asociado', // Por defecto, el rol es 'asociado'
      );
      await remoteDataSource.addMembership(userId, newMembership);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Ocurrió un error inesperado.'));
    }
  }
}
