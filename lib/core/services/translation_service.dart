import 'dart:convert';

import 'package:conectasoc/features/articles/domain/entities/entities.dart';
import 'package:translator/translator.dart';

/// NOTE: This is a mock translation service.
/// A real implementation would use a package like 'translator' or a cloud API.
class TranslationService {
  final _translator = GoogleTranslator();

  /// Translates the content of an ArticleEntity if the target language is different.
  Future<ArticleEntity> translateArticle(
      ArticleEntity article, String targetLang) async {
    if (article.originalLanguage == targetLang) {
      return article;
    }

    final translatedTitle = await _translateQuillJson(article.title,
        from: article.originalLanguage, to: targetLang);
    final translatedAbstract = await _translateQuillJson(
        article.abstractContent,
        from: article.originalLanguage,
        to: targetLang);

    final translatedSections = <ArticleSection>[];
    for (final section in article.sections) {
      final translatedContent = section.richTextContent != null
          ? await _translateQuillJson(section.richTextContent!,
              from: article.originalLanguage, to: targetLang)
          : null;
      translatedSections
          .add(section.copyWith(richTextContent: translatedContent));
    }

    return article.copyWith(
      title: translatedTitle,
      abstractContent: translatedAbstract,
      sections: translatedSections,
    );
  }

  /// Translates the text content within a Quill-formatted JSON string (Delta).
  Future<String> _translateQuillJson(String jsonString,
      {required String from, required String to}) async {
    if (jsonString.isEmpty) return '';

    try {
      List<dynamic> delta = jsonDecode(jsonString);

      for (var op in delta) {
        if (op is Map<String, dynamic> &&
            op.containsKey('insert') &&
            op['insert'] is String) {
          String textToTranslate = op['insert'];
          // Only translate non-empty text to avoid unnecessary API calls
          if (textToTranslate.trim().isNotEmpty) {
            final translation = await _translator.translate(
              textToTranslate,
              from: from,
              to: to,
            );
            op['insert'] = translation.text;
          }
        }
      }
      return jsonEncode(delta);
    } catch (e) {
      // If translation fails, return the original content with an error prefix for debugging.
      return '[Error de traducción] $jsonString';
    }
  }
}
