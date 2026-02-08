import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conectasoc/core/errors/errors.dart';
import 'package:conectasoc/features/articles/domain/entities/entities.dart';
import 'package:conectasoc/features/articles/domain/repositories/article_repository.dart';
import 'package:conectasoc/features/users/domain/entities/entities.dart';
import 'package:dartz/dartz.dart' hide Tuple2;
import 'package:tuple/tuple.dart';

class GetArticlesUseCase {
  final ArticleRepository repository;

  GetArticlesUseCase(this.repository);

  Future<
      Either<Failure,
          Tuple2<List<ArticleEntity>, DocumentSnapshot<Object?>?>>> call({
    IUser? user,
    bool isEditMode = false,
    String? categoryId,
    String? subcategoryId,
    String? searchTerm,
    DocumentSnapshot<Object?>? lastDocument,
    int limit = 20,
  }) async {
    return await repository.getArticles(
      user: user,
      isEditMode: isEditMode,
      categoryId: categoryId,
      subcategoryId: subcategoryId,
      searchTerm: searchTerm,
      lastDocument: lastDocument,
      limit: limit,
    );
  }
}
