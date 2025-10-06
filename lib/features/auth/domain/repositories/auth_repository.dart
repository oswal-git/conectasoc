// lib/features/auth/domain/repositories/auth_repository.dart

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;

import 'package:conectasoc/core/errors/failures.dart';
import 'package:conectasoc/features/auth/domain/entities/entities.dart';

abstract class AuthRepository {
  Stream<firebase.User?> get authStateChanges;

  // Verificación de estado
  Future<Either<Failure, UserEntity?>> getCurrentUser();
  Future<Either<Failure, bool>> hasLocalUser();
  Future<Either<Failure, LocalUserEntity?>> getLocalUser();

  // Usuario Local (Tipo 1)
  Future<Either<Failure, void>> saveLocalUser({
    required String displayName,
    required String associationId,
  });
  Future<Either<Failure, void>> deleteLocalUser();

  // Autenticación (Tipo 2)
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> registerWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    String? associationId,
    bool createAssociation,
    String? newAssociationName,
    String? newAssociationLongName,
    String? newAssociationEmail,
    String? newAssociationContactName,
    String? newAssociationPhone,
  });

  Future<Either<Failure, UserEntity>> upgradeLocalToRegistered({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
  });

  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, void>> resetPasswordWithEmail(String email);

  // Asociaciones
  Future<Either<Failure, List<AssociationEntity>>> getAllAssociations();
  Future<Either<Failure, AssociationEntity>> createNewAssociation({
    required String shortName,
    required String longName,
    required String email,
    required String contactName,
    required String phone,
    String? description,
  });

  Future<Either<Failure, void>> leaveAssociation(MembershipEntity membership);
}
