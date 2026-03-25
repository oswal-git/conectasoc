import 'package:equatable/equatable.dart';
import 'package:conectasoc/features/articles/domain/entities/entities.dart';
import 'package:conectasoc/features/documents/domain/entities/entities.dart';

abstract class DocumentEditState extends Equatable {
  const DocumentEditState();

  @override
  List<Object?> get props => [];
}

class DocumentEditInitial extends DocumentEditState {}

class DocumentEditLoading extends DocumentEditState {}

class DocumentEditReady extends DocumentEditState {
  final DocumentEntity originalDocument;
  final String description;
  final String categoryId;
  final String subcategoryId;
  final bool canDownload;
  
  final List<CategoryEntity> categories;
  final List<SubcategoryEntity> subcategories;
  final String associationId;

  const DocumentEditReady({
    required this.originalDocument,
    required this.description,
    required this.categoryId,
    required this.subcategoryId,
    required this.canDownload,
    required this.categories,
    required this.subcategories,
    required this.associationId,
  });

  bool get hasChanges {
    return description != originalDocument.descDoc ||
        categoryId != originalDocument.categoryId ||
        subcategoryId != originalDocument.subcategoryId ||
        canDownload != originalDocument.canDownload;
  }

  DocumentEditReady copyWith({
    String? description,
    String? categoryId,
    String? subcategoryId,
    bool? canDownload,
    List<CategoryEntity>? categories,
    List<SubcategoryEntity>? subcategories,
  }) {
    return DocumentEditReady(
      originalDocument: originalDocument,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      canDownload: canDownload ?? this.canDownload,
      categories: categories ?? this.categories,
      subcategories: subcategories ?? this.subcategories,
      associationId: associationId,
    );
  }

  @override
  List<Object?> get props => [
        originalDocument,
        description,
        categoryId,
        subcategoryId,
        canDownload,
        categories,
        subcategories,
        associationId,
      ];
}

class DocumentEditSubmitting extends DocumentEditState {
  final double progress;
  const DocumentEditSubmitting(this.progress);

  @override
  List<Object?> get props => [progress];
}

class DocumentEditSuccess extends DocumentEditState {
  final DocumentEntity document;
  const DocumentEditSuccess(this.document);

  @override
  List<Object?> get props => [document];
}

class DocumentEditFailure extends DocumentEditState {
  final String message;
  const DocumentEditFailure(this.message);

  @override
  List<Object?> get props => [message];
}
