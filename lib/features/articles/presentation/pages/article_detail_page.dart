import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:conectasoc/features/articles/domain/entities/entities.dart';
import 'package:conectasoc/features/articles/presentation/bloc/bloc.dart';
import 'package:conectasoc/features/auth/presentation/bloc/bloc.dart';
import 'package:conectasoc/injection_container.dart';
import 'package:conectasoc/l10n/app_localizations.dart';

class ArticleDetailPage extends StatelessWidget {
  final String articleId;
  const ArticleDetailPage({super.key, required this.articleId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ArticleDetailBloc>(
        param1: context.read<AuthBloc>(),
      )..add(LoadArticleDetail(articleId)),
      child: const ArticleDetailView(),
    );
  }
}

class ArticleDetailView extends StatelessWidget {
  const ArticleDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ArticleDetailBloc, ArticleDetailState>(
        builder: (context, state) {
          if (state is ArticleDetailLoading || state is ArticleDetailInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ArticleDetailError) {
            return Center(child: Text(state.message));
          }
          if (state is ArticleDetailLoaded) {
            return _buildArticleContent(context, state.article);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildArticleContent(BuildContext context, ArticleEntity article) {
    final l10n = AppLocalizations.of(context)!;
    final FocusNode focusNode = FocusNode();
    final ScrollController scrollController = ScrollController();

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 250.0,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(_quillJsonToPlainText(article.title),
                style: const TextStyle(fontSize: 16)),
            background: CachedNetworkImage(
              imageUrl: article.coverUrl,
              fit: BoxFit.cover,
              color: Colors.black.withValues(alpha: 0.4),
              colorBlendMode: BlendMode.darken,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mostrar el título con formato completo aquí
                quill.QuillEditor(
                  scrollController: scrollController,
                  focusNode: focusNode,
                  controller: _quillControllerFromJson(article.title),
                  config: quill.QuillEditorConfig(
                    showCursor: false,
                    autoFocus: false,
                    expands: false,
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    placeholder: 'Contenido de solo lectura',
                  ),
                ),
                Text(
                  '${l10n.category}: ${article.categoryId} > ${l10n.subcategory}: ${article.subcategoryId}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  '${l10n.publishDateLabel}: ${DateFormat.yMMMd(l10n.localeName).format(article.publishDate)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Divider(height: 32),
                ...article.sections
                    .map((section) => _buildSection(context, section)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(BuildContext context, ArticleSection section) {
    final FocusNode focusNode = FocusNode();
    final ScrollController scrollController = ScrollController();
    final quill.QuillController? contentController =
        section.richTextContent != null
            ? _quillControllerFromJson(section.richTextContent!)
            : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (section.imageUrl != null && section.imageUrl!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: section.imageUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
          if (contentController != null)
            quill.QuillEditor(
              scrollController: scrollController,
              focusNode: focusNode,
              controller: contentController,
              config: quill.QuillEditorConfig(
                showCursor: false,
                autoFocus: false,
                expands: false,
                padding: EdgeInsets.zero,
                placeholder: 'Contenido de solo lectura',
              ),
            ),
        ],
      ),
    );
  }

  quill.QuillController _quillControllerFromJson(String jsonString) {
    try {
      if (jsonString.isEmpty) {
        return quill.QuillController.basic();
      }
      final doc = quill.Document.fromJson(jsonDecode(jsonString));
      return quill.QuillController(
          document: doc,
          selection: const TextSelection.collapsed(offset: 0),
          readOnly: true);
    } catch (e) {
      // If JSON is invalid (e.g., our mock translation), treat as plain text.
      final doc = quill.Document()..insert(0, jsonString);
      return quill.QuillController(
          document: doc,
          selection: const TextSelection.collapsed(offset: 0),
          readOnly: true);
    }
  }

  // Helper para convertir el JSON de Quill a texto plano para el título del AppBar
  String _quillJsonToPlainText(String quillJson) {
    if (quillJson.isEmpty) return '';
    try {
      final doc = quill.Document.fromJson(jsonDecode(quillJson));
      return doc
          .toPlainText()
          .trim()
          .replaceAll('\n', ' '); // Reemplaza saltos de línea
    } catch (e) {
      return ''; // Manejo de JSON malformado
    }
  }
}
