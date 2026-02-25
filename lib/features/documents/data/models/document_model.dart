import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conectasoc/features/documents/domain/entities/document_entity.dart';

class DocumentModel extends DocumentEntity {
  const DocumentModel({
    required super.id,
    required super.publicId,
    required super.urlDoc,
    required super.urlThumb,
    required super.descDoc,
    required super.canDownload,
    required super.associationId,
    required super.categoryId,
    required super.subcategoryId,
    required super.dateCreation,
    required super.dateModification,
    required super.uploadedBy,
    required super.fileName,
    required super.fileExtension,
    required super.fileSize,
    required super.readScope,
  });

  /// Convierte un documento de Firestore en un DocumentModel
  factory DocumentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DocumentModel(
      id: doc.id,
      publicId: data['publicId'] ?? '',
      urlDoc: data['urlDoc'] ?? '',
      urlThumb: data['urlThumb'] ?? '',
      descDoc: data['descDoc'] ?? '',
      canDownload: data['canDownload'] ?? true,
      associationId: data['associationId'] ?? '',
      categoryId: data['categoryId'] ?? '',
      subcategoryId: data['subcategoryId'] ?? '',
      dateCreation: (data['dateCreation'] as Timestamp).toDate(),
      dateModification: (data['dateModification'] as Timestamp).toDate(),
      uploadedBy: data['uploadedBy'] ?? '',
      fileName: data['fileName'] ?? '',
      fileExtension: data['fileExtension'] ?? '',
      fileSize: data['fileSize'] ?? 0,
      readScope: ReadScopeExtension.fromValue(
          data['readScope'] ?? 'asociado'), // ✨ NUEVO
    );
  }

  /// Convierte una DocumentEntity en un DocumentModel
  factory DocumentModel.fromEntity(DocumentEntity entity) {
    return DocumentModel(
      id: entity.id,
      publicId: entity.publicId,
      urlDoc: entity.urlDoc,
      urlThumb: entity.urlThumb,
      descDoc: entity.descDoc,
      canDownload: entity.canDownload,
      associationId: entity.associationId,
      categoryId: entity.categoryId,
      subcategoryId: entity.subcategoryId,
      dateCreation: entity.dateCreation,
      dateModification: entity.dateModification,
      uploadedBy: entity.uploadedBy,
      fileName: entity.fileName,
      fileExtension: entity.fileExtension,
      fileSize: entity.fileSize,
      readScope: entity.readScope,
    );
  }

  /// Convierte un DocumentModel en un mapa para guardarlo en Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'publicId': publicId,
      'urlDoc': urlDoc,
      'urlThumb': urlThumb,
      'descDoc': descDoc,
      'canDownload': canDownload,
      'associationId': associationId,
      'categoryId': categoryId,
      'subcategoryId': subcategoryId,
      'dateCreation': Timestamp.fromDate(dateCreation),
      'dateModification': Timestamp.fromDate(dateModification),
      'uploadedBy': uploadedBy,
      'fileName': fileName,
      'fileExtension': fileExtension,
      'fileSize': fileSize,
      'readScope': readScope.value, // ✨ NUEVO
      // Campo para búsquedas de texto
      'searchText': '${descDoc.toLowerCase()} ${fileName.toLowerCase()}'
          .split(RegExp(r'\s+'))
          .where((s) => s.isNotEmpty)
          .toSet()
          .toList(),
    };
  }

  /// Convierte a entidad de dominio
  DocumentEntity toEntity() {
    return DocumentEntity(
      id: id,
      publicId: publicId,
      urlDoc: urlDoc,
      urlThumb: urlThumb,
      descDoc: descDoc,
      canDownload: canDownload,
      associationId: associationId,
      categoryId: categoryId,
      subcategoryId: subcategoryId,
      dateCreation: dateCreation,
      dateModification: dateModification,
      uploadedBy: uploadedBy,
      fileName: fileName,
      fileExtension: fileExtension,
      fileSize: fileSize,
      readScope: readScope,
    );
  }

  @override
  DocumentModel copyWith({
    String? id,
    String? publicId,
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
    ReadScope? readScope,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      publicId: publicId ?? this.publicId,
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
      readScope: readScope ?? this.readScope,
    );
  }
}
