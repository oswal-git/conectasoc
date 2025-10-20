import 'package:conectasoc/core/errors/errors.dart';
import 'package:conectasoc/features/auth/domain/entities/entities.dart';
import 'package:conectasoc/features/auth/domain/repositories/repositories.dart';

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;

class CreateUserUseCase {
  final AuthRepository repository;

  CreateUserUseCase({required this.repository});

  Future<Either<Failure, UserEntity>> call(UserEntity user,
      {required String password}) async {
    firebase.User? firebaseUser;

    try {
      // Step 1: Create the user in Firebase Authentication.
      final credentialResult =
          await repository.createFirebaseAuthUser(user.email, password);

      return await credentialResult.fold(
        (failure) => Left(failure),
        (credential) async {
          firebaseUser = credential.user;
          if (firebaseUser == null) {
            return const Left(ServerFailure(
                'Error: Could not get Firebase user after creation.'));
          }

          // Step 2: Create the user document in Firestore with the new UID.
          final userWithUid = user.copyWith(uid: firebaseUser!.uid);
          final userDocResult =
              await repository.createUserDocumentFromEntity(userWithUid);

          return userDocResult.fold(
            (failure) => Left(failure),
            (_) async {
              await firebaseUser!.sendEmailVerification();
              return Right(userWithUid);
            },
          );
        },
      );
    } catch (e) {
      await firebaseUser?.delete(); // Rollback
      return Left(ServerFailure('Unexpected error during user creation: $e'));
    }
  }
}
