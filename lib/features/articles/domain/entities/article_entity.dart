import 'package:conectasoc/features/articles/domain/entities/entities.dart';
import 'package:equatable/equatable.dart';

enum ArticleStatus {
  redaccion, // draft
  publicado, // published
  revision, // review
  expirado, // expired
  anulado, // cancelled
}

extension ArticleStatusExtension on ArticleStatus {
  /// Devuelve el valor en string para ser guardado en la base de datos.
  String get value {
    return toString().split('.').last;
  }

  /// Crea un ArticleStatus a partir de un string de la base de datos.
  static ArticleStatus fromValue(String value) {
    return ArticleStatus.values.firstWhere(
      (e) => e.value == value, // Use the new Spanish values
      orElse: () => ArticleStatus.redaccion, // Valor por defecto seguro
    );
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
  final DateTime? expirationDate; // Puede ser nulo
  final ArticleStatus status;
  final List<ArticleSection> sections; // List of sections

  // Metadata
  final String userId; // Creator's UID
  final String assocId; // Usar '' para artículos genéricos, no null.
  final String authorName;
  final String? authorAvatarUrl;
  final String associationShortName;
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
    required this.status,
    this.sections = const [],
    required this.userId, // ID del creador
    required this.assocId,
    required this.authorName,
    this.authorAvatarUrl,
    required this.associationShortName,
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
        originalLanguage,
        createdAt,
        modifiedAt,
      ];

  // Constructor 'empty' para la creación de nuevos artículos
  static ArticleEntity empty() {
    final now = DateTime.now();
    return ArticleEntity(
      id: '',
      title: '',
      abstractContent: '',
      coverUrl: '',
      categoryId: '',
      subcategoryId: '',
      publishDate: now,
      effectiveDate: now,
      status: ArticleStatus.redaccion,
      expirationDate: null,
      sections: const [],
      userId: '',
      assocId: '', // Por defecto es un artículo genérico
      authorName: '',
      authorAvatarUrl: null,
      associationShortName: '',
      originalLanguage: 'es',
      createdAt: now,
      modifiedAt: now, // Default status is 'redaccion'
    );
  }

  factory ArticleEntity.fromJson(Map<String, dynamic> json) {
    return ArticleEntity(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      abstractContent: json['abstractContent'] ?? '',
      coverUrl: json['coverUrl'] ?? '',
      categoryId: json['categoryId'] ?? '',
      subcategoryId: json['subcategoryId'] ?? '',
      publishDate: DateTime.parse(json['publishDate']),
      effectiveDate: DateTime.parse(json['effectiveDate']),
      expirationDate: json['expirationDate'] != null
          ? DateTime.parse(json['expirationDate'])
          : null,
      status: ArticleStatusExtension.fromValue(json['status'] ?? 'redaccion'),
      sections: (json['sections'] as List<dynamic>?)
              ?.map((s) => ArticleSection.fromJson(s))
              .toList() ??
          [],
      userId: json['userId'] ?? '',
      assocId: json['assocId'] ?? '',
      authorName: json['authorName'] ?? '',
      authorAvatarUrl: json['authorAvatarUrl'],
      associationShortName: json['associationShortName'] ?? '',
      originalLanguage: json['originalLanguage'] ?? 'es',
      createdAt: DateTime.parse(json['createdAt']),
      modifiedAt: DateTime.parse(json['modifiedAt']),
    );
  }

  ArticleEntity copyWith({
    String? id,
    String? title,
    String? abstractContent,
    String? coverUrl,
    String? categoryId,
    String? subcategoryId,
    DateTime? publishDate,
    DateTime? effectiveDate,
    DateTime? expirationDate,
    ArticleStatus? status,
    List<ArticleSection>? sections,
    String? userId,
    String? assocId,
    String? authorName,
    String? authorAvatarUrl,
    String? associationShortName,
    String? originalLanguage,
    DateTime? createdAt,
    DateTime? modifiedAt,
  }) {
    return ArticleEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      abstractContent: abstractContent ?? this.abstractContent,
      coverUrl: coverUrl ?? this.coverUrl,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      publishDate: publishDate ?? this.publishDate,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      expirationDate: expirationDate ?? this.expirationDate,
      status: status ?? this.status,
      sections: sections ?? this.sections,
      userId: userId ?? this.userId,
      assocId: assocId ?? this.assocId,
      authorName: authorName ?? this.authorName,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      associationShortName: associationShortName ?? this.associationShortName,
      originalLanguage: originalLanguage ?? this.originalLanguage,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
    );
  }
}
