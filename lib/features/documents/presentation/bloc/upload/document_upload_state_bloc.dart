import 'dart:typed_data';

import 'package:conectasoc/features/articles/domain/entities/entities.dart';
import 'package:conectasoc/features/documents/domain/entities/document_entity.dart';
import 'package:equatable/equatable.dart';

/// Estados para el bloc de carga de documentos
abstract class DocumentUploadState extends Equatable {
  const DocumentUploadState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class DocumentUploadInitial extends DocumentUploadState {
  @override
  List<Object> get props => [];
}

/// Form is ready for input
class DocumentUploadReady extends DocumentUploadState {
  final String associationId;
  final String categoryId;
  final String subcategoryId;
  final String userId;
  final String description;
  final bool canDownload;
  final Uint8List? selectedFileBytes;
  final String? selectedFileName;
  final List<CategoryEntity> categories;
  final List<SubcategoryEntity> subcategories;

  const DocumentUploadReady({
    required this.associationId,
    required this.categoryId,
    required this.subcategoryId,
    required this.userId,
    this.description = '',
    this.canDownload = true,
    this.selectedFileBytes,
    this.selectedFileName,
    required this.categories,
    required this.subcategories,
  });

  DocumentUploadReady copyWith({
    String? associationId,
    String? categoryId,
    String? subcategoryId,
    String? userId,
    String? description,
    bool? canDownload,
    Uint8List? selectedFileBytes,
    String? selectedFileName,
    List<CategoryEntity>? categories,
    List<SubcategoryEntity>? subcategories,
    bool clearFile = false,
  }) {
    return DocumentUploadReady(
      associationId: associationId ?? this.associationId,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      userId: userId ?? this.userId,
      description: description ?? this.description,
      canDownload: canDownload ?? this.canDownload,
      selectedFileBytes:
          clearFile ? null : (selectedFileBytes ?? this.selectedFileBytes),
      selectedFileName:
          clearFile ? null : (selectedFileName ?? this.selectedFileName),
      categories: categories ?? this.categories,
      subcategories: subcategories ?? this.subcategories,
    );
  }

  /// Check if form is valid for submission
  bool get isValid =>
      selectedFileBytes != null &&
      selectedFileName != null &&
      description.trim().isNotEmpty &&
      description.length <= 200 &&
      categoryId.isNotEmpty &&
      subcategoryId.isNotEmpty;

  /// Get file extension
  String? get fileExtension => selectedFileName?.split('.').last.toLowerCase();

  /// Get file size in MB
  double? get fileSizeMB => selectedFileBytes != null
      ? selectedFileBytes!.length / (1024 * 1024)
      : null;

  @override
  List<Object?> get props => [
        associationId,
        categoryId,
        subcategoryId,
        userId,
        description,
        canDownload,
        selectedFileBytes,
        selectedFileName,
        categories,
        subcategories,
      ];
}

/// Estado de carga en progreso
class DocumentUploadInProgress extends DocumentUploadState {
  final double progress;

  const DocumentUploadInProgress(this.progress);

  @override
  List<Object?> get props => [progress];
}

/// Estado de carga exitosa
class DocumentUploadSuccess extends DocumentUploadState {
  final DocumentEntity document;

  const DocumentUploadSuccess(this.document);

  @override
  List<Object?> get props => [document];
}

/// Estado de error en la carga
class DocumentUploadFailure extends DocumentUploadState {
  final String error;

  const DocumentUploadFailure(this.error);

  @override
  List<Object?> get props => [error];
}

/// Estado de carga cancelada
class DocumentUploadCancelled extends DocumentUploadState {
  @override
  List<Object> get props => [];
}

/// Estado de limpieza del estado
class DocumentUploadCleared extends DocumentUploadState {
  @override
  List<Object> get props => [];
}
