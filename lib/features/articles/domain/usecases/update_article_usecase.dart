import 'dart:typed_data';

import 'package:conectasoc/core/errors/failures.dart';
import 'package:conectasoc/features/articles/domain/entities/article_entity.dart';
import 'package:conectasoc/features/articles/domain/repositories/article_repository.dart';
import 'package:dartz/dartz.dart';

class UpdateArticleUseCase {
  final ArticleRepository repository;

  UpdateArticleUseCase(this.repository);

  Future<Either<Failure, ArticleEntity>> call(
    ArticleEntity article, {
    Uint8List? newCoverImageBytes,
  }) async {
    return repository.updateArticle(article,
        newCoverImageBytes: newCoverImageBytes);
  }
}
