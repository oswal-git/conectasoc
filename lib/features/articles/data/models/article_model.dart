import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conectasoc/features/articles/domain/entities/entities.dart';
import 'package:conectasoc/features/documents/domain/entities/document_link_entity.dart';

// Hereda de ArticleEntity para reutilizar la lógica de negocio y la igualdad.
class ArticleModel extends ArticleEntity {
  const ArticleModel({
    required super.id,
    required super.title,
    required super.abstractContent,
    required super.coverUrl,
    required super.categoryId,
    required super.categoryName,
    required super.subcategoryId,
    required super.subcategoryName,
    required super.publishDate,
    required super.effectiveDate,
    super.expirationDate,
    super.status,
    super.fechaNotificacion,
    required super.sections,
    required super.userId,
    required super.assocId,
    required super.authorName,
    required super.associationShortName,
    required super.originalLanguage,
    required super.createdAt,
    required super.modifiedAt,
    super.documentLink,
  });

  // Convierte un documento de Firestore en un ArticleModel
  factory ArticleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ArticleModel(
      id: doc.id,
      title: data['title'] ?? '',
      abstractContent: data['abstractContent'] ?? '',
      coverUrl: data['coverUrl'] ?? '',
      categoryId: data['categoryId'] ?? '',
      categoryName: data['categoryName'] ?? '',
      subcategoryId: data['subcategoryId'] ?? '',
      subcategoryName: data['subcategoryName'] ?? '',
      publishDate: (data['publishDate'] as Timestamp).toDate(),
      effectiveDate: (data['effectiveDate'] as Timestamp).toDate(),
      expirationDate: data['expirationDate'] != null
          ? (data['expirationDate'] as Timestamp).toDate()
          : null,
      sections: (data['sections'] as List<dynamic>?)
              ?.map((s) => ArticleSection(
                    id: s['id'] ?? '',
                    imageUrl: s['imageUrl'],
                    richTextContent: s['richTextContent'],
                    order: s['order'] ?? 0,
                    // ✨ Parsear documentLink de la sección
                    documentLink: s['documentLink'] != null
                        ? DocumentLinkEntity.fromJson(
                            s['documentLink'] as Map<String, dynamic>)
                        : null,
                  ))
              .toList() ??
          [],
      userId: data['userId'] ?? '',
      assocId: data['assocId'] ?? '', // Asegura que nunca sea nulo
      authorName: data['authorName'] ?? '',
      associationShortName: data['associationShortName'] ?? '',
      originalLanguage: data['originalLanguage'] ?? 'es',
      status: ArticleStatusExtension.fromValue(data['status'] ?? 'redaccion'),
      fechaNotificacion: data['fechaNotificacion'] != null
          ? (data['fechaNotificacion'] as Timestamp).toDate()
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      modifiedAt: (data['modifiedAt'] as Timestamp).toDate(),
      documentLink: data['documentLink'] != null
          ? DocumentLinkEntity.fromJson(
              data['documentLink'] as Map<String, dynamic>)
          : null,
    );
  }

  // Convierte una ArticleEntity en un ArticleModel
  factory ArticleModel.fromEntity(ArticleEntity entity) {
    return ArticleModel(
      id: entity.id,
      title: entity.title,
      abstractContent: entity.abstractContent,
      coverUrl: entity.coverUrl,
      categoryId: entity.categoryId,
      categoryName: entity.categoryName,
      subcategoryId: entity.subcategoryId,
      subcategoryName: entity.subcategoryName,
      publishDate: entity.publishDate,
      effectiveDate: entity.effectiveDate,
      expirationDate: entity.expirationDate,
      sections: entity.sections,
      userId: entity.userId,
      assocId: entity.assocId,
      authorName: entity.authorName,
      associationShortName: entity.associationShortName,
      originalLanguage: entity.originalLanguage,
      status: entity.status,
      fechaNotificacion: entity.fechaNotificacion,
      createdAt: entity.createdAt,
      modifiedAt: entity.modifiedAt,
      documentLink: entity.documentLink,
    );
  }

  // Convierte un ArticleModel en un mapa para guardarlo en Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'abstractContent': abstractContent,
      'coverUrl': coverUrl,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'subcategoryId': subcategoryId,
      'subcategoryName': subcategoryName,
      'publishDate': Timestamp.fromDate(publishDate),
      'effectiveDate': Timestamp.fromDate(effectiveDate),
      'expirationDate':
          expirationDate != null ? Timestamp.fromDate(expirationDate!) : null,
      'sections': sections
          .map((s) => {
                'id': s.id,
                'imageUrl': s.imageUrl,
                'richTextContent': s.richTextContent,
                'order': s.order,
                'documentLink': s.documentLink?.toJson(),
              })
          .toList(),
      'userId': userId,
      'assocId': assocId,
      'authorName': authorName,
      'associationShortName': associationShortName,
      'originalLanguage': originalLanguage,
      'status': status.value,
      'fechaNotificacion': fechaNotificacion != null
          ? Timestamp.fromDate(fechaNotificacion!)
          : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'modifiedAt': Timestamp.fromDate(modifiedAt),
      'documentLink': documentLink?.toJson(),
      // Campo para búsquedas de texto. Se convierte el título y el resumen
      // en un array de palabras en minúsculas para poder usar 'array-contains'.
      'searchText':
          '${title.toLowerCase()} ${abstractContent.toLowerCase()} ${sections.map((s) => s.richTextContent?.toLowerCase() ?? '').join(' ')}'
              .split(RegExp(r'\s+'))
              .where((s) => s.isNotEmpty)
              .toSet() // Elimina duplicados
              .toList(),
    };
  }

  // Added for consistency with fromJson in ArticleEntity, useful for local storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'abstractContent': abstractContent,
      'coverUrl': coverUrl,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'subcategoryId': subcategoryId,
      'subcategoryName': subcategoryName,
      'publishDate': publishDate.toIso8601String(),
      'effectiveDate': effectiveDate.toIso8601String(),
      'expirationDate': expirationDate?.toIso8601String(),
      'status': status.value,
      'fechaNotificacion': fechaNotificacion?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
      'documentLink': documentLink?.toJson(),
    };
  }

  @override
  ArticleModel copyWith({
    String? id,
    String? title,
    String? abstractContent,
    String? coverUrl,
    String? categoryId,
    String? categoryName,
    String? subcategoryId,
    String? subcategoryName,
    DateTime? publishDate,
    DateTime? effectiveDate,
    DateTime? expirationDate,
    ArticleStatus? status,
    DateTime? fechaNotificacion,
    List<ArticleSection>? sections,
    String? userId,
    String? assocId,
    String? authorName,
    String? associationShortName,
    String? originalLanguage,
    DateTime? createdAt,
    DateTime? modifiedAt,
    DocumentLinkEntity? documentLink,
    bool clearDocumentLink = false,
    bool clearExpirationDate = false,
    bool clearFechaNotificacion = false,
  }) {
    return ArticleModel(
      id: id ?? this.id,
      title: title ?? this.title,
      abstractContent: abstractContent ?? this.abstractContent,
      coverUrl: coverUrl ?? this.coverUrl,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      subcategoryName: subcategoryName ?? this.subcategoryName,
      publishDate: publishDate ?? this.publishDate,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      expirationDate:
          clearExpirationDate ? null : (expirationDate ?? this.expirationDate),
      status: status ?? this.status,
      fechaNotificacion: clearFechaNotificacion
          ? null
          : (fechaNotificacion ?? this.fechaNotificacion),
      sections: sections ?? this.sections,
      userId: userId ?? this.userId,
      assocId: assocId ?? this.assocId,
      authorName: authorName ?? this.authorName,
      associationShortName: associationShortName ?? this.associationShortName,
      originalLanguage: originalLanguage ?? this.originalLanguage,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      documentLink:
          clearDocumentLink ? null : (documentLink ?? this.documentLink),
    );
  }
}
