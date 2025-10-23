import 'package:conectasoc/features/articles/domain/entities/entities.dart';
import 'package:equatable/equatable.dart';

abstract class ArticleEvent extends Equatable {
  const ArticleEvent();

  @override
  List<Object?> get props => [];
}

class LoadArticles extends ArticleEvent {
  final bool refresh;
  final ArticleFilter filter;

  const LoadArticles({
    this.refresh = false,
    this.filter = const ArticleFilter(),
  });

  @override
  List<Object?> get props => [refresh, filter];
}

class ArticleLoadMoreRequested extends ArticleEvent {}

class ArticleFilterChanged extends ArticleEvent {
  final ArticleFilter filter;

  const ArticleFilterChanged(this.filter);

  @override
  List<Object?> get props => [filter];
}

class ArticleCreated extends ArticleEvent {
  final ArticleEntity article;

  const ArticleCreated(this.article);

  @override
  List<Object?> get props => [article];
}

class ArticleUpdated extends ArticleEvent {
  final ArticleEntity article;

  const ArticleUpdated(this.article);

  @override
  List<Object?> get props => [article];
}

class ArticleDeleted extends ArticleEvent {
  final String articleId;

  const ArticleDeleted(this.articleId);

  @override
  List<Object?> get props => [articleId];
}
