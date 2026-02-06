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
                // Title
                quill.QuillEditor(
                  controller: titleController,
                  focusNode: titleFocusNode,
                  scrollController: titleScrollController,
                  config: const quill.QuillEditorConfig(
                    padding: EdgeInsets.only(bottom: 8),
                  ),
                ),
                // Abstract
                quill.QuillEditor(
                  controller: abstractController,
                  focusNode: abstractFocusNode,
                  scrollController: abstractScrollController,
                  config: const quill.QuillEditorConfig(
                    padding: EdgeInsets.only(bottom: 16),
                  ),
                ),
                // Metadata
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
                // Sections
                ...article.sections.map((section) => PreviewSection(
                      state: state,
                      section: section,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
