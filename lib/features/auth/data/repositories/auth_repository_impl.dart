// lib/features/auth/data/repositories/auth_repository_impl.dart

// ignore_for_file: avoid_print

import 'package:conectasoc/features/auth/data/models/models.dart';
import 'package:conectasoc/features/users/domain/repositories/repositories.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;

import 'package:conectasoc/core/errors/exceptions.dart';
import 'package:conectasoc/core/errors/failures.dart';
import 'package:conectasoc/features/auth/data/datasources/datasources.dart';
import 'package:conectasoc/features/auth/domain/entities/entities.dart';
import 'package:conectasoc/features/auth/domain/repositories/repositories.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final UserRepository userRepository;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.userRepository,
  });

  @override
  Stream<firebase.User?> get authStateChanges =>
      remoteDataSource.authStateChanges;

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final userModel = await remoteDataSource.getCurrentUser();
      if (userModel == null) return const Right(null);

      return Right(userModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error obteniendo usuario: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> hasLocalUser() async {
    try {
      final has = await localDataSource.hasLocalUser();
      return Right(has);
    } catch (e) {
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, LocalUserEntity?>> getLocalUser() async {
    try {
      final localUser = await localDataSource.getLocalUser();
      return Right(localUser);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Error obteniendo usuario local: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveLocalUser({
    required String displayName,
    required String associationId,
  }) async {
    try {
      final localUser = LocalUserEntity(
        displayName: displayName,
        associationId: associationId,
      );

      await localDataSource.saveLocalUser(localUser);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Error guardando usuario local: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteLocalUser() async {
    try {
      await localDataSource.deleteLocalUser();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Error eliminando usuario local: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await remoteDataSource.signInWithEmail(email, password);
      return Right(userModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error en login: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> signInWithEmailOnly({
    required String email,
    required String password,
  }) async {
    try {
      await remoteDataSource.signInWithEmailOnly(email, password);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error en login: $e'));
    }
  }

  @override
  Future<Either<Failure, firebase.UserCredential>> createFirebaseAuthUser(
      String email, String password) async {
    print('Inicio createFirebaseAuthUser');
    try {
      final credential =
          await remoteDataSource.createFirebaseAuthUser(email, password);
      print('createFirebaseAuthUser: credential');
      return Right(credential);
    } on ServerException catch (e) {
      print('createFirebaseAuthUser: ServerException -> ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e) {
      print('createFirebaseAuthUser: GenericException -> $e');
      return Left(ServerFailure('Error creando usuario en Auth: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> createUserDocumentFromEntity(
      UserEntity user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      await remoteDataSource.createUserDocument(userModel);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error cerrando sesión: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> resetPasswordWithEmail(String email) async {
    try {
      await remoteDataSource.resetPasswordWithEmail(email);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error enviando email de recuperación: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> leaveAssociation(
      MembershipEntity membership) async {
    try {
      // Delegar la eliminación de la membresía al UserRepository
      return await userRepository.removeMembership(
        userId: membership.userId,
        associationId: membership.associationId,
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error al abandonar la asociación: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getSavedUser() async {
    try {
      final userModel = await remoteDataSource.getSavedUser();
      return Right(userModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error al obtener el usuario guardado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserFechaNotificada(
      String uid, DateTime fecha) async {
    try {
      await remoteDataSource.updateUserFechaNotificada(uid, fecha);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
          ServerFailure('Error al actualizar fecha de notificación: $e'));
    }
  }
}
