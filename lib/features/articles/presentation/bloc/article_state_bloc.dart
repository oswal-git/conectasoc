// Estados
import 'package:conectasoc/features/articles/domain/entities/entities.dart';
import 'package:equatable/equatable.dart';

abstract class ArticleState extends Equatable {
  const ArticleState();

  @override
  @override
  List<Object> get props => [];
}

class ArticleInitial extends ArticleState {}

class ArticleLoading extends ArticleState {}

class ArticleLoaded extends ArticleState {
  final List<ArticleEntity> articles;
  final bool hasMore;
  final ArticleFilter filter;

  const ArticleLoaded({
    required this.articles,
    this.hasMore = false,
    required this.filter,
  });

  @override
  List<Object> get props => [articles, hasMore, filter];
}

class ArticleError extends ArticleState {
  final String message;

  const ArticleError(this.message);

  @override
  List<Object> get props => [message];
}
