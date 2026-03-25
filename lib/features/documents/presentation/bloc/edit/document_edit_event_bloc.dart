import 'package:equatable/equatable.dart';
import 'package:conectasoc/features/documents/domain/entities/entities.dart';

abstract class DocumentEditEvent extends Equatable {
  const DocumentEditEvent();

  @override
  List<Object?> get props => [];
}

class LoadDocumentForEdit extends DocumentEditEvent {
  final DocumentEntity document;
  final String associationId;

  const LoadDocumentForEdit({
    required this.document,
    required this.associationId,
  });

  @override
  List<Object?> get props => [document, associationId];
}

class EditDescriptionChanged extends DocumentEditEvent {
  final String description;
  const EditDescriptionChanged(this.description);

  @override
  List<Object?> get props => [description];
}

class EditCategoryChanged extends DocumentEditEvent {
  final String categoryId;
  const EditCategoryChanged(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class EditSubcategoryChanged extends DocumentEditEvent {
  final String subcategoryId;
  const EditSubcategoryChanged(this.subcategoryId);

  @override
  List<Object?> get props => [subcategoryId];
}

class EditDownloadPermissionChanged extends DocumentEditEvent {
  final bool canDownload;
  const EditDownloadPermissionChanged(this.canDownload);

  @override
  List<Object?> get props => [canDownload];
}

class SubmitDocumentEdit extends DocumentEditEvent {
  const SubmitDocumentEdit();
}
