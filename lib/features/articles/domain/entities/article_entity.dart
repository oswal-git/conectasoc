import 'package:equatable/equatable.dart';

enum ArticleStatus {
  draft,
  published,
  inReview,
  expired,
  cancelled,
}

extension ArticleStatusExtension on ArticleStatus {
  String get value {
    switch (this) {
      case ArticleStatus.draft:
        return 'redacción';
      case ArticleStatus.published:
        return 'publicado';
      case ArticleStatus.inReview:
        return 'revisión';
      case ArticleStatus.expired:
        return 'expirado';
      case ArticleStatus.cancelled:
        return 'anulado';
      // ignore: unreachable_switch_default
      default:
        return 'desconocido';
    }
  }
}

class ArticleEntity extends Equatable {
  final String id;
  final String title; // Rich text (JSON string)
  final String abstractContent; // Rich text (JSON string)
  final String coverUrl;
  final String categoryId;
  final String subcategoryId;
  final DateTime publishDate;
  final DateTime effectiveDate;
  final DateTime? expirationDate;
  final List<Map<String, dynamic>> sections; // Array of sections

  // Metadata
  final String userId; // Creator's UID
  final String assocId;
  final String authorName;
  final String? authorAvatarUrl;
  final String associationShortName;
  final ArticleStatus status;
  final String originalLanguage;
  final DateTime createdAt;
  final DateTime modifiedAt;

  const ArticleEntity({
    required this.id,
    required this.title,
    required this.abstractContent,
    required this.coverUrl,
    required this.categoryId,
    required this.subcategoryId,
    required this.publishDate,
    required this.effectiveDate,
    this.expirationDate,
    this.sections = const [],
    required this.userId,
    required this.assocId,
    required this.authorName,
    this.authorAvatarUrl,
    required this.associationShortName,
    required this.status,
    required this.originalLanguage,
    required this.createdAt,
    required this.modifiedAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        abstractContent,
        coverUrl,
        categoryId,
        subcategoryId,
        publishDate,
        effectiveDate,
        expirationDate,
        sections,
        userId,
        assocId,
        authorName,
        authorAvatarUrl,
        associationShortName,
        status,
        originalLanguage,
        createdAt,
        modifiedAt,
      ];
}

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final int order;

  const CategoryEntity(
      {required this.id, required this.name, required this.order});

  @override
  List<Object?> get props => [id, name, order];
}

class SubcategoryEntity extends CategoryEntity {
  final String categoryId;

  const SubcategoryEntity(
      {required super.id,
      required super.name,
      required super.order,
      required this.categoryId});

  @override
  List<Object?> get props => [id, name, order, categoryId];
}
