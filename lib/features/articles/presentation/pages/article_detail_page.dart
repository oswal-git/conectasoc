import 'dart:convert';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:conectasoc/features/articles/domain/entities/entities.dart';
import 'package:conectasoc/features/articles/presentation/bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:conectasoc/features/auth/presentation/bloc/bloc.dart';
import 'package:conectasoc/core/utils/quill_helpers.dart';
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.articleTitle),
      ),
      body: BlocBuilder<ArticleDetailBloc, ArticleDetailState>(
        builder: (context, state) {
          if (state is ArticleDetailLoading || state is ArticleDetailInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ArticleDetailError) {
            return Center(
                child: Text(state.message, textAlign: TextAlign.center));
          }
          if (state is ArticleDetailLoaded) {
            return LayoutBuilder(
              builder: (context, constraints) {
                // Usamos un breakpoint para decidir qué layout mostrar
                if (constraints.maxWidth > 768) {
                  return _WebLayout(article: state.article);
                } else {
                  return _MobileLayout(article: state.article);
                }
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

/// Layout para pantallas grandes (Web)
class _WebLayout extends StatelessWidget {
  final ArticleEntity article;
  const _WebLayout({required this.article});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat("dd 'de' MMMM 'de' yyyy", l10n.localeName);

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1300),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fila 1: Título
                _SectionContent(jsonContent: article.title, isTitle: true),
                const SizedBox(height: 16),

                // Fila 2: Metadata
                _AuthorInfo(article: article),
                const SizedBox(height: 4),
                Text(
                  '${l10n.category}: ${article.categoryName} / ${article.subcategoryName}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),

                // Fila 3: Fecha de publicación
                Text(
                  '${l10n.publishDateLabel}: ${dateFormat.format(article.publishDate)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 24),

                // Fila 4: Cover
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: article.coverUrl,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Fila 5: Contenido (Abstract o Secciones)
                // if (article.sections.isEmpty)
                _SectionContent(jsonContent: article.abstractContent),
                // else
                ...article.sections.asMap().entries.map((entry) {
                  final index = entry.key;
                  final section = entry.value;
                  final bool isOdd = (index + 1) % 2 != 0;
                  return _buildWebSection(context, section, isOdd);
                }),

                const Divider(height: 48),

                // Pie de página: Fechas de vigencia
                _buildFooter(context, article, dateFormat),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWebSection(
      BuildContext context, ArticleSection section, bool isOdd) {
    final imageWidget =
        (section.imageUrl != null && section.imageUrl!.isNotEmpty)
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: section.imageUrl!,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            : null;

    final hasTextContent =
        quillJsonToPlainText(section.richTextContent ?? '').isNotEmpty;

    final textWidget = hasTextContent
        ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: _SectionContent(jsonContent: section.richTextContent!),
          )
        : null;

    if (imageWidget == null && textWidget == null) {
      return const SizedBox.shrink();
    }

    // Si solo hay una imagen, centrarla con un ancho máximo.
    if (imageWidget != null && textWidget == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
                maxWidth: 600), // Ancho máximo para la imagen
            child: imageWidget,
          ),
        ),
      );
    }

    if (imageWidget == null && textWidget != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: textWidget,
      );
    }

    // ✅ Si hay ambos, usar Row con Expanded dentro de IntrinsicHeight
    final children = isOdd
        ? [Expanded(child: imageWidget!), Expanded(child: textWidget!)]
        : [Expanded(child: textWidget!), Expanded(child: imageWidget!)];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}

/// Layout para pantallas pequeñas (Móvil)
class _MobileLayout extends StatelessWidget {
  final ArticleEntity article;
  const _MobileLayout({required this.article});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat("d 'de' MMMM 'de' yyyy", l10n.localeName);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila 1: Título
          _SectionContent(jsonContent: article.title, isTitle: true),
          const SizedBox(height: 16),

          // Fila 2: Metadata
          _AuthorInfo(article: article),
          const SizedBox(height: 4),
          Text(
            '${l10n.category}: ${article.categoryName} / ${article.subcategoryName}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),

          // Fila 3: Fecha de publicación
          Text(
            '${l10n.publishDateLabel}: ${dateFormat.format(article.publishDate)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),

          // Fila 4: Cover
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: article.coverUrl,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          const SizedBox(height: 24),

          // Fila 5: Contenido (Abstract o Secciones)
          if (article.sections.isEmpty)
            _SectionContent(jsonContent: article.abstractContent)
          else
            ...article.sections.map((section) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (section.imageUrl != null &&
                        section.imageUrl!.isNotEmpty)
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
                    if (section.richTextContent != null &&
                        section.richTextContent!.isNotEmpty)
                      _SectionContent(jsonContent: section.richTextContent!),
                  ],
                ),
              );
            }),
          const Divider(height: 48),
          _buildFooter(context, article, dateFormat),
        ],
      ),
    );
  }
}

