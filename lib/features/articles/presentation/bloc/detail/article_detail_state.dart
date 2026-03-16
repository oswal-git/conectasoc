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
  // true mientras la traducción de secciones está en curso
  final bool isTranslating;

  const ArticleDetailLoaded(this.article, {this.isTranslating = false});

  ArticleDetailLoaded copyWith({
    ArticleEntity? article,
    bool? isTranslating,
  }) =>
      ArticleDetailLoaded(
        article ?? this.article,
        isTranslating: isTranslating ?? this.isTranslating,
      );

  @override
  List<Object> get props => [article, isTranslating];
}

class ArticleDetailError extends ArticleDetailState {
  final String message;
  const ArticleDetailError(this.message);
}
