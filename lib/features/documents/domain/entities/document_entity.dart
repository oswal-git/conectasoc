import 'package:equatable/equatable.dart';

/// Entidad que representa un documento subido al sistema
class DocumentEntity extends Equatable {
  final String id;
  final String urlDoc; // URL del documento en Cloudinary
  final String urlThumb; // URL del thumbnail en Cloudinary
  final String descDoc; // Descripción (máximo 200 caracteres)
  final bool canDownload; // Indica si se puede descargar
  final String associationId; // ID de la asociación ("Todas" para superadmin)
  final String categoryId; // ID de la categoría
  final String subcategoryId; // ID de la subcategoría
  final DateTime dateCreation;
  final DateTime dateModification;
  final String uploadedBy; // User ID del que subió el documento
  final String fileName; // Nombre original del archivo
  final String fileExtension; // Extensión del archivo (pdf, docx, xlsx)
  final int fileSize; // Tamaño en bytes

  const DocumentEntity({
    required this.id,
    required this.urlDoc,
    required this.urlThumb,
    required this.descDoc,
    this.canDownload = true,
    required this.associationId,
    required this.categoryId,
    required this.subcategoryId,
    required this.dateCreation,
    required this.dateModification,
    required this.uploadedBy,
    required this.fileName,
    required this.fileExtension,
    required this.fileSize,
  });

  DocumentEntity copyWith({
    String? id,
    String? urlDoc,
    String? urlThumb,
    String? descDoc,
    bool? canDownload,
    String? associationId,
    String? categoryId,
    String? subcategoryId,
    DateTime? dateCreation,
    DateTime? dateModification,
    String? uploadedBy,
    String? fileName,
    String? fileExtension,
    int? fileSize,
  }) {
    return DocumentEntity(
      id: id ?? this.id,
      urlDoc: urlDoc ?? this.urlDoc,
      urlThumb: urlThumb ?? this.urlThumb,
      descDoc: descDoc ?? this.descDoc,
      canDownload: canDownload ?? this.canDownload,
      associationId: associationId ?? this.associationId,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      fileName: fileName ?? this.fileName,
      fileExtension: fileExtension ?? this.fileExtension,
      fileSize: fileSize ?? this.fileSize,
    );
  }

  @override
  List<Object?> get props => [
        id,
        urlDoc,
        urlThumb,
        descDoc,
        canDownload,
        associationId,
        categoryId,
        subcategoryId,
        dateCreation,
        dateModification,
        uploadedBy,
        fileName,
        fileExtension,
        fileSize,
      ];

  /// Formatea el tamaño del archivo en formato legible
  String get formattedFileSize {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Retorna el icono apropiado según la extensión del archivo
  String get fileIcon {
    switch (fileExtension.toLowerCase()) {
      case 'pdf':
        return '📄';
      case 'doc':
      case 'docx':
        return '📝';
      case 'xls':
      case 'xlsx':
        return '📊';
      case 'ppt':
      case 'pptx':
        return '📽️';
      default:
        return '📎';
    }
  }

  static DocumentEntity empty() {
    return DocumentEntity(
      id: '',
      urlDoc: '',
      urlThumb: '',
      descDoc: '',
      canDownload: true,
      associationId: '',
      categoryId: '',
      subcategoryId: '',
      dateCreation: DateTime.now(),
      dateModification: DateTime.now(),
      uploadedBy: '',
      fileName: '',
      fileExtension: '',
      fileSize: 0,
    );
  }
}
