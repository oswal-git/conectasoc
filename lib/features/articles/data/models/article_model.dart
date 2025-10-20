import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conectasoc/features/articles/domain/entities/article_entity.dart';

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
    super.sections,
    required super.userId,
    required super.assocId,
    required super.authorName,
    super.authorAvatarUrl,
    required super.associationShortName,
    required super.status,
    required super.originalLanguage,
    required super.createdAt,
    required super.modifiedAt,
  });

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
      expirationDate: (data['expirationDate'] as Timestamp?)?.toDate(),
      sections: List<Map<String, dynamic>>.from(data['sections'] ?? []),
      userId: data['userId'] ?? '',
      assocId: data['assocId'] ?? '', // Convertir null a string vacío
      authorName: data['authorName'] ?? '',
      authorAvatarUrl: data['authorAvatarUrl'],
      associationShortName: data['associationShortName'] ?? '',
      status: ArticleStatus.values.firstWhere(
        (e) => e.value == data['status'],
        orElse: () => ArticleStatus.draft,
      ),
      originalLanguage: data['originalLanguage'] ?? 'es',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      modifiedAt: (data['modifiedAt'] as Timestamp).toDate(),
    );
  }
}

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.order,
  });

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      name: data['name'] ?? '',
      order: data['order'] ?? 0,
    );
  }
}

class SubcategoryModel extends SubcategoryEntity {
  const SubcategoryModel({
    required super.id,
    required super.name,
    required super.order,
    required super.categoryId,
  });

  factory SubcategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SubcategoryModel(
      id: doc.id,
      name: data['name'] ?? '',
      order: data['order'] ?? 0,
      categoryId: data['categoryId'] ?? '',
    );
  }
}
