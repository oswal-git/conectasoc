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
  final ArticleEntity? initialArticle;
  final List<CategoryEntity> categories;
  final List<SubcategoryEntity> subcategories;
  final bool isCreating;
  final bool isSaving;
  final String? Function()? errorMessage;
  final Uint8List? newCoverImageBytes;
  final ArticleStatus status; // New field for article status
  final Map<String, Uint8List> newSectionImageBytes;
  final bool isArticleValid;
  final bool isPreviewMode;
  final int titleCharCount;
  final int abstractCharCount;
  final bool canEditContent;
  final List<String> imagesToDelete; // Para rastrear imágenes a borrar

  const ArticleEditLoaded({
    required this.article,
    this.initialArticle,
    required this.categories,
    required this.subcategories,
    this.newSectionImageBytes = const {},
    this.isCreating = false,
    this.isSaving = false,
    this.errorMessage,
    this.newCoverImageBytes,
    this.status = ArticleStatus.redaccion, // Default status
    this.isPreviewMode = false,
    this.isArticleValid = false,
    this.titleCharCount = 0,
    this.abstractCharCount = 0,
    this.canEditContent = true,
    this.imagesToDelete = const [],
  });

  bool get isDirty {
    if (newCoverImageBytes != null) return true;
    if (newSectionImageBytes.isNotEmpty) return true;
    if (imagesToDelete.isNotEmpty) return true;
    if (initialArticle == null) return false;
    return article != initialArticle;
  }

  ArticleEditLoaded copyWith({
    ArticleEntity? article,
    ArticleEntity? initialArticle,
    List<CategoryEntity>? categories,
    List<SubcategoryEntity>? subcategories,
    bool? isCreating,
    bool? isSaving,
    String? Function()? errorMessage,
    Uint8List? newCoverImageBytes,
    ArticleStatus? status,
    Map<String, Uint8List>? newSectionImageBytes,
    bool? isArticleValid,
    bool? isPreviewMode,
    int? titleCharCount,
    int? abstractCharCount,
    bool? canEditContent,
    List<String>? imagesToDelete,
  }) {
    return ArticleEditLoaded(
      article: article ?? this.article,
      initialArticle: initialArticle ?? this.initialArticle,
      categories: categories ?? this.categories,
      subcategories: subcategories ?? this.subcategories,
      isCreating: isCreating ?? this.isCreating,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      newCoverImageBytes: newCoverImageBytes ?? this.newCoverImageBytes,
      status: status ?? this.status,
      newSectionImageBytes: newSectionImageBytes ?? this.newSectionImageBytes,
      isArticleValid: isArticleValid ?? this.isArticleValid,
      isPreviewMode: isPreviewMode ?? this.isPreviewMode,
      titleCharCount: titleCharCount ?? this.titleCharCount,
      abstractCharCount: abstractCharCount ?? this.abstractCharCount,
      canEditContent: canEditContent ?? this.canEditContent,
      imagesToDelete: imagesToDelete ?? this.imagesToDelete,
    );
  }

  @override
  List<Object?> get props => [
        article,
        initialArticle,
        categories,
        subcategories,
        isCreating,
        isSaving,
        errorMessage,
        newCoverImageBytes,
        status,
        newSectionImageBytes,
        isArticleValid,
        isPreviewMode,
        titleCharCount,
        abstractCharCount,
        canEditContent,
        imagesToDelete,
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

class ArticleEditSuccess extends ArticleEditState {
  final bool isCreating;

  const ArticleEditSuccess({this.isCreating = false});

  @override
  List<Object?> get props => [isCreating];
}

class ArticleEditFailure extends ArticleEditState {
  final String message;
  const ArticleEditFailure(this.message);
  @override
  List<Object> get props => [message];
}
