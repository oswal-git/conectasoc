import 'package:conectasoc/core/errors/errors.dart';
import 'package:conectasoc/features/articles/domain/entities/entities.dart';
import 'package:conectasoc/features/articles/domain/repositories/article_repository.dart';
import 'package:conectasoc/features/auth/domain/entities/entities.dart';
import 'package:dartz/dartz.dart';

class GetArticlesUseCase {
  final ArticleRepository repository;

  GetArticlesUseCase(this.repository);

  Future<Either<Failure, List<ArticleEntity>>> call({
    UserEntity? user,
    MembershipEntity? membership,
  }) async {
    return await repository.getArticles(user: user, membership: membership);
  }
}
