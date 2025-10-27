// lib/features/users/data/repositories/user_repository_impl.dart

import 'dart:typed_data';
import 'package:conectasoc/core/constants/cloudinary_config.dart';
import 'package:conectasoc/services/cloudinary_service.dart';
import 'package:dartz/dartz.dart';

import 'package:conectasoc/core/errors/exceptions.dart';
import 'package:conectasoc/core/errors/failures.dart';
import 'package:conectasoc/features/auth/domain/entities/user_entity.dart';
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
  Future<Either<Failure, List<UserEntity>>> getUsersByAssociation(
      String associationId) async {
    try {
      final userModels =
          await remoteDataSource.getUsersByAssociation(associationId);
      return Right(userModels);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<UserEntity>>> getAllUsers() async {
    try {
      final userModels = await remoteDataSource.getAllUsers();
      return Right(userModels);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getUserById(String userId) async {
    try {
      final userModel = await remoteDataSource.getUserById(userId);
      return Right(userModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> updateUser({
    required ProfileEntity user,
    Uint8List? newImageBytes,
  }) async {
    try {
      String? newImageUrl;
      String? oldPublicId;

      // Si se va a subir una nueva imagen y ya existía una, obtenemos su public_id para borrarla.
      if (newImageBytes != null && user.photoUrl != null) {
        oldPublicId = CloudinaryService.getPublicIdFromUrl(user.photoUrl!);
      }

      if (newImageBytes != null) {
        final uploadResult = await CloudinaryService.uploadImageBytes(
          imageBytes: newImageBytes,
          filename: user.uid, // Use user ID for a unique filename
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
  Future<Either<Failure, void>> updateUserDetails(UserEntity user) async {
    try {
      await remoteDataSource.updateUserDetails(user);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUser(String userId) async {
    try {
      await remoteDataSource.deleteUser(userId);
      return const Right(null);
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
