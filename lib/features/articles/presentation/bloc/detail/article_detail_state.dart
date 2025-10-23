import 'package:conectasoc/features/articles/domain/entities/entities.dart';
import 'package:equatable/equatable.dart';

abstract class ArticleDetailState extends Equatable {
  const ArticleDetailState();

  @override
  List<Object> get props => [];
}

class ArticleDetailInitial extends ArticleDetailState {}

class ArticleDetailLoading extends ArticleDetailState {}

class ArticleDetailLoaded extends ArticleDetailState {
  final ArticleEntity article;
  const ArticleDetailLoaded(this.article);

  @override
  List<Object> get props => [article];
}

class ArticleDetailError extends ArticleDetailState {
  final String message;
  const ArticleDetailError(this.message);
}
