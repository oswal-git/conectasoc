import 'package:equatable/equatable.dart';

class ArticleSection extends Equatable {
  final String id;
  final String? imageUrl;
  final String? richTextContent; // flutter_quill Delta JSON
  final int order;

  const ArticleSection({
    required this.id,
    this.imageUrl,
    this.richTextContent,
    required this.order,
  });

  @override
  List<Object?> get props => [id, imageUrl, richTextContent, order];

  ArticleSection copyWith({
    String? id,
    String? imageUrl,
    String? richTextContent,
    int? order,
  }) {
    return ArticleSection(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      richTextContent: richTextContent ?? this.richTextContent,
      order: order ?? this.order,
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
}
