// lib/features/articles/domain/usecases/create_article_usecase.dart
import 'dart:io';
import 'package:conectasoc/core/errors/failures.dart';
import 'package:conectasoc/features/articles/domain/entities/article_entity.dart';
import 'package:conectasoc/features/articles/domain/repositories/article_repository.dart';
import 'package:dartz/dartz.dart';

class CreateArticleUseCase {
  final ArticleRepository repository;

  CreateArticleUseCase(this.repository);

  Future<Either<Failure, ArticleEntity>> call(
      ArticleEntity article, File coverImageFile) {
    return repository.createArticle(article, coverImageFile);
  }
}
