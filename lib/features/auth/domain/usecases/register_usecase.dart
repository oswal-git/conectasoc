// lib/features/auth/domain/usecases/register_usecase.dart

// ignore_for_file: avoid_print

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:logger/logger.dart';

import 'package:conectasoc/core/errors/failures.dart';
import 'package:conectasoc/features/associations/domain/usecases/create_association_usecase.dart';
import 'package:conectasoc/features/associations/domain/usecases/delete_association_usecase.dart';
import 'package:conectasoc/features/auth/domain/entities/entities.dart';
import 'package:conectasoc/features/auth/domain/repositories/repositories.dart';

class RegisterUseCase {
  final AuthRepository repository;
  final CreateAssociationUseCase createAssociationUseCase;
  final DeleteAssociationUseCase deleteAssociationUseCase;

  final logger = Logger();

  RegisterUseCase({
    required this.repository,
    required this.createAssociationUseCase,
    required this.deleteAssociationUseCase,
  });

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
    // DEBUG: Verificar que se llama al método
    print('=== REGISTER USECASE CALLED ===');
    print('Email: $email');
    print('CreateAssociation: $createAssociation');
    print('AssociationId: $associationId');

    firebase.User? firebaseUser;
    String? createdAssociationId; // Para hacer rollback si es necesario

