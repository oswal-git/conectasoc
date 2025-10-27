import 'package:conectasoc/core/errors/failures.dart';
import 'package:conectasoc/features/articles/domain/entities/entities.dart';
import 'package:dartz/dartz.dart';

abstract class SettingsRepository {
  Future<Either<Failure, void>> createCategory(String name);
  Future<Either<Failure, void>> updateCategory(CategoryEntity category);
  Future<Either<Failure, void>> deleteCategory(String categoryId);
  Future<Either<Failure, void>> reorderCategories(
      List<CategoryEntity> categories);

  Future<Either<Failure, void>> createSubcategory(
      String name, String categoryId);
  Future<Either<Failure, void>> updateSubcategory(
      SubcategoryEntity subcategory);
  Future<Either<Failure, void>> deleteSubcategory(String subcategoryId);
  Future<Either<Failure, void>> reorderSubcategories(
      List<SubcategoryEntity> subcategories);
}
