import 'package:conectasoc/core/errors/exceptions.dart';
import 'package:conectasoc/core/errors/failures.dart';
import 'package:conectasoc/features/articles/data/models/models.dart';
import 'package:conectasoc/features/articles/domain/entities/entities.dart';
import 'package:conectasoc/features/associations/data/datasources/settings_remote_datasource.dart';
import 'package:conectasoc/features/associations/domain/repositories/settings_repository.dart';
import 'package:dartz/dartz.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsRemoteDataSource remoteDataSource;

  SettingsRepositoryImpl({required this.remoteDataSource});

  Future<Either<Failure, void>> _tryCatch(
      Future<void> Function() action) async {
    try {
      await action();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createCategory(String name) async {
    return _tryCatch(() => remoteDataSource.createCategory(name));
  }

  @override
  Future<Either<Failure, void>> updateCategory(CategoryEntity category) async {
    return _tryCatch(() => remoteDataSource.updateCategory(CategoryModel(
        id: category.id, name: category.name, order: category.order)));
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String categoryId) async {
    return _tryCatch(() => remoteDataSource.deleteCategory(categoryId));
  }

  @override
  Future<Either<Failure, void>> reorderCategories(
      List<CategoryEntity> categories) async {
    final models = categories
        .map((c) => CategoryModel(id: c.id, name: c.name, order: c.order))
        .toList();
    return _tryCatch(() => remoteDataSource.reorderCategories(models));
  }

  @override
  Future<Either<Failure, void>> createSubcategory(
      String name, String categoryId) async {
    return _tryCatch(
        () => remoteDataSource.createSubcategory(name, categoryId));
  }

  @override
  Future<Either<Failure, void>> updateSubcategory(
      SubcategoryEntity subcategory) async {
    return _tryCatch(() => remoteDataSource.updateSubcategory(SubcategoryModel(
        id: subcategory.id,
        name: subcategory.name,
        order: subcategory.order,
        categoryId: subcategory.categoryId)));
  }

  @override
  Future<Either<Failure, void>> deleteSubcategory(String subcategoryId) async {
    return _tryCatch(() => remoteDataSource.deleteSubcategory(subcategoryId));
  }

  @override
  Future<Either<Failure, void>> reorderSubcategories(
      List<SubcategoryEntity> subcategories) async {
    final models = subcategories
        .map((s) => SubcategoryModel(
            id: s.id, name: s.name, order: s.order, categoryId: s.categoryId))
        .toList();
    return _tryCatch(() => remoteDataSource.reorderSubcategories(models));
  }
}
