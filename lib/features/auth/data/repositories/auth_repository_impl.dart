// lib/features/auth/data/repositories/auth_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;

import 'package:conectasoc/core/errors/exceptions.dart';
import 'package:conectasoc/core/errors/failures.dart';
import 'package:conectasoc/features/auth/data/datasources/datasources.dart';
import 'package:conectasoc/features/auth/data/models/models.dart';
import 'package:conectasoc/features/auth/domain/entities/entities.dart';
import 'package:conectasoc/features/auth/domain/repositories/repositories.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Stream<firebase.User?> get authStateChanges =>
      remoteDataSource.authStateChanges;

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final userModel = await remoteDataSource.getCurrentUser();
      if (userModel == null) return const Right(null);

      return Right(userModel.toEntity());
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
      return Right(userModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error en login: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> registerWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    String? associationId,
    bool createAssociation = false,
    String? newAssociationName,
    String? newAssociationLongName,
    String? newAssociationEmail,
    String? newAssociationContactName,
    String? newAssociationPhone,
  }) async {
    User? firebaseUser;

    try {
      String profile;
      String finalAssociationId;

      // Paso 1: Crear el usuario en Firebase Authentication.
      // Esto es crucial hacerlo primero para obtener un UID único. Si este paso falla,
      // la operación se detiene antes de crear documentos huérfanos en Firestore.
      final credential =
          await remoteDataSource.createFirebaseAuthUser(email, password);
      firebaseUser = credential.user;
      if (firebaseUser == null) {
        return const Left(ServerFailure(
            'Error crítico: No se pudo obtener el usuario de Firebase tras la creación.'));
      }

      // Paso 2: Determinar el rol del usuario y su asociación.
      // Se bifurca la lógica dependiendo de si el usuario está creando una nueva
      // asociación o uniéndose a una existente.
      if (createAssociation) {
        // Caso A: El usuario crea una nueva asociación.
        if (newAssociationName == null || newAssociationLongName == null) {
          return const Left(
              ValidationFailure('Datos de asociación incompletos'));
        }

        profile = 'admin';

        // Se prepara el modelo de la nueva asociación.
        final newAssoc = AssociationModel(
          id: '', // Se generará automáticamente
          shortName: newAssociationName,
          longName: newAssociationLongName,
          email: newAssociationEmail ?? email,
          contactName: newAssociationContactName ?? '$firstName $lastName',
          phone: newAssociationPhone ?? phone ?? '',
          dateCreated: DateTime.now(),
          dateUpdated: DateTime.now(),
        );

        // Se crea la asociación en Firestore y se obtiene su ID.
        final createdAssoc = await remoteDataSource.createAssociation(newAssoc);
        finalAssociationId = createdAssoc.id;
      } else {
        // Caso B: El usuario se une a una asociación existente.
        // Si no se proporciona un ID de asociación, el registro no puede continuar.
        if (associationId == null || associationId.isEmpty) {
          return const Left(
              ValidationFailure('Debe seleccionar una asociación'));
        }

        profile = 'asociado';
        finalAssociationId = associationId;
      }

      // Se crea la primera membresía para el usuario.
      final List<Map<String, dynamic>> memberships = [
        {
          'associationId': finalAssociationId,
          'role': profile,
        }
      ];

      // Paso 3: Crear el documento del usuario en la colección 'users' de Firestore.
      // Este documento contiene toda la información del perfil, incluyendo el rol
      // y la asociación asignados en el paso anterior.
      final userModel = await remoteDataSource.createUserDocument(
        uid: firebaseUser.uid,
        email: email,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        memberships: memberships,
      );

      // Paso 4: Enviar el correo electrónico de verificación.
      // Esto se hace después de que toda la lógica de creación en la base de datos
      // ha sido exitosa.
      await firebaseUser.sendEmailVerification();

      // Paso 5: Limpiar cualquier sesión de "usuario local" que pudiera existir.
      // Esto asegura que la nueva sesión registrada prevalezca.
      await localDataSource.deleteLocalUser();

      return Right(userModel.toEntity());
    } on ServerException catch (e) {
      // Rollback: Si ocurre un error durante la creación de documentos en Firestore
      // (ej. ServerException), se elimina el usuario de Firebase Auth para mantener
      // la consistencia y permitir que el usuario intente registrarse de nuevo.
      await firebaseUser?.delete();
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      // Si hubo un error, eliminar el usuario de Auth para poder reintentar
      await firebaseUser?.delete();
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error en registro: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> upgradeLocalToRegistered({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    try {
      // Obtener usuario local actual
      final localUserResult = await getLocalUser();

      return localUserResult.fold(
        (failure) => Left(failure),
        (localUser) async {
          if (localUser == null) {
            return const Left(
                CacheFailure('No hay usuario local para actualizar'));
          }

          // Registrar manteniendo la asociación del usuario local
          return await registerWithEmail(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName,
            phone: phone,
            associationId: localUser.associationId,
            createAssociation: false,
          );
        },
      );
    } catch (e) {
      return Left(ServerFailure('Error actualizando usuario: $e'));
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
  Future<Either<Failure, List<AssociationEntity>>> getAllAssociations() async {
    try {
      final associations = await remoteDataSource.getAllAssociations();
      return Right(associations.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error obteniendo asociaciones: $e'));
    }
  }

  @override
  Future<Either<Failure, AssociationEntity>> createNewAssociation({
    required String shortName,
    required String longName,
    required String email,
    required String contactName,
    required String phone,
    String? description,
  }) async {
    try {
      final association = AssociationModel(
        id: '', // Se generará automáticamente
        shortName: shortName,
        longName: longName,
        email: email,
        contactName: contactName,
        phone: phone,
        description: description,
        dateCreated: DateTime.now(),
        dateUpdated: DateTime.now(),
      );

      final created = await remoteDataSource.createAssociation(association);
      return Right(created.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error creando asociación: $e'));
    }
  }
}
