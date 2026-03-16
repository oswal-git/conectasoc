import 'package:equatable/equatable.dart';

abstract class ArticleDetailEvent extends Equatable {
  const ArticleDetailEvent();

  @override
  List<Object> get props => [];
}

class LoadArticleDetail extends ArticleDetailEvent {
  final String articleId;
  const LoadArticleDetail(this.articleId);

  @override
  List<Object> get props => [articleId];
}

/// Igual que LoadArticleDetail pero omite la caché en memoria,
/// forzando una lectura fresca desde Firestore.
class RefreshArticleDetail extends ArticleDetailEvent {
  final String articleId;
  const RefreshArticleDetail(this.articleId);

  @override
  List<Object> get props => [articleId];
}
