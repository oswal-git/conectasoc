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
    final translatedCategory = await _translateString(article.categoryName,
        from: article.originalLanguage, to: targetLang);
    final translatedSubcategory = await _translateString(
        article.subcategoryName,
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
      categoryName: translatedCategory,
      subcategoryName: translatedSubcategory,
    );
  }

// Translates a CategoryEntity name to the target language
  Future<CategoryEntity> translateCategory(
      CategoryEntity category, String targetLang) async {
    final translatedName = await _translateString(
      category.name,
      from: 'auto',
      to: targetLang,
    );

    return category.copyWith(name: translatedName);
  }

  /// Translates a list of CategoryEntity names to the target language
  Future<List<CategoryEntity>> translateCategories(
      List<CategoryEntity> categories, String targetLang) async {
    return Future.wait(
      categories.map((category) => translateCategory(category, targetLang)),
    );
  }

  /// Translates a SubcategoryEntity name to the target language
  Future<SubcategoryEntity> translateSubcategory(
      SubcategoryEntity subcategory, String targetLang) async {
    final translatedName = await _translateString(
      subcategory.name,
      from: 'auto',
      to: targetLang,
    );

    return subcategory.copyWith(name: translatedName);
  }

  /// Translates a list of SubcategoryEntity names to the target language
  Future<List<SubcategoryEntity>> translateSubcategories(
      List<SubcategoryEntity> subcategories, String targetLang) async {
    return Future.wait(
      subcategories
          .map((subcategory) => translateSubcategory(subcategory, targetLang)),
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

          // ✅ Solo traducir si hay texto real (no solo \n)
          if (textToTranslate.trim().isNotEmpty) {
            // Contar saltos de línea al inicio y al final
            final leadingNewlines =
                RegExp(r'^\n+').firstMatch(textToTranslate)?.group(0) ?? '';
            final trailingNewlines =
                RegExp(r'\n+$').firstMatch(textToTranslate)?.group(0) ?? '';

            // Extraer solo el texto sin los saltos de línea
            final cleanText = textToTranslate.trim();

            if (cleanText.isNotEmpty) {
              // Traducir usando detección automática del idioma de origen
              final translation = await _translator.translate(
                cleanText,
                from: 'auto', // ✅ Permitir que Google detecte el idioma real
                to: to,
              );

              // ✅ Si el idioma detectado es el mismo que el de destino, NO aplicar la traducción.
              // Esto evita errores gramaticales o cambios no deseados en textos ya correctos.
              if (translation.sourceLanguage.code == to) {
                op['insert'] = textToTranslate;
              } else {
                // Restaurar los saltos de línea en la misma posición usando el texto traducido
                op['insert'] =
                    '$leadingNewlines${translation.text}$trailingNewlines';
              }
            }
            // Si solo hay saltos de línea, dejarlos sin traducir
          }
          // Si solo hay \n, no tocar nada
        }
      }

      // ✅ CRÍTICO: Asegurar que termina con \n sin atributos
      if (delta.isNotEmpty) {
        final lastOp = delta.last as Map<String, dynamic>;
        final lastInsert = lastOp['insert'] as String?;

        if (lastInsert == null ||
            !lastInsert.endsWith('\n') ||
            lastOp.containsKey('attributes')) {
          delta.add({'insert': '\n'});
        }
      }
      return jsonEncode(delta);
    } catch (e) {
      // If translation fails, return the original content with an error prefix for debugging.
      return '[Error de traducción] $jsonString';
    }
  }

  /// Translates the text content within a Quill-formatted JSON string (Delta).
  Future<String> _translateString(
    String string, {
    required String from,
    required String to,
  }) async {
    if (string.isEmpty) return '';

    try {
      // ✅ Solo traducir si hay texto real (no solo \n)
      if (string.trim().isNotEmpty) {
        // Extraer solo el texto sin los saltos de línea
        final cleanText = string.trim();

        if (cleanText.isNotEmpty) {
          // Traducir usando detección automática del idioma de origen
          final translation = await _translator.translate(
            cleanText,
            from: 'auto', // ✅ Permitir que Google detecte el idioma real
            to: to,
          );

          // ✅ Si el idioma detectado es el mismo que el de destino, NO aplicar la traducción.
          // Esto evita errores gramaticales o cambios no deseados en textos ya correctos.
          if (translation.sourceLanguage.code != to) {
            // Restaurar los saltos de línea en la misma posición usando el texto traducido
            string = translation.text;
          }
        }
        // Si solo hay saltos de línea, dejarlos sin traducir
      }
      // Si solo hay \n, no tocar nada

      return string;
    } catch (e) {
      // If translation fails, return the original content with an error prefix for debugging.
      return '[Error de traducción] $string';
    }
  }
}
