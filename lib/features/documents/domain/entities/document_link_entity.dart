import 'package:equatable/equatable.dart';

/// Entidad que representa un enlace a un documento
/// Se usa en ArticleEntity y ArticleSection para referenciar documentos
class DocumentLinkEntity extends Equatable {
  final String documentId; // ID del documento en la colección 'documents'
  final String description; // Copia local de la descripción
  final String urlThumb; // Copia local del thumbnail
  final String urlDoc; // Copia local de la URL del documento
  final String fileExtension; // Extensión del archivo

  const DocumentLinkEntity({
    required this.documentId,
    required this.description,
    required this.urlThumb,
    required this.urlDoc,
    required this.fileExtension,
  });

  DocumentLinkEntity copyWith({
    String? documentId,
    String? description,
    String? urlThumb,
    String? urlDoc,
    String? fileExtension,
  }) {
    return DocumentLinkEntity(
      documentId: documentId ?? this.documentId,
      description: description ?? this.description,
      urlThumb: urlThumb ?? this.urlThumb,
      urlDoc: urlDoc ?? this.urlDoc,
      fileExtension: fileExtension ?? this.fileExtension,
    );
  }

  /// Crea un DocumentLinkEntity desde un DocumentEntity
  factory DocumentLinkEntity.fromDocument(
    String documentId,
    String urlDoc,
    String urlThumb,
    String description,
    String fileExtension,
  ) {
    return DocumentLinkEntity(
      documentId: documentId,
      description: description,
      urlThumb: urlThumb,
      urlDoc: urlDoc,
      fileExtension: fileExtension,
    );
  }

  /// Convierte a JSON para Firestore
  Map<String, dynamic> toJson() {
    return {
      'documentId': documentId,
      'description': description,
      'urlThumb': urlThumb,
      'urlDoc': urlDoc,
      'fileExtension': fileExtension,
    };
  }

  /// Crea desde JSON de Firestore
  factory DocumentLinkEntity.fromJson(Map<String, dynamic> json) {
    return DocumentLinkEntity(
      documentId: json['documentId'] ?? '',
      description: json['description'] ?? '',
      urlThumb: json['urlThumb'] ?? '',
      urlDoc: json['urlDoc'] ?? '',
      fileExtension: json['fileExtension'] ?? '',
    );
  }

  @override
  List<Object?> get props => [
        documentId,
        description,
        urlThumb,
        urlDoc,
        fileExtension,
      ];

  static DocumentLinkEntity empty() {
    return const DocumentLinkEntity(
      documentId: '',
      description: '',
      urlThumb: '',
      urlDoc: '',
      fileExtension: '',
    );
  }
}
