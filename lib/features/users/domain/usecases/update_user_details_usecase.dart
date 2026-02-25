import 'package:conectasoc/core/errors/failures.dart';
import 'package:conectasoc/features/auth/domain/entities/entities.dart';
import 'package:conectasoc/features/users/domain/repositories/repositories.dart';
import 'package:dartz/dartz.dart';

class UpdateUserDetailsUseCase {
  final UserRepository repository;

  UpdateUserDetailsUseCase(this.repository);

  Future<Either<Failure, void>> call(UserEntity user,
      {DateTime? expectedDateUpdated}) async {
    return await repository.updateUserDetails(user,
        expectedDateUpdated: expectedDateUpdated);
  }
}
