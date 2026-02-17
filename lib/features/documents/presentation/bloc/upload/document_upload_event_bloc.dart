import 'dart:typed_data';
import 'package:equatable/equatable.dart';

/// Events for document upload
abstract class DocumentUploadEvent extends Equatable {
  const DocumentUploadEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize upload form
class InitializeUpload extends DocumentUploadEvent {
  final String associationId;
  final String categoryId;
  final String subcategoryId;
  final String userId;

  const InitializeUpload({
    required this.associationId,
    required this.categoryId,
    required this.subcategoryId,
    required this.userId,
  });

  @override
  List<Object?> get props => [associationId, categoryId, subcategoryId, userId];
}

/// User selected a file from device
class FileSelected extends DocumentUploadEvent {
  final Uint8List fileBytes;
  final String fileName;

  const FileSelected({
    required this.fileBytes,
    required this.fileName,
  });

  @override
  List<Object?> get props => [fileBytes, fileName];
}

/// User changed description
class DescriptionChanged extends DocumentUploadEvent {
  final String description;

  const DescriptionChanged(this.description);

  @override
  List<Object?> get props => [description];
}

/// User changed category
class CategoryChanged extends DocumentUploadEvent {
  final String categoryId;

  const CategoryChanged(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

/// User changed subcategory
class SubcategoryChanged extends DocumentUploadEvent {
  final String subcategoryId;

  const SubcategoryChanged(this.subcategoryId);

  @override
  List<Object?> get props => [subcategoryId];
}

/// User toggled download permission
class DownloadPermissionChanged extends DocumentUploadEvent {
  final bool canDownload;

  const DownloadPermissionChanged(this.canDownload);

  @override
  List<Object?> get props => [canDownload];
}

/// User clicked upload button
class SubmitDocumentUpload extends DocumentUploadEvent {
  const SubmitDocumentUpload();
}

/// Clear form and reset to initial state
class ResetUpload extends DocumentUploadEvent {
  const ResetUpload();
}
