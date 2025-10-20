import 'package:conectasoc/core/errors/failures.dart';
import 'package:conectasoc/features/articles/domain/entities/entities.dart';
import 'package:conectasoc/features/auth/domain/entities/entities.dart';
import 'package:dartz/dartz.dart';

abstract class ArticleRepository {
  Future<Either<Failure, List<ArticleEntity>>> getArticles({
    UserEntity? user,
    MembershipEntity? membership,
  });

  Future<Either<Failure, List<CategoryEntity>>> getCategories();

  Future<Either<Failure, List<SubcategoryEntity>>> getSubcategories(
      String categoryId);
}
