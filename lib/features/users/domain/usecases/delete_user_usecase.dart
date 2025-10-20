import 'package:conectasoc/core/errors/failures.dart';
import 'package:conectasoc/features/users/domain/repositories/repositories.dart';
import 'package:dartz/dartz.dart';

class DeleteUserUseCase {
  final UserRepository repository;

  DeleteUserUseCase(this.repository);

  /// Deletes the user document from Firestore.
  /// Note: This does not delete the user from Firebase Auth.
  /// That should be handled by a Cloud Function for security reasons.
  Future<Either<Failure, void>> call(String userId) async {
    // Here you could add business logic, for example,
    // checking if the user is not deleting themselves if they are the last superadmin.
    return await repository.deleteUser(userId);
  }
}
