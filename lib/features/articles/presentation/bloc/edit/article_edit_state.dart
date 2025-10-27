import 'dart:typed_data';

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
  final Uint8List? newCoverImageBytes;
  final ArticleStatus status; // New field for article status
  final Map<String, Uint8List> newSectionImageBytes;
  final bool isPreviewMode;
  final int titleCharCount;
  final int abstractCharCount;

  const ArticleEditLoaded({
    required this.article,
    required this.categories,
    required this.subcategories,
    this.newSectionImageBytes = const {},
    this.isCreating = false,
    this.isSaving = false,
    this.errorMessage,
    this.newCoverImageBytes,
    this.status = ArticleStatus.redaccion, // Default status
    this.isPreviewMode = false,
    this.titleCharCount = 0,
    this.abstractCharCount = 0,
  });

  ArticleEditLoaded copyWith({
    ArticleEntity? article,
    List<CategoryEntity>? categories,
    List<SubcategoryEntity>? subcategories,
    bool? isCreating,
    bool? isSaving,
    String? Function()? errorMessage,
    Uint8List? newCoverImageBytes,
    ArticleStatus? status,
    Map<String, Uint8List>? newSectionImageBytes,
    bool? isPreviewMode,
    int? titleCharCount,
    int? abstractCharCount,
  }) {
    return ArticleEditLoaded(
      article: article ?? this.article,
      categories: categories ?? this.categories,
      subcategories: subcategories ?? this.subcategories,
      isCreating: isCreating ?? this.isCreating,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      newCoverImageBytes: newCoverImageBytes ?? this.newCoverImageBytes,
      status: status ?? this.status,
      newSectionImageBytes: newSectionImageBytes ?? this.newSectionImageBytes,
      isPreviewMode: isPreviewMode ?? this.isPreviewMode,
      titleCharCount: titleCharCount ?? this.titleCharCount,
      abstractCharCount: abstractCharCount ?? this.abstractCharCount,
    );
  }

  @override
  List<Object?> get props => [
        article,
        categories,
        subcategories,
        isCreating,
        isSaving,
        errorMessage,
        newCoverImageBytes,
        status,
        newSectionImageBytes,
        isPreviewMode,
        titleCharCount,
        abstractCharCount,
      ];
}

class ArticleEditDraftFound extends ArticleEditState {
  final ArticleEntity originalArticle;
  final ArticleEntity draftArticle;

  const ArticleEditDraftFound({
    required this.originalArticle,
    required this.draftArticle,
  });

  @override
  List<Object?> get props => [
        originalArticle,
        draftArticle,
      ];
}

class ArticleEditSuccess extends ArticleEditState {}

class ArticleEditFailure extends ArticleEditState {
  final String message;
  const ArticleEditFailure(this.message);
  @override
  List<Object> get props => [message];
}
