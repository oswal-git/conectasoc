import 'package:conectasoc/core/errors/errors.dart';
import 'package:conectasoc/features/associations/domain/repositories/settings_repository.dart';
import 'package:dartz/dartz.dart';

class CreateSubcategoryUseCase {
  final SettingsRepository repository;
  CreateSubcategoryUseCase(this.repository);
  Future<Either<Failure, void>> call(String name, String categoryId) =>
      repository.createSubcategory(name, categoryId);
}
