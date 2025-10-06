// lib/features/users/data/repositories/user_repository_impl.dart

import 'dart:io';
import 'package:conectasoc/core/constants/cloudinary_config.dart';
import 'package:conectasoc/services/cloudinary_service.dart';
import 'package:dartz/dartz.dart';

import 'package:conectasoc/core/errors/exceptions.dart';
import 'package:conectasoc/core/errors/failures.dart';
import 'package:conectasoc/features/auth/data/models/models.dart';
import 'package:conectasoc/features/users/data/datasources/user_remote_datasource.dart';
import 'package:conectasoc/features/users/domain/entities/profile_entity.dart';
import 'package:conectasoc/features/users/domain/repositories/repositories.dart';

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

  @override
  Future<Either<Failure, ProfileEntity>> updateUser({
    required ProfileEntity user,
    File? newImageFile,
  }) async {
    try {
      String? newImageUrl;
      if (newImageFile != null) {
        final uploadResult = await CloudinaryService.uploadImage(
          imageFile: newImageFile,
          imageType: CloudinaryImageType.avatar,
        );
        if (uploadResult.success) {
          newImageUrl = uploadResult.secureUrl;
        } else {
          return Left(
              ServerFailure(uploadResult.error ?? 'Error al subir la imagen'));
        }
      }

      final updatedUser = await remoteDataSource.updateUser(user, newImageUrl);
      return Right(updatedUser);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
