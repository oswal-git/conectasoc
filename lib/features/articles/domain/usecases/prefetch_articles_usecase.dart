import 'package:conectasoc/features/articles/domain/repositories/article_repository.dart';

class PrefetchArticlesUseCase {
  final ArticleRepository repository;

  PrefetchArticlesUseCase(this.repository);

  Future<void> call(List<String> articleIds) async {
    await repository.prefetchArticles(articleIds);
  }
}
