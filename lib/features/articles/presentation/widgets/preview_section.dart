import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:conectasoc/features/articles/domain/entities/entities.dart';
import 'package:conectasoc/features/articles/presentation/bloc/bloc.dart';
import 'section_image.dart';

class PreviewSection extends StatelessWidget {
  final ArticleEditLoaded state;
  final ArticleSection section;

  const PreviewSection({
    super.key,
    required this.state,
    required this.section,
  });

  @override
  Widget build(BuildContext context) {
    final quill.QuillController? contentController =
        section.richTextContent != null && section.richTextContent!.isNotEmpty
            ? quill.QuillController(
                document: quill.Document.fromJson(
                    jsonDecode(section.richTextContent!)),
                selection: const TextSelection.collapsed(offset: 0),
              )
            : null;
    final FocusNode contentFocusNode = FocusNode();
    final ScrollController contentScrollController = ScrollController();

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionImage(
            imageBytes: state.newSectionImageBytes[section.id],
            imageUrl: section.imageUrl,
          ),
          if (contentController != null)
            quill.QuillEditor(
              controller: contentController,
              focusNode: contentFocusNode,
              scrollController: contentScrollController,
              config: const quill.QuillEditorConfig(
                padding: EdgeInsets.zero,
              ),
            ),
        ],
      ),
    );
  }
}
