 
// // Estados
// abstract class ArticlesState extends Equatable {
//   const ArticlesState();
  
//   @override
//   List<Object?> get props => [];
// }

// class ArticlesInitial extends ArticlesState {}

// class ArticlesLoading extends ArticlesState {}

// class ArticlesLoaded extends ArticlesState {
//   final List<ArticleEntity> articles;
//   final bool hasMore;
//   final bool isLoadingMore;
//   final String? selectedCategory;
//   final ArticleFilter filter;
  
//   const ArticlesLoaded({
//     required this.articles,
//     this.hasMore = false,
//     this.isLoadingMore = false,
//     this.selectedCategory,
//     required this.filter,
//   });
  
//   @override
//   List<Object?> get props => [
//     articles, hasMore, isLoadingMore, selectedCategory, filter
//   ];
  
//   ArticlesLoaded copyWith({
//     List<ArticleEntity>? articles,
//     bool? hasMore,
//     bool? isLoadingMore,
//     String? selectedCategory,
//     ArticleFilter? filter,
//   }) {
//     return ArticlesLoaded(
//       articles: articles ?? this.articles,
//       hasMore: hasMore ?? this.hasMore,
//       isLoadingMore: isLoadingMore ?? this.isLoadingMore,
//       selectedCategory: selectedCategory ?? this.selectedCategory,
//       filter: filter ?? this.filter,
//     );
//   }
// }

// class ArticlesError extends ArticlesState {
//   final String message;
//   final List<ArticleEntity>? cachedArticles;
  
//   const ArticlesError(this.message, {this.cachedArticles});
  
//   @override
//   List<Object?> get props => [message, cachedArticles];
// }

// // Eventos
// abstract class ArticlesEvent extends Equatable {
//   const ArticlesEvent();
  
//   @override
//   List<Object?> get props => [];
// }

// class ArticlesLoadRequested extends ArticlesEvent {
//   final bool refresh;
//   final ArticleFilter filter;
  
//   const ArticlesLoadRequested({
//     this.refresh = false,
//     this.filter = const ArticleFilter(),
//   });
  
//   @override
//   List<Object?> get props => [refresh, filter];
// }

// class ArticlesLoadMoreRequested extends ArticlesEvent {}

// class ArticlesFilterChanged extends ArticlesEvent {
//   final ArticleFilter filter;
  
//   const ArticlesFilterChanged(this.filter);
  
//   @override
//   List<Object?> get props => [filter];
// }

// class ArticleCreated extends ArticlesEvent {
//   final ArticleEntity article;
  
//   const ArticleCreated(this.article);
  
//   @override
//   List<Object?> get props => [article];
// }

// class ArticleUpdated extends ArticlesEvent {
//   final ArticleEntity article;
  
//   const ArticleUpdated(this.article);
  
//   @override
//   List<Object?> get props => [article];
// }

// class ArticleDeleted extends ArticlesEvent {
//   final String articleId;
  
//   const ArticleDeleted(this.articleId);
  
//   @override