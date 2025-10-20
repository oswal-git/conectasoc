import 'package:conectasoc/features/articles/domain/entities/entities.dart';
import 'package:conectasoc/features/associations/domain/entities/entities.dart';
import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<ArticleEntity> allArticles;
  final List<ArticleEntity> filteredArticles;
  final List<CategoryEntity> categories;
  final List<AssociationEntity> associations;
  final List<SubcategoryEntity> subcategories;
  final CategoryEntity? selectedCategory;
  final SubcategoryEntity? selectedSubcategory;
  final bool isEditMode;

  const HomeLoaded({
    required this.allArticles,
    required this.filteredArticles,
    required this.categories,
    required this.associations,
    this.subcategories = const [],
    this.selectedCategory,
    this.selectedSubcategory,
    this.isEditMode = false,
  });

  HomeLoaded copyWith({
    List<ArticleEntity>? allArticles,
    List<ArticleEntity>? filteredArticles,
    List<CategoryEntity>? categories,
    List<AssociationEntity>? associations,
    List<SubcategoryEntity>? subcategories,
    CategoryEntity? selectedCategory,
    SubcategoryEntity? selectedSubcategory,
    bool? isEditMode,
  }) {
    return HomeLoaded(
      allArticles: allArticles ?? this.allArticles,
      filteredArticles: filteredArticles ?? this.filteredArticles,
      categories: categories ?? this.categories,
      associations: associations ?? this.associations,
      subcategories: subcategories ?? this.subcategories,
      selectedCategory: selectedCategory,
      selectedSubcategory: selectedSubcategory,
      isEditMode: isEditMode ?? this.isEditMode,
    );
  }

  @override
  List<Object?> get props => [
        allArticles,
        filteredArticles,
        categories,
        associations,
        subcategories,
        selectedCategory,
        selectedSubcategory,
        isEditMode
      ];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object> get props => [message];
}
