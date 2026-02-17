import 'package:conectasoc/features/documents/domain/entities/document_link_entity.dart';
import 'package:equatable/equatable.dart';

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
  List<Object?> get props => [id, imageUrl, richTextContent, order];

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

  factory ArticleSection.fromJson(Map<String, dynamic> json) {
    return ArticleSection(
      id: json['id'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      richTextContent: json['richTextContent'] ?? '',
      order: json['order'] ?? 0,
    );
  }

  /// Retorna true si la sección tiene un documento enlazado
  bool get hasDocument => documentLink != null;

  /// Retorna true si la sección tiene contenido (imagen o texto)
  bool get hasContent =>
      (imageUrl != null && imageUrl!.isNotEmpty) ||
      (richTextContent != null && richTextContent!.isNotEmpty);

  /// Valida que no haya documento Y contenido al mismo tiempo
  bool get isValid => !(hasDocument && hasContent);

  // Factory para crear sección con documento
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

  // Factory para crear sección con contenido
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
