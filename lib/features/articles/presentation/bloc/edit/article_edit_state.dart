import 'dart:io';

import 'package:conectasoc/features/articles/domain/entities/entities.dart';
import 'package:equatable/equatable.dart';

abstract class ArticleEditState extends Equatable {
  const ArticleEditState();

  @override
  List<Object?> get props => [];
}

class ArticleEditInitial extends ArticleEditState {}

class ArticleEditLoading extends ArticleEditState {}

class ArticleEditLoaded extends ArticleEditState {
  final ArticleEntity article;
  final List<CategoryEntity> categories;
  final List<SubcategoryEntity> subcategories;
  final bool isCreating;
  final bool isSaving;
  final String? Function()? errorMessage;
  final File? newCoverImageFile; // New field for cover image
  final ArticleStatus status; // New field for article status

  const ArticleEditLoaded({
    required this.article,
    required this.categories,
    required this.subcategories,
    this.isCreating = false,
    this.isSaving = false,
    this.errorMessage,
    this.newCoverImageFile,
    this.status = ArticleStatus.redaccion, // Default status
  });

  ArticleEditLoaded copyWith({
    ArticleEntity? article,
    List<CategoryEntity>? categories,
    List<SubcategoryEntity>? subcategories,
    bool? isCreating,
    bool? isSaving,
    String? Function()? errorMessage,
    File? newCoverImageFile,
    ArticleStatus? status,
  }) {
    return ArticleEditLoaded(
      article: article ?? this.article,
      categories: categories ?? this.categories,
      subcategories: subcategories ?? this.subcategories,
      isCreating: isCreating ?? this.isCreating,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      newCoverImageFile: newCoverImageFile ?? this.newCoverImageFile,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        article, categories, subcategories, isCreating, isSaving, errorMessage,
        newCoverImageFile, status, // Include new fields in props
      ];
}

class ArticleEditSuccess extends ArticleEditState {}

class ArticleEditFailure extends ArticleEditState {
  final String message;
  const ArticleEditFailure(this.message);
  @override
  List<Object> get props => [message];
}
