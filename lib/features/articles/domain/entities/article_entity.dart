import 'package:conectasoc/features/articles/domain/entities/entities.dart';
import 'package:equatable/equatable.dart';

enum ArticleStatus {
  redaccion, // draft
  publicado, // published
  revision, // review
  expirado, // expired
  anulado, // cancelled
  notificar, // marked for notification
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
  final String categoryName;
  final String categoryId;
  final String subcategoryId;
  final String subcategoryName;
  final DateTime publishDate;
  final DateTime effectiveDate;
  final DateTime? expirationDate; // Puede ser nulo
  final ArticleStatus status;
  final DateTime? fechaNotificacion; // Fecha en que se marcó para notificar
  final List<ArticleSection> sections; // List of sections

  // Metadata
  final String userId; // Creator's UID
  final String assocId; // Usar '' para artículos genéricos, no null.
  final String authorName;
  final String associationShortName;
  final String originalLanguage;
  final DateTime createdAt;
  final DateTime modifiedAt;

  const ArticleEntity({
    required this.id,
    required this.title,
    required this.abstractContent,
    this.coverUrl = '',
    required this.categoryName,
    required this.categoryId,
    required this.subcategoryId,
    required this.subcategoryName,
    required this.publishDate,
    required this.effectiveDate,
    this.expirationDate,
    this.status = ArticleStatus.redaccion,
    this.fechaNotificacion,
    this.sections = const [],
    required this.userId, // ID del creador
    required this.assocId,
    required this.authorName,
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
        categoryName,
        subcategoryId,
        subcategoryName,
        publishDate,
        effectiveDate,
        expirationDate,
        status,
        fechaNotificacion,
        sections,
        userId,
        assocId,
        authorName,
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
      categoryName: '',
      subcategoryId: '',
      subcategoryName: '',
      publishDate: now,
      effectiveDate: now,
      status: ArticleStatus.redaccion,
      expirationDate: null,
      fechaNotificacion: null,
      sections: const [],
      userId: '',
      assocId: '', // Por defecto es un artículo genérico
      authorName: '',
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
      categoryName: json['categoryName'] ?? '',
      subcategoryId: json['subcategoryId'] ?? '',
      subcategoryName: json['subcategoryName'] ?? '',
      publishDate: DateTime.parse(json['publishDate']),
      effectiveDate: DateTime.parse(json['effectiveDate']),
      expirationDate: json['expirationDate'] != null
          ? DateTime.parse(json['expirationDate'])
          : null,
      status: ArticleStatusExtension.fromValue(json['status'] ?? 'redaccion'),
      fechaNotificacion: json['fechaNotificacion'] != null
          ? DateTime.parse(json['fechaNotificacion'])
          : null,
      sections: (json['sections'] as List<dynamic>?)
              ?.map((s) => ArticleSection.fromJson(s))
              .toList() ??
          [],
      userId: json['userId'] ?? '',
      assocId: json['assocId'] ?? '',
      authorName: json['authorName'] ?? '',
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
  }) {
    return ArticleEntity(
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
      expirationDate: expirationDate ?? this.expirationDate,
      status: status ?? this.status,
      fechaNotificacion: fechaNotificacion ?? this.fechaNotificacion,
      sections: sections ?? this.sections,
      userId: userId ?? this.userId,
      assocId: assocId ?? this.assocId,
      authorName: authorName ?? this.authorName,
      associationShortName: associationShortName ?? this.associationShortName,
      originalLanguage: originalLanguage ?? this.originalLanguage,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
    );
  }
}
