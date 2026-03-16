import 'dart:convert';
import 'package:conectasoc/core/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:conectasoc/features/articles/domain/entities/entities.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/translator.dart';

/// NOTE: This is a mock translation service.
/// A real implementation would use a package like 'translator' or a cloud API.
/// Translation service with SharedPreferences cache.
/// Cache key format: trl_{xxhash of text}_{targetLang}
/// This avoids redundant HTTP calls on subsequent app launches.
class TranslationService {
  final _translator = GoogleTranslator();

// In-memory cache for the current session (avoids repeated SP lookups)
  final Map<String, String> _memoryCache = {};

  // SharedPreferences instance — injected lazily
  SharedPreferences? _prefs;

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Builds a stable cache key from content + target language.
  /// Uses a simple djb2 hash — fast, no extra dependencies.
  String _cacheKey(String text, String targetLang) {
    var hash = 5381;
    for (final codeUnit in text.codeUnits) {
      hash = ((hash << 5) + hash) + codeUnit;
      hash &= 0x7FFFFFFF; // keep positive 32-bit
    }
    return 'trl_${hash}_$targetLang';
  }

  Future<String?> _readCache(String key) async {
    if (_memoryCache.containsKey(key)) return _memoryCache[key];
    final prefs = await _getPrefs();
    final value = prefs.getString(key);
    if (value != null) _memoryCache[key] = value;
    return value;
  }