Widget _buildFooter(
    BuildContext context, ArticleEntity article, DateFormat dateFormat) {
  final l10n = AppLocalizations.of(context)!;
  String vigenciaText =
      '${l10n.effectivePublishDate} ${l10n.start} ${dateFormat.format(article.effectiveDate)}';
  if (article.expirationDate != null) {
    vigenciaText =
        '${l10n.effectivePublishDate} ${l10n.from} ${dateFormat.format(article.effectiveDate)} ${l10n.toThe} ${dateFormat.format(article.expirationDate!)}';
  }

  return Center(
    child: Text(
      vigenciaText,
      style: Theme.of(context)
          .textTheme
          .bodySmall
          ?.copyWith(fontStyle: FontStyle.italic),
      textAlign: TextAlign.center,
    ),
  );
}

class _AuthorInfo extends StatelessWidget {
  final ArticleEntity article;
  const _AuthorInfo({required this.article});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: article.authorAvatarUrl != null
              ? CachedNetworkImageProvider(article.authorAvatarUrl!)
              : null,
          child: article.authorAvatarUrl == null
              ? const Icon(Icons.person, size: 20)
              : null,
        ),
        const SizedBox(width: 8),
        Text(
          'Por ${article.authorName}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

/// Widget reutilizable para mostrar contenido de Quill en modo de solo lectura.
class _SectionContent extends StatefulWidget {
  final String jsonContent;
  final bool isTitle;

  const _SectionContent({required this.jsonContent, this.isTitle = false});

  @override
  State<_SectionContent> createState() => _SectionContentState();
}

class _SectionContentState extends State<_SectionContent> {
  late final quill.QuillController _controller;

  @override
  void initState() {
    super.initState();
    try {
      // ✅ Parsear el JSON correctamente
      List<dynamic> jsonData = jsonDecode(widget.jsonContent);

      // ✅ CRÍTICO: Asegurar que termina con \n sin atributos
      if (jsonData.isNotEmpty) {
        final lastInsert = jsonData.last as Map<String, dynamic>;
        final lastInsertText = lastInsert['insert'] as String?;

        if (lastInsertText == null ||
            !lastInsertText.endsWith('\n') ||
            lastInsert.containsKey('attributes')) {
          jsonData.add({'insert': '\n'});
        }
      }

      final doc = quill.Document.fromJson(jsonData);
      _controller = quill.QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
      );
    } catch (e) {
      final doc = quill.Document()..insert(0, widget.jsonContent);
      _controller = quill.QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = widget.isTitle
        ? Theme.of(context).textTheme.headlineMedium
        : Theme.of(context).textTheme.bodyLarge;

    return quill.QuillEditor.basic(
      controller: _controller,
      config: quill.QuillEditorConfig(
        // Eliminamos el placeholder
        // placeholder: 'Contenido de solo lectura',
        padding: EdgeInsets.zero,
        customStyles: quill.DefaultStyles(
          paragraph: quill.DefaultTextBlockStyle(
            textStyle!,
            const quill.HorizontalSpacing(0, 0),
            const quill.VerticalSpacing(0, 0),
            const quill.VerticalSpacing(0, 0),
            null,
          ),
        ),
      ),
    );
  }
}
