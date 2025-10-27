import 'package:conectasoc/core/errors/failures.dart';
import 'package:conectasoc/features/articles/domain/entities/entities.dart';
import 'package:conectasoc/features/articles/domain/repositories/article_repository.dart';
import 'package:dartz/dartz.dart';

class GetSubcategoriesUseCase {
  final ArticleRepository repository;

  GetSubcategoriesUseCase(this.repository);

  Future<Either<Failure, List<SubcategoryEntity>>> call(
      String categoryId) async {
    return await repository.getSubcategories(categoryId);
  }
}
