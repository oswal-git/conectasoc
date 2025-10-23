import 'package:equatable/equatable.dart';

class ArticleFilter extends Equatable {
  final String? categoryId;
  final String? subcategoryId;
  final String? searchTerm;

  const ArticleFilter({
    this.categoryId,
    this.subcategoryId,
    this.searchTerm,
  });

  ArticleFilter copyWith({
    String? categoryId,
    String? subcategoryId,
    String? searchTerm,
  }) {
    return ArticleFilter(
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      searchTerm: searchTerm ?? this.searchTerm,
    );
  }

  @override
  List<Object?> get props => [categoryId, subcategoryId, searchTerm];
}
