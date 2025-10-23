import 'package:conectasoc/core/errors/failures.dart';
import 'package:conectasoc/features/articles/domain/repositories/article_repository.dart';
import 'package:dartz/dartz.dart';

class DeleteArticleUseCase {
  final ArticleRepository repository;

  DeleteArticleUseCase(
    this.repository, {
    String? coverUrl,
    List<String>? sectionImages,
  });

  Future<Either<Failure, void>> call(
    String articleId, {
    String? coverUrl,
    List<String>? sectionImages,
  }) {
    return repository.deleteArticle(
      articleId,
      coverUrl: coverUrl,
      sectionImages: sectionImages,
    );
  }
}
