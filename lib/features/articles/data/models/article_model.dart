import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conectasoc/features/articles/domain/entities/article_entity.dart';

// Hereda de ArticleEntity para reutilizar la lógica de negocio y la igualdad.
class ArticleModel extends ArticleEntity {
  const ArticleModel({
    required super.id,
    required super.title,
    required super.abstractContent,
    required super.coverUrl,
    required super.categoryId,
    required super.subcategoryId,
    required super.publishDate,
    required super.effectiveDate,
    super.expirationDate,
    required super.status,
    required super.sections,
    required super.userId,
    required super.assocId,
    required super.authorName,
    super.authorAvatarUrl,
    required super.associationShortName,
    required super.originalLanguage,
    required super.createdAt,
    required super.modifiedAt,
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
      subcategoryId: data['subcategoryId'] ?? '',
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
                  ))
              .toList() ??
          [],
      userId: data['userId'] ?? '',
      assocId: data['assocId'] ?? '', // Asegura que nunca sea nulo
      authorName: data['authorName'] ?? '',
      authorAvatarUrl: data['authorAvatarUrl'],
      associationShortName: data['associationShortName'] ?? '',
      originalLanguage: data['originalLanguage'] ?? 'es',
      status: ArticleStatusExtension.fromValue(data['status'] ?? 'redaccion'),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      modifiedAt: (data['modifiedAt'] as Timestamp).toDate(),
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
      subcategoryId: entity.subcategoryId,
      publishDate: entity.publishDate,
      effectiveDate: entity.effectiveDate,
      expirationDate: entity.expirationDate,
      sections: entity.sections,
      userId: entity.userId,
      assocId: entity.assocId,
      authorName: entity.authorName,
      authorAvatarUrl: entity.authorAvatarUrl,
      associationShortName: entity.associationShortName,
      originalLanguage: entity.originalLanguage,
      status: entity.status,
      createdAt: entity.createdAt,
      modifiedAt: entity.modifiedAt,
    );
  }

  // Convierte un ArticleModel en un mapa para guardarlo en Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'abstractContent': abstractContent,
      'coverUrl': coverUrl,
      'categoryId': categoryId,
      'subcategoryId': subcategoryId,
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
              })
          .toList(),
      'userId': userId,
      'assocId': assocId,
      'authorName': authorName,
      'authorAvatarUrl': authorAvatarUrl,
      'associationShortName': associationShortName,
      'originalLanguage': originalLanguage,
      'status': status.value,
      'createdAt': Timestamp.fromDate(createdAt),
      'modifiedAt': Timestamp.fromDate(modifiedAt),
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
}
