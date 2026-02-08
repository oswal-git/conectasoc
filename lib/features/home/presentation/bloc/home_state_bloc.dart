import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'package:conectasoc/features/articles/domain/entities/entities.dart';
import 'package:conectasoc/features/associations/domain/entities/entities.dart';

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
  final String searchTerm;
  final bool isEditMode;
  final bool hasMore;
  final DocumentSnapshot<Object?>? lastDocument; // Firestore-specific cursor
  final bool isLoading;

  const HomeLoaded({
    required this.allArticles,
    required this.filteredArticles,
    required this.categories,
    required this.associations,
    this.subcategories = const [],
    this.selectedCategory,
    this.searchTerm = '',
    this.selectedSubcategory,
    this.isEditMode = false,
    this.hasMore = true,
    this.lastDocument,
    this.isLoading = false,
  });

  HomeLoaded copyWith({
    List<ArticleEntity>? allArticles,
    List<ArticleEntity>? filteredArticles,
    List<CategoryEntity>? categories,
    List<AssociationEntity>? associations,
    List<SubcategoryEntity>? subcategories,
    CategoryEntity? selectedCategory,
    SubcategoryEntity? selectedSubcategory,
    String? searchTerm,
    bool? isEditMode,
    bool? hasMore,
    DocumentSnapshot<Object?>? lastDocument,
    bool? isLoading,
  }) {
    return HomeLoaded(
      allArticles: allArticles ?? this.allArticles,
      filteredArticles: filteredArticles ?? this.filteredArticles,
      categories: categories ?? this.categories,
      associations: associations ?? this.associations,
      subcategories: subcategories ?? this.subcategories,
      selectedCategory: selectedCategory,
      selectedSubcategory: selectedSubcategory,
      searchTerm: searchTerm ?? this.searchTerm,
      isEditMode: isEditMode ?? this.isEditMode,
      hasMore: hasMore ?? this.hasMore,
      lastDocument: lastDocument,
      isLoading: isLoading ?? this.isLoading,
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
        searchTerm,
        isEditMode,
        hasMore,
        lastDocument,
        isLoading,
      ];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object> get props => [message];
}