  Future<void> _writeCache(String key, String value) async {
    _memoryCache[key] = value;
    final prefs = await _getPrefs();
    await prefs.setString(key, value);
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Translates a single field — either a Quill Delta JSON string or plain text.
  /// Used by ArticleDetailBloc to translate fields individually.
  Future<String> translateField(
    String content,
    String fromLang,
    String toLang, {
    bool isQuillJson = false,
  }) async {
    if (content.isEmpty || fromLang == toLang) return content;
    return isQuillJson
        ? _translateQuillJson(content, from: fromLang, to: toLang)
        : _translateCached(content, from: fromLang, to: toLang);
  }

  /// Translates an [ArticleEntity] to [targetLang].
  /// Returns the original article unchanged when the language matches or on web.
  ///
  /// Translates the content of an ArticleEntity if the target language is different.
  Future<ArticleEntity> translateArticle(
      ArticleEntity article, String targetLang) async {
    if (article.originalLanguage == targetLang || kIsWeb) {
      debugPrint(
          '${fechaD('📓')} Translation: Skipping (same language or web targetLang=$targetLang)');
      return article.copyWith(isTranslated: true);
    }

    try {
      debugPrint(
          '${fechaD('📓')}Translation: Translating article ${article.id} to $targetLang');

      final translatedTitle = await _translateQuillJson(article.title,
          from: article.originalLanguage, to: targetLang);
      final translatedAbstract = await _translateQuillJson(
          article.abstractContent,
          from: article.originalLanguage,
          to: targetLang);
      final translatedCategory = await _translateCached(article.categoryName,
          from: article.originalLanguage, to: targetLang);
      final translatedSubcategory = await _translateCached(
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

      debugPrint('${fechaD('📓')}Translation: Done article ${article.id}');

      return article.copyWith(
        title: translatedTitle,
        abstractContent: translatedAbstract,
        sections: translatedSections,
        categoryName: translatedCategory,
        subcategoryName: translatedSubcategory,
        isTranslated: true,
      );
    } catch (e) {
      // Always mark as translated even on error so the shimmer always
      // disappears. The article will display in its original language.
      debugPrint(
          '${fechaD('🔴')}Translation error for article ${article.id}: $e');
      return article.copyWith(isTranslated: true);
    }
  }

// Translates a CategoryEntity name to the target language
  Future<CategoryEntity> translateCategory(
      CategoryEntity category, String targetLang) async {
    if (kIsWeb) return category;
    final translated =
        await _translateCached(category.name, from: 'auto', to: targetLang);

    return category.copyWith(name: translated);
  }

  /// Translates a list of CategoryEntity names to the target language
  Future<List<CategoryEntity>> translateCategories(
      List<CategoryEntity> categories, String targetLang) async {
    if (kIsWeb) return categories;
    return Future.wait(
      categories.map((category) => translateCategory(category, targetLang)),
    );
  }

  /// Translates a SubcategoryEntity name to the target language
  Future<SubcategoryEntity> translateSubcategory(
      SubcategoryEntity subcategory, String targetLang) async {
    if (kIsWeb) return subcategory;
    final translated =
        await _translateCached(subcategory.name, from: 'auto', to: targetLang);

    return subcategory.copyWith(name: translated);
  }

  /// Translates a list of SubcategoryEntity names to the target language
  Future<List<SubcategoryEntity>> translateSubcategories(
      List<SubcategoryEntity> subcategories, String targetLang) async {
    if (kIsWeb) return subcategories;
    return Future.wait(
      subcategories
          .map((subcategory) => translateSubcategory(subcategory, targetLang)),
    );
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Translates a plain string with cache lookup.
  Future<String> _translateCached(
    String text, {
    required String from,
    required String to,
  }) async {
    if (text.trim().isEmpty) return text;

    final key = _cacheKey(text, to);
    final cached = await _readCache(key);
    if (cached != null) return cached;

// Let exceptions propagate to translateArticle's catch block
    final result = await _translateString(text, from: from, to: to);
    await _writeCache(key, result);
    return result;
  }

  /// Translates each text run inside a Quill Delta JSON string, with cache.
  ///
  /// Translates the text content within a Quill-formatted JSON string (Delta).
  Future<String> _translateQuillJson(String jsonString,
      {required String from, required String to}) async {
    if (jsonString.isEmpty) return '';

    // Check cache for the whole Delta blob first
    final blobKey = _cacheKey(jsonString, to);
    final cachedBlob = await _readCache(blobKey);
    if (cachedBlob != null) return cachedBlob;

    // No try/catch here — exceptions propagate to translateArticle's catch,
    // which sets isTranslated: true so the shimmer always resolves.
    List<dynamic> delta = jsonDecode(jsonString);

    for (var op in delta) {
      if (op is Map<String, dynamic> &&
          op.containsKey('insert') &&
          op['insert'] is String) {
        final textToTranslate = op['insert'] as String;

        if (textToTranslate.trim().isEmpty) continue;

        final leadingNewlines =
            RegExp(r'^\n+').firstMatch(textToTranslate)?.group(0) ?? '';
        final trailingNewlines =
            RegExp(r'\n+$').firstMatch(textToTranslate)?.group(0) ?? '';
        final cleanText = textToTranslate.trim();

        if (cleanText.isNotEmpty) {
          final runKey = _cacheKey(cleanText, to);
          String translated;

          final cachedRun = await _readCache(runKey);
          if (cachedRun != null) {
            translated = cachedRun;
          } else {
            final translation = await _translator
                .translate(cleanText, from: 'auto', to: to)
                .timeout(const Duration(seconds: 10));

            translated = translation.sourceLanguage.code == to
                ? cleanText
                : translation.text;
            await _writeCache(runKey, translated);
          }

          op['insert'] = '$leadingNewlines$translated$trailingNewlines';
        }
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

    final result = jsonEncode(delta);
    await _writeCache(blobKey, result);
    return result;
  }

  /// Translates the text content within a Quill-formatted JSON string (Delta).
  Future<String> _translateString(
    String string, {
    required String from,
    required String to,
  }) async {
    if (string.trim().isEmpty) return string;

    final translation = await _translator
        .translate(string.trim(), from: 'auto', to: to)
        .timeout(const Duration(seconds: 10));

    return translation.sourceLanguage.code != to ? translation.text : string;
  }
}