    try {
      logger.i('Iniciando proceso de registro para: $email');

      // DEBUG: Antes de llamar al repositorio
      print('=== ANTES DE createFirebaseAuthUser ===');
      print('Repository type: ${repository.runtimeType}');

      // PASO 1: Crear el usuario en Firebase Authentication
      logger.d('Paso 1: Creando usuario en Firebase Auth');
      final credentialResult =
          await repository.createFirebaseAuthUser(email, password).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('=== TIMEOUT EN createFirebaseAuthUser ===');
          logger.e('Timeout al crear usuario en Firebase Auth');
          throw const ServerFailure(
              'La operación tardó demasiado. Por favor, verifica tu conexión.');
        },
      );

      return await credentialResult.fold(
        (failure) {
          logger.e('Error en creación de usuario Auth: ${failure.message}');
          return Left(failure);
        },
        (credential) async {
          firebaseUser = credential.user;
          if (firebaseUser == null) {
            logger.e('Usuario de Firebase es null después de la creación');
            return const Left(ServerFailure(
              'Error crítico: No se pudo obtener el usuario de Firebase tras la creación.',
            ));
          }

          logger.i('Usuario creado en Auth con UID: ${firebaseUser!.uid}');
          // DEBUG: Después de llamar al repositorio
          print('=== DESPUÉS DE createFirebaseAuthUser ===');
          print('CredentialResult type: ${credentialResult.runtimeType}');
          logger.d('Paso 1 completado: credentialResult obtenido');

          // PASO 2: Determinar el rol y la asociación
          String profile;
          String finalAssociationId;

          if (createAssociation) {
            // Validar datos de la nueva asociación
            if (newAssociationName == null || newAssociationLongName == null) {
              logger.w('Datos de asociación incompletos');
              await _rollbackFirebaseUser(firebaseUser);
              return const Left(ValidationFailure('incompleteAssociationData'));
            }

            profile = 'admin';
            logger.d('Paso 2: Creando nueva asociación: $newAssociationName');

            // Crear la nueva asociación
            final createAssocResult = await createAssociationUseCase(
              shortName: newAssociationName,
              longName: newAssociationLongName,
              email: newAssociationEmail ?? email,
              contactName: newAssociationContactName ?? '$firstName $lastName',
              phone: newAssociationPhone ?? phone ?? '',
              creatorId: firebaseUser!.uid,
              contactUserId: firebaseUser!.uid,
            );

            // Manejar el resultado de la creación de asociación
            final associationResult = await createAssocResult.fold(
              (failure) async {
                logger.e('Error al crear asociación: ${failure.message}');
                await _rollbackFirebaseUser(firebaseUser);
                return Left<Failure, String>(failure);
              },
              (association) async {
                // IMPORTANTE: Guardar el ID para posible rollback
                createdAssociationId = association.id;
                logger.i('Asociación creada con ID: $createdAssociationId');
                return Right<Failure, String>(association.id);
              },
            );

            // Si hubo error, retornar inmediatamente
            if (associationResult.isLeft()) {
              logger.e(
                  'Error al crear asociación.: ${(associationResult as Left).value}');
              return Left((associationResult as Left).value);
            }

            finalAssociationId = (associationResult as Right).value;
          } else {
            // Unirse a asociación existente
            if (associationId == null || associationId.isEmpty) {
              logger.w('No se seleccionó asociación existente');
              await _rollbackFirebaseUser(firebaseUser);
              return const Left(ValidationFailure('mustSelectAnAssociation'));
            }
            profile = 'asociado';
            finalAssociationId = associationId;
            logger
                .d('Paso 2: Uniéndose a asociación existente: $associationId');
          }

          // PASO 3: Crear el documento del usuario en Firestore
          logger.d('Paso 3: Creando documento de usuario en Firestore');
          final newUserEntity = UserEntity(
            uid: firebaseUser!.uid,
            email: email,
            firstName: firstName,
            lastName: lastName,
            phone: phone,
            memberships: {finalAssociationId: profile},
            status: UserStatus.pending,
            isEmailVerified: false,
            dateCreated: DateTime.now(),
            dateUpdated: DateTime.now(),
          );

          final userDocResult =
              await repository.createUserDocumentFromEntity(newUserEntity);

          return await userDocResult.fold(
            (failure) async {
              logger
                  .e('Error al crear documento de usuario: ${failure.message}');
              // ROLLBACK COMPLETO: Eliminar asociación si se creó + usuario de Auth
              await _rollbackAll(firebaseUser, createdAssociationId);
              return Left(failure);
            },
            (_) async {
              logger.i('Documento de usuario creado exitosamente');
              // // PASO 4: Enviar email de verificación
              // try {
              //   await firebaseUser!.sendEmailVerification();
              //   logger.i('Email de verificación enviado a: $email');
              // } catch (e) {
              //   // Si falla el envío del email, no es crítico
              //   // pero lo registramos para debugging
              //   logger.e(
              //       'Advertencia: No se pudo enviar email de verificación: $e');
              //   // NO hacemos rollback aquí porque el usuario ya está creado correctamente
              // }

              logger.i('Registro completado exitosamente para: $email');
              return Right(newUserEntity);
            },
          );
        },
      );
    } on firebase.FirebaseAuthException catch (e) {
      // Manejar errores específicos de Firebase Auth
      logger.e(
          'FirebaseAuthException durante el registro: ${e.code} - ${e.message}');
      await _rollbackAll(firebaseUser, createdAssociationId);
      return Left(ServerFailure(_getFirebaseAuthErrorMessage(e)));
    } on Failure catch (failure) {
      // Manejar fallos conocidos del dominio
      logger.e('Failure conocido durante el registro: ${failure.message}');
      await _rollbackAll(firebaseUser, createdAssociationId);
      return Left(failure);
    } catch (e, stackTrace) {
      print('=== EXCEPTION CAPTURADA ===');
      print('Exception type: ${e.runtimeType}');
      print('Exception: $e');
      print('StackTrace: $stackTrace');
      logger.e('Error inesperado durante el registro',
          error: e, stackTrace: stackTrace);
      // Manejar cualquier otro error inesperado
      await _rollbackAll(firebaseUser, createdAssociationId);
      return Left(ServerFailure(
        'Error inesperado durante el registro: ${e.toString()}',
      ));
    }
  }

  /// Realiza rollback solo del usuario de Firebase Auth
  Future<void> _rollbackFirebaseUser(firebase.User? user) async {
    if (user == null) return;

    try {
      logger.i('Haciendo rollback del usuario de Firebase Auth: ${user.uid}');
      await user.delete();
      logger.i('Usuario de Firebase Auth eliminado exitosamente');
    } catch (e) {
      logger.e('Error al hacer rollback del usuario de Firebase Auth: $e');
      // No lanzamos excepción aquí para no ocultar el error original
    }
  }

  /// Realiza rollback completo: asociación (si se creó) + usuario de Firebase Auth
  Future<void> _rollbackAll(
    firebase.User? user,
    String? associationId,
  ) async {
    logger.w('Iniciando rollback completo');

    // 1. Eliminar asociación si se creó
    if (associationId != null) {
      try {
        await deleteAssociationUseCase(associationId);
        logger.i('Rollback: Asociación $associationId eliminada');
      } catch (e) {
        logger.e('Error al hacer rollback de la asociación: $e');
        // Continuamos con el rollback del usuario incluso si esto falla
      }
    }

    // 2. Eliminar usuario de Firebase Auth
    await _rollbackFirebaseUser(user);

    logger.i('Rollback completo finalizado');
  }

  /// Convierte códigos de error de Firebase Auth en mensajes legibles
  String _getFirebaseAuthErrorMessage(firebase.FirebaseAuthException e) {
    switch (e.code) {
      case 'network-request-failed':
        return 'No hay conexión a internet. Por favor, verifica tu conexión y vuelve a intentarlo.';
      case 'email-already-in-use':
        return 'Este email ya está registrado';
      case 'invalid-email':
        return 'El formato del email no es válido';
      case 'operation-not-allowed':
        return 'Operación no permitida';
      case 'weak-password':
        return 'La contraseña es demasiado débil';
      case 'too-many-requests':
        return 'Demasiados intentos. Por favor, espera unos minutos.';
      default:
        return 'Error de autenticación: ${e.message ?? e.code}';
    }
  }
}
