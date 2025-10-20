import 'package:conectasoc/core/errors/failures.dart';
import 'package:conectasoc/features/auth/domain/entities/user_entity.dart';
import 'package:conectasoc/features/users/domain/repositories/repositories.dart';
import 'package:dartz/dartz.dart';

class GetAllUsersUseCase {
  final UserRepository repository;

  GetAllUsersUseCase(this.repository);

  Future<Either<Failure, List<UserEntity>>> call() async {
    return await repository.getAllUsers();
  }
}
