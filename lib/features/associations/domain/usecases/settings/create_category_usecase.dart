import 'package:conectasoc/core/errors/errors.dart';
import 'package:conectasoc/features/associations/domain/repositories/settings_repository.dart';
import 'package:dartz/dartz.dart';

class CreateCategoryUseCase {
  final SettingsRepository repository;
  CreateCategoryUseCase(this.repository);
  Future<Either<Failure, void>> call(String name) =>
      repository.createCategory(name);
}
