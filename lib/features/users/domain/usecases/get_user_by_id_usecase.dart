import 'package:conectasoc/core/errors/failures.dart';
import 'package:conectasoc/features/auth/domain/entities/user_entity.dart';
import 'package:conectasoc/features/users/domain/repositories/repositories.dart';
import 'package:dartz/dartz.dart';

class GetUserByIdUseCase {
  final UserRepository repository;

  GetUserByIdUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(String userId) async {
    return await repository.getUserById(userId);
  }
}
