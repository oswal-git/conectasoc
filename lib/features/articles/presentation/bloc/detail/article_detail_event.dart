import 'package:equatable/equatable.dart';

abstract class ArticleDetailEvent extends Equatable {
  const ArticleDetailEvent();

  @override
  List<Object> get props => [];
}

class LoadArticleDetail extends ArticleDetailEvent {
  final String articleId;
  const LoadArticleDetail(this.articleId);
}
