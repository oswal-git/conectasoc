import 'package:conectasoc/features/documents/domain/entities/document_link_entity.dart';
import 'package:equatable/equatable.dart';

/// Sección de un artículo.
///
/// REGLA DE INCOMPATIBILIDAD:
/// - Si [documentLink] está informado → [imageUrl] y [richTextContent] deben
///   ser nulos/vacíos.
/// - Si [imageUrl] o [richTextContent] están informados → [documentLink] debe
///   ser nulo.
/// Usar los factories [withDocument] y [withContent] para garantizar esto.
///

class ArticleSection extends Equatable {
  final String id;
  final String? imageUrl;
  final String? richTextContent; // flutter_quill Delta JSON
  final int order;
  final DocumentLinkEntity? documentLink;

  const ArticleSection({
    required this.id,
    this.imageUrl,
    this.richTextContent,
    required this.order,
    this.documentLink,
  });

  @override
  List<Object?> get props => [
        id,
        imageUrl,
        richTextContent,
        documentLink,
      ];

  ArticleSection copyWith({
    String? id,
    String? imageUrl,
    String? richTextContent,
    int? order,
    DocumentLinkEntity? documentLink,
    bool clearImageUrl = false,
    bool clearRichTextContent = false,
    bool clearDocumentLink = false,
  }) {
    return ArticleSection(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      richTextContent: clearRichTextContent
          ? null
          : (richTextContent ?? this.richTextContent),
      order: order ?? this.order,
      // ✨ NUEVO
      documentLink:
          clearDocumentLink ? null : (documentLink ?? this.documentLink),
    );
  }

  // ─────────────────────────────────────────────
  // Serialización
  // ─────────────────────────────────────────────

  factory ArticleSection.fromJson(Map<String, dynamic> json) {
    return ArticleSection(
      id: json['id'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      richTextContent: json['richTextContent'] ?? '',
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'richTextContent': richTextContent,
      'order': order,
      'documentLink': documentLink?.toJson(), // ✨ NUEVO
    };
  }

  // ─────────────────────────────────────────────
  // Getters de estado
  // ─────────────────────────────────────────────
  /// Retorna true si la sección tiene un documento enlazado
  bool get hasDocument => documentLink != null;

  /// Retorna true si la sección tiene contenido (imagen o texto)
  bool get hasContent =>
      (imageUrl != null && imageUrl!.isNotEmpty) ||
      (richTextContent != null && richTextContent!.isNotEmpty);

  /// Valida que no haya documento Y contenido al mismo tiempo
  bool get isValid => !(hasDocument && hasContent);

  // ─────────────────────────────────────────────
  // Factories
  // ─────────────────────────────────────────────

  /// Crea una sección con documento enlazado (limpia imagen y texto)
  factory ArticleSection.withDocument({
    required String id,
    required DocumentLinkEntity documentLink,
    required int order,
  }) {
    return ArticleSection(
      id: id,
      imageUrl: null,
      richTextContent: null,
      order: order,
      documentLink: documentLink,
    );
  }

  /// Crea una sección con imagen y/o texto (limpia documento)
  factory ArticleSection.withContent({
    required String id,
    String? imageUrl,
    String? richTextContent,
    required int order,
  }) {
    return ArticleSection(
      id: id,
      imageUrl: imageUrl,
      richTextContent: richTextContent,
      order: order,
      documentLink: null,
    );
  }
}
