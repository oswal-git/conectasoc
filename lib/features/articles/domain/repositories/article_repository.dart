import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conectasoc/features/users/domain/entities/entities.dart';
import 'package:dartz/dartz.dart' hide Tuple2;
import 'package:tuple/tuple.dart';

import 'package:conectasoc/core/errors/errors.dart';
import 'package:conectasoc/features/articles/domain/entities/entities.dart';

abstract class ArticleRepository {
  Future<
          Either<Failure,
              Tuple2<List<ArticleEntity>, DocumentSnapshot<Object?>?>>>
      getArticles({
    IUser? user,
    bool isEditMode = false,
    String? categoryId,
    String? subcategoryId,
    String? searchTerm,
    DocumentSnapshot<Object?>? lastDocument,
    int limit = 20,
  });

  Future<Either<Failure, List<CategoryEntity>>> getCategories();

  Future<Either<Failure, List<SubcategoryEntity>>> getSubcategories(
      String categoryId);

  Future<Either<Failure, ArticleEntity>> createArticle(
    ArticleEntity article,
    Uint8List? coverImageBytes, {
    Map<String, Uint8List> sectionImageBytes = const {},
  });

  Future<Either<Failure, void>> deleteArticle(
    String articleId, {
    String? coverUrl,
    List<String>? sectionImages,
  });

  Future<Either<Failure, ArticleEntity>> getArticleById(String articleId);

  Future<Either<Failure, ArticleEntity>> updateArticle(
    ArticleEntity article, {
    Uint8List? newCoverImageBytes,
    Map<String, Uint8List> newSectionImageBytes = const {},
    List<String> imagesToDelete = const [],
    DateTime? expectedModifiedAt,
  });

  Future<Either<Failure, List<ArticleEntity>>> getArticlesForNotification({
    required DateTime lastNotified,
    required List<String> associationIds,
  });
}
