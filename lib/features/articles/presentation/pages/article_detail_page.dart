import 'dart:convert';
import 'package:conectasoc/app/theme/app_theme.dart';
import 'package:conectasoc/services/notification_service.dart';
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
import 'package:conectasoc/features/articles/presentation/widgets/widgets.dart';
import 'package:conectasoc/features/users/presentation/widgets/user_avatar_widget.dart';

class ArticleDetailPage extends StatelessWidget {
  final String articleId;
  final VoidCallback? onBackOverride;

  const ArticleDetailPage({
    super.key,
    required this.articleId,
    this.onBackOverride,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        // Al abrir el detalle, intentamos cancelar la notificación local si existe
        sl<NotificationService>().cancelNotification(articleId.hashCode);

        return sl<ArticleDetailBloc>(
          param1: context.read<AuthBloc>(),
        )..add(LoadArticleDetail(articleId));
      },
      child: ArticleDetailView(onBackOverride: onBackOverride),
    );
  }
}

class ArticleDetailView extends StatelessWidget {
  final VoidCallback? onBackOverride;
  const ArticleDetailView({super.key, this.onBackOverride});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: BlocBuilder<ArticleDetailBloc, ArticleDetailState>(
        builder: (context, state) {
          // Título del AppBar: nombre de asociación cuando el artículo está cargado,
          // título genérico mientras carga o si hay error.
          final appBarTitle = state is ArticleDetailLoaded
              ? state.article.associationShortName != 'superadmin_access'
                  ? state.article.associationShortName
                  : l10n.articleTitle
              : l10n.articleTitle;
          return Scaffold(
            appBar: AppBar(
              title: Text(appBarTitle),
              leading: onBackOverride != null
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: onBackOverride,
                    )
                  : null,
            ),
            body: Builder(
              builder: (context) {
                if (state is ArticleDetailLoading ||
                    state is ArticleDetailInitial) {
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
                      if (constraints.maxWidth > AppTheme.breakpointWeb) {
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
    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat("dd 'de' MMMM 'de' yyyy", l10n.localeName);

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: AppTheme.maxWidthWebContent),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spaceMd, vertical: AppTheme.spaceSm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fila 1: Título
                _SectionContent(jsonContent: article.title, isTitle: true),
                const SizedBox(height: AppTheme.spaceMd),

                // Fila 2: Metadata
                _AuthorInfo(article: article),
                const SizedBox(height: AppTheme.spaceXxs),
                Text(
                  '${l10n.category}: ${article.categoryName} / ${article.subcategoryName}',
                  style: AppTheme.articleMeta(context),
                ),
                const SizedBox(height: AppTheme.spaceXs),

                // Fila 3: Fecha de publicación
                Text(
                  '${l10n.publishDateLabel}: ${dateFormat.format(article.publishDate)}',
                  style: AppTheme.articleMeta(context),
                ),
                const SizedBox(height: AppTheme.spaceMd),

                // Fila 4: Cover
                if (article.coverUrl.isNotEmpty)
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                          maxWidth: AppTheme.maxWidthCoverImage),
                      child: ClipRRect(
                        borderRadius: AppTheme.borderRadiusDefault,
                        child: CachedNetworkImage(
                          imageUrl: article.coverUrl,
                          fit: BoxFit.contain,
                          errorWidget: (context, url, error) =>
                              const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ),
                if (article.coverUrl.isNotEmpty)
                  const SizedBox(height: AppTheme.spaceMd),

                // Fila 5: Contenido (Abstract o Secciones)
                // Ocultar abstract si alguna sección tiene texto
                if (!article.sections.any((s) =>
                    quillJsonToPlainText(s.richTextContent ?? '').isNotEmpty))
                  _SectionContent(jsonContent: article.abstractContent),

                // Root Document Link
                if (article.documentLink != null &&
                    article.documentLink!.documentId.isNotEmpty)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppTheme.spaceSm),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SectionDocumentLinkWidget(
                          documentLink: article.documentLink!),
                    ),
                  ),

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
    // Definir los componentes básicos
    final imageWidget = (section.imageUrl != null &&
            section.imageUrl!.isNotEmpty)
        ? Padding(
            padding: const EdgeInsets.all(AppTheme.spaceXs),
            child: ClipRRect(
              borderRadius: AppTheme.borderRadiusDefault,
              child: CachedNetworkImage(
                imageUrl: section.imageUrl!,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => const SizedBox.shrink(),
              ),
            ),
          )
        : null;

    final hasTextContent =
        quillJsonToPlainText(section.richTextContent ?? '').isNotEmpty;

    final textWidget = hasTextContent
        ? Padding(
            padding: const EdgeInsets.all(AppTheme.spaceXs),
            child: _SectionContent(jsonContent: section.richTextContent!),
          )
        : null;

    final docWidget = section.documentLink != null
        ? Padding(
            padding: const EdgeInsets.all(AppTheme.spaceXs),
            child:
                SectionDocumentLinkWidget(documentLink: section.documentLink!),
          )
        : null;

    // COMPOSICIÓN D: Sólo enlace a documento
    if (docWidget != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceSm),
        child: Align(
          alignment: Alignment.centerLeft,
          child: docWidget,
        ),
      );
    }

