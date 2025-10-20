import 'package:conectasoc/core/errors/errors.dart';
import 'package:conectasoc/features/auth/domain/entities/entities.dart';
import 'package:conectasoc/features/users/domain/repositories/repositories.dart';
import 'package:dartz/dartz.dart';

class UpdateUserUseCase {
  final UserRepository repository;

  UpdateUserUseCase(this.repository);

  Future<Either<Failure, void>> call(UserEntity user) async {
    return await repository.updateUserDetails(user);
  }
}
