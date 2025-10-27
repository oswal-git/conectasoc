import 'package:conectasoc/core/errors/errors.dart';
import 'package:conectasoc/features/articles/domain/entities/entities.dart';
import 'package:conectasoc/features/associations/domain/repositories/settings_repository.dart';
import 'package:dartz/dartz.dart';

class ReorderSubcategoriesUseCase {
  final SettingsRepository repository;
  ReorderSubcategoriesUseCase(this.repository);
  Future<Either<Failure, void>> call(List<SubcategoryEntity> subcategories) =>
      repository.reorderSubcategories(subcategories);
}