    // COMPOSICIÓN B: Sólo imagen
    if (imageWidget != null && textWidget == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceSm),
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: AppTheme.maxWidthSectionImage),
            child: imageWidget,
          ),
        ),
      );
    }

    // COMPOSICIÓN C: Sólo texto
    if (imageWidget == null && textWidget != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceSm),
        child: textWidget, // Justificado a todo el ancho por defecto del widget
      );
    }

    // COMPOSICIÓN A: Imagen y texto (Alineación alterna)
    if (imageWidget != null && textWidget != null) {
      final children = isOdd
          ? [Expanded(child: imageWidget), Expanded(child: textWidget)]
          : [Expanded(child: textWidget), Expanded(child: imageWidget)];

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceSm),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

/// Layout para pantallas pequeñas (Móvil)
class _MobileLayout extends StatelessWidget {
  final ArticleEntity article;
  const _MobileLayout({required this.article});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat("d 'de' MMMM 'de' yyyy", l10n.localeName);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spaceSm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila 1: Título
          _SectionContent(jsonContent: article.title, isTitle: true),
          const SizedBox(height: AppTheme.spaceSm),

          // Fila 2: Metadata
          _AuthorInfo(article: article),
          const SizedBox(height: AppTheme.spaceXxs),
          Text(
            '${l10n.category}: ${article.categoryName} / ${article.subcategoryName}',
            style: AppTheme.articleMeta(context),
          ),
          const SizedBox(height: AppTheme.spaceXs),

          // Fila 3: Fecha de publicación
          Text(
            '${l10n.publishDateLabel}: ${dateFormat.format(article.publishDate)}',
            style: AppTheme.articleMeta(context),
          ),
          const SizedBox(height: AppTheme.spaceMd),

          // Fila 4: Cover
          if (article.coverUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spaceMd),
              child: ClipRRect(
                borderRadius: AppTheme.borderRadiusDefault,
                child: CachedNetworkImage(
                  imageUrl: article.coverUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorWidget: (context, url, error) => const SizedBox.shrink(),
                ),
              ),
            ),

          // Fila 5: Contenido (Abstract o Secciones)
          // Ocultar abstract si alguna sección tiene texto
          if (!article.sections.any(
              (s) => quillJsonToPlainText(s.richTextContent ?? '').isNotEmpty))
            _SectionContent(jsonContent: article.abstractContent),

          // Root Document Link
          if (article.documentLink != null &&
              article.documentLink!.documentId.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceSm),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SectionDocumentLinkWidget(
                    documentLink: article.documentLink!),
              ),
            ),

          if (article.sections.isNotEmpty)
            ...article.sections.map((section) {
              final hasImage =
                  section.imageUrl != null && section.imageUrl!.isNotEmpty;
              final hasText =
                  quillJsonToPlainText(section.richTextContent ?? '')
                      .isNotEmpty;
              final hasDoc = section.documentLink != null;

              return Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spaceMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // COMPOSICIÓN A: Imagen arriba, texto debajo
                    if (hasImage && hasText) ...[
                      ClipRRect(
                        borderRadius: AppTheme.borderRadiusDefault,
                        child: CachedNetworkImage(
                          imageUrl: section.imageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorWidget: (context, url, error) =>
                              const SizedBox.shrink(),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spaceXs),
                      _SectionContent(jsonContent: section.richTextContent!),
                    ]
                    // COMPOSICIÓN B: Sólo imagen (centrado)
                    else if (hasImage)
                      Center(
                        child: ClipRRect(
                          borderRadius: AppTheme.borderRadiusDefault,
                          child: CachedNetworkImage(
                            imageUrl: section.imageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorWidget: (context, url, error) =>
                                const SizedBox.shrink(),
                          ),
                        ),
                      )
                    // COMPOSICIÓN C: Sólo texto (ancho completo)
                    else if (hasText)
                      _SectionContent(jsonContent: section.richTextContent!)
                    // COMPOSICIÓN D: Sólo enlace a documento (izquierda)
                    else if (hasDoc)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: SectionDocumentLinkWidget(
                          documentLink: section.documentLink!,
                        ),
                      ),
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
  final l10n = AppLocalizations.of(context);
  String vigenciaText =
      '${l10n.effectivePublishDate} ${l10n.start} ${dateFormat.format(article.effectiveDate)}';
  if (article.expirationDate != null) {
    vigenciaText =
        '${l10n.effectivePublishDate} ${l10n.from} ${dateFormat.format(article.effectiveDate)} ${l10n.toThe} ${dateFormat.format(article.expirationDate!)}';
  }

  return Center(
    child: Text(
      vigenciaText,
      style: AppTheme.articleFooter(context),
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
        UserAvatarWidget(
          userId: article.userId,
          radius: AppTheme.avatarRadiusDefault,
        ),
        const SizedBox(width: AppTheme.spaceXs),
        Text(
          'Por ${article.authorName}',
          style: AppTheme.articleMeta(context),
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
        ? AppTheme.articleTitle(context)
        : AppTheme.articleBody(context);

    return quill.QuillEditor.basic(
      controller: _controller,
      config: quill.QuillEditorConfig(
        // Eliminamos el placeholder
        // placeholder: 'Contenido de solo lectura',
        padding: EdgeInsets.zero,
        customStyles: quill.DefaultStyles(
          paragraph: quill.DefaultTextBlockStyle(
            textStyle,
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
