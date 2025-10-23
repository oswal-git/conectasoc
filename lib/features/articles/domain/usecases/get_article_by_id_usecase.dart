import 'package:conectasoc/core/errors/failures.dart';
import 'package:conectasoc/features/articles/domain/entities/article_entity.dart';
import 'package:conectasoc/features/articles/domain/repositories/article_repository.dart';
import 'package:dartz/dartz.dart';

class GetArticleByIdUseCase {
  final ArticleRepository repository;

  GetArticleByIdUseCase(this.repository);

  Future<Either<Failure, ArticleEntity>> call(String articleId) {
    return repository.getArticleById(articleId);
  }
}
