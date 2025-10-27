import 'package:conectasoc/core/errors/errors.dart';
import 'package:conectasoc/features/articles/domain/entities/entities.dart';
import 'package:conectasoc/features/associations/domain/repositories/settings_repository.dart';
import 'package:dartz/dartz.dart';

class UpdateSubcategoryUseCase {
  final SettingsRepository repository;
  UpdateSubcategoryUseCase(this.repository);
  Future<Either<Failure, void>> call(SubcategoryEntity subcategory) =>
      repository.updateSubcategory(subcategory);
}
