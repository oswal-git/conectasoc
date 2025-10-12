// lib/features/auth/domain/usecases/register_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;

import 'package:conectasoc/core/errors/failures.dart';
import 'package:conectasoc/features/associations/domain/usecases/create_association_usecase.dart';
import 'package:conectasoc/features/auth/domain/entities/entities.dart';
import 'package:conectasoc/features/auth/domain/repositories/repositories.dart';

class RegisterUseCase {
  final AuthRepository repository;
  final CreateAssociationUseCase createAssociationUseCase;

  RegisterUseCase(
      {required this.repository, required this.createAssociationUseCase});

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    required bool createAssociation,
    String? associationId,
    String? newAssociationName,
    String? newAssociationLongName,
    String? newAssociationEmail,
    String? newAssociationContactName,
    String? newAssociationPhone,
  }) async {
    firebase.User? firebaseUser;

    try {
      // Paso 1: Crear el usuario en Firebase Authentication.
      final credentialResult =
          await repository.createFirebaseAuthUser(email, password);
      return await credentialResult.fold(
        (failure) => Left(failure),
        (credential) async {
          firebaseUser = credential.user;
          if (firebaseUser == null) {
            return const Left(ServerFailure(
                'Error crítico: No se pudo obtener el usuario de Firebase tras la creación.'));
          }

          // Paso 2: Determinar el rol y la asociación.
          String profile;
          String finalAssociationId;

          if (createAssociation) {
            if (newAssociationName == null || newAssociationLongName == null) {
              return const Left(ValidationFailure('incompleteAssociationData'));
            }
            profile = 'admin';

            // Llamar al UseCase de asociaciones para crear la nueva asociación.
            final createAssocResult = await createAssociationUseCase(
              shortName: newAssociationName,
              longName: newAssociationLongName,
              email: newAssociationEmail ?? email,
              contactName: newAssociationContactName ?? '$firstName $lastName',
              phone: newAssociationPhone ?? phone ?? '',
              creatorId: firebaseUser!.uid, // Añadir el ID del creador
            );

            finalAssociationId = await createAssocResult.fold(
              (failure) =>
                  throw failure, // Lanza para ser capturado por el catch
              (association) => association.id,
            );
          } else {
            if (associationId == null || associationId.isEmpty) {
              return const Left(ValidationFailure('mustSelectAnAssociation'));
            }
            profile = 'asociado';
            finalAssociationId = associationId;
          }

          // Paso 3: Crear el documento del usuario en Firestore.
          final userDocResult = await repository.createUserDocument(
            uid: firebaseUser!.uid,
            email: email,
            firstName: firstName,
            lastName: lastName,
            phone: phone,
            memberships: {finalAssociationId: profile},
          );

          return await userDocResult.fold(
            (failure) => Left(failure),
            (userEntity) async {
              // Paso 4: Enviar email de verificación y limpiar usuario local.
              await firebaseUser!.sendEmailVerification();
              await repository.deleteLocalUser();
              return Right(userEntity);
            },
          );
        },
      );
    } catch (failure) {
      // Rollback: Si algo falla, eliminar el usuario de Firebase Auth.
      await firebaseUser?.delete();
      if (failure is Failure) {
        return Left(failure);
      }
      return Left(ServerFailure(
          'Error inesperado durante el registro: ${failure.toString()}'));
    }
  }
}
