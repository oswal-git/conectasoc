import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conectasoc/features/articles/domain/entities/entities.dart';

// Hereda de ArticleEntity para reutilizar la lógica de negocio y la igualdad.
class ArticleModel extends ArticleEntity {
  const ArticleModel({
    required super.id,
    required super.title,
    required super.abstractContent,
    super.coverUrl = '',
    required super.categoryName,
    required super.categoryId,
    required super.subcategoryId,
    required super.subcategoryName,
    required super.publishDate,
    required super.effectiveDate,
    super.expirationDate,
    super.status = ArticleStatus.redaccion,
    super.fechaNotificacion,
    super.sections = const [],
    required super.userId,
    required super.assocId,
    required super.authorName,
    required super.associationShortName,
    required super.originalLanguage,
    required super.createdAt,
    required super.modifiedAt,
    super.isTranslated,
  });

  factory ArticleModel.fromFirestore(
    DocumentSnapshot doc, {
    List<QueryDocumentSnapshot>? sectionsDocs,
  }) {
    final data = doc.data() as Map<String, dynamic>;

    final sections = sectionsDocs
            ?.map((s) =>
                ArticleSection.fromJson(s.data() as Map<String, dynamic>))
            .toList() ??
        [];

    final createdAtRaw = data['createdAt'];
    final modifiedAtRaw = data['modifiedAt'];

    final createdAt =
        (createdAtRaw is Timestamp) ? createdAtRaw.toDate() : DateTime.now();
    final modifiedAt =
        (modifiedAtRaw is Timestamp) ? modifiedAtRaw.toDate() : DateTime.now();

    return ArticleModel(
      id: doc.id,
      title: data['title'] ?? '',
      abstractContent: data['abstractContent'] ?? '',
      coverUrl: data['coverUrl'] ?? '',
      categoryId: data['categoryId'] ?? '',
      categoryName: data['categoryName'] ?? '',
      subcategoryId: data['subcategoryId'] ?? '',
      subcategoryName: data['subcategoryName'] ?? '',
      publishDate: data['publishDate'] != null
          ? (data['publishDate'] as Timestamp).toDate()
          : DateTime.now(),
      effectiveDate: data['effectiveDate'] != null
          ? (data['effectiveDate'] as Timestamp).toDate()
          : DateTime.now(),
      expirationDate: data['expirationDate'] != null
          ? (data['expirationDate'] as Timestamp).toDate()
          : null,
      sections: sections,
      userId: data['userId'] ?? '',
      assocId: data['assocId'] ?? '',
      authorName: data['authorName'] ?? '',
      associationShortName: data['associationShortName'] ?? '',
      originalLanguage: data['originalLanguage'] ?? 'es',
      status: ArticleStatusExtension.fromValue(data['status'] ?? 'redaccion'),
      fechaNotificacion: data['fechaNotificacion'] != null
          ? (data['fechaNotificacion'] as Timestamp).toDate()
          : null,
      createdAt: createdAt,
      modifiedAt: modifiedAt,
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
    );
  }

  // Convierte un ArticleModel en un mapa LIGERO para el documento principal en Firestore
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
      'status': status.value,
      'fechaNotificacion': fechaNotificacion != null
          ? Timestamp.fromDate(fechaNotificacion!)
          : null,
      'userId': userId,
      'assocId': assocId,
      'authorName': authorName,
      'associationShortName': associationShortName,
      'originalLanguage': originalLanguage,
      'createdAt': Timestamp.fromDate(createdAt),
      'modifiedAt': Timestamp.fromDate(modifiedAt),
      // searchText optimizado para listado
      'searchText': _generateSearchText(),
    };
  }

  // Genera los datos para la subcolección 'sections'
  List<Map<String, dynamic>> sectionsToFirestore() {
    return sections
        .map((s) => {
              'id': s.id,
              'imageUrl': s.imageUrl,
              'richTextContent': s.richTextContent,
              'order': s.order,
              'documentLink': s.documentLink?.toJson(),
            })
        .toList();
  }

  // Genera los datos para la subcolección 'additionalInfo'
  // Map<String, dynamic> additionalInfoToFirestore() {
  //   return {};
  // }

  List<String> _generateSearchText() {
    return '${title.toLowerCase()} ${abstractContent.toLowerCase()}'
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
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
      'sections': sections.map((s) => s.toJson()).toList(),
      'userId': userId,
      'assocId': assocId,
      'authorName': authorName,
      'associationShortName': associationShortName,
      'originalLanguage': originalLanguage,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
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
    bool clearExpirationDate = false,
    bool clearFechaNotificacion = false,
    bool? isTranslated,
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
      isTranslated: isTranslated ?? this.isTranslated,
    );
  }
}
