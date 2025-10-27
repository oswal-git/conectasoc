import 'package:conectasoc/core/errors/errors.dart';
import 'package:conectasoc/features/associations/domain/repositories/settings_repository.dart';
import 'package:dartz/dartz.dart';

class DeleteCategoryUseCase {
  final SettingsRepository repository;
  DeleteCategoryUseCase(this.repository);
  Future<Either<Failure, void>> call(String categoryId) =>
      repository.deleteCategory(categoryId);
}
