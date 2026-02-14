import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:conectasoc/features/articles/presentation/bloc/bloc.dart';
import 'package:conectasoc/l10n/app_localizations.dart';
import 'preview_section.dart';

class ArticlePreview extends StatelessWidget {
  final ArticleEditLoaded state;
  final AppLocalizations l10n;
  final quill.QuillController titleController;
  final FocusNode titleFocusNode;
  final ScrollController titleScrollController;
  final quill.QuillController abstractController;
  final FocusNode abstractFocusNode;
  final ScrollController abstractScrollController;

  const ArticlePreview({
    super.key,
    required this.state,
    required this.l10n,
    required this.titleController,
    required this.titleFocusNode,
    required this.titleScrollController,
    required this.abstractController,
    required this.abstractFocusNode,
    required this.abstractScrollController,
  });

  @override
  Widget build(BuildContext context) {
    final article = state.article;
    final dateFormat = DateFormat.yMMMd(l10n.localeName);

    ImageProvider? imageProvider;
    if (state.newCoverImageBytes != null) {
      imageProvider = MemoryImage(state.newCoverImageBytes!);
    } else if (article.coverUrl.isNotEmpty) {
      imageProvider = CachedNetworkImageProvider(article.coverUrl);
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageProvider != null)
            Image(
              image: imageProvider,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 250,
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title (read-only)
                quill.QuillEditor(
                  controller: titleController,
                  focusNode: titleFocusNode,
                  scrollController: titleScrollController,
                  config: const quill.QuillEditorConfig(
                    padding: EdgeInsets.only(bottom: 8),
                  ),
                ),
                const SizedBox(height: 8),
                // Author and association info
                Row(
                  children: [
                    if (article.authorName.isNotEmpty)
                      Text(
                        'Por ${article.authorName}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    if (article.authorName.isNotEmpty &&
                        article.associationShortName.isNotEmpty)
                      Text(' • ', style: Theme.of(context).textTheme.bodySmall),
                    if (article.associationShortName.isNotEmpty)
                      Text(
                        article.associationShortName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                // Publish date
                Text(
                  '${l10n.publishDateLabel}: ${dateFormat.format(article.publishDate)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Divider(height: 24),
                // Abstract (read-only)
                quill.QuillEditor(
                  controller: abstractController,
                  focusNode: abstractFocusNode,
                  scrollController: abstractScrollController,
                  config: const quill.QuillEditorConfig(
                    padding: EdgeInsets.only(bottom: 16),
                  ),
                ),
                // Category metadata
                Text(
                  '${l10n.category}: ${article.categoryName} > ${l10n.subcategory}: ${article.subcategoryName}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Divider(height: 32),
                // Sections
                ...article.sections.map((section) => PreviewSection(
                      state: state,
                      section: section,
                    )),
                const Divider(height: 48),
                // Footer with effective dates
                Center(
                  child: Text(
                    article.expirationDate != null
                        ? '${l10n.effectivePublishDate} ${l10n.from} ${dateFormat.format(article.effectiveDate)} ${l10n.toThe} ${dateFormat.format(article.expirationDate!)}'
                        : '${l10n.effectivePublishDate} ${l10n.start} ${dateFormat.format(article.effectiveDate)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
