// lib/features/users/data/repositories/user_repository_impl.dart

import 'dart:io';
import 'package:conectasoc/core/constants/cloudinary_config.dart';
import 'package:conectasoc/services/cloudinary_service.dart';
import 'package:dartz/dartz.dart';

import 'package:conectasoc/core/errors/exceptions.dart';
import 'package:conectasoc/core/errors/failures.dart';
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
      // El rol por defecto al unirse es 'asociado'
      await remoteDataSource.addMembership(userId, associationId, 'asociado');
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
      String? oldPublicId;

      // Si se va a subir una nueva imagen y ya existía una, obtenemos su public_id para borrarla.
      if (newImageFile != null && user.photoUrl != null) {
        oldPublicId = CloudinaryService.getPublicIdFromUrl(user.photoUrl!);
      }

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

      // Si la actualización fue exitosa y tenemos un oldPublicId, lo borramos.
      // Lo hacemos después para no borrar la imagen vieja si la actualización falla.
      if (oldPublicId != null) {
        await CloudinaryService.deleteImage(oldPublicId);
      }
      return Right(updatedUser);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> removeMembership(
      {required String userId, required String associationId}) async {
    try {
      await remoteDataSource.removeMembership(userId, associationId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(
          'Ocurrió un error inesperado al abandonar la asociación.'));
    }
  }
}
