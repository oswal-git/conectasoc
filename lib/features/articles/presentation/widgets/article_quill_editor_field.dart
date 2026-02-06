import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class ArticleQuillEditorField extends StatelessWidget {
  final String label;
  final quill.QuillController controller;
  final FocusNode focusNode;
  final ScrollController scrollController;
  final int charCount;
  final int maxCharCount;
  final double height;
  final double iconButtonFactor;
  final bool showFontSize;
  final bool showFontFamily;
  final bool multiRowsDisplay;

  const ArticleQuillEditorField({
    super.key,
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.scrollController,
    required this.charCount,
    required this.maxCharCount,
    required this.height,
    this.iconButtonFactor = 1.0,
    this.showFontSize = false,
    this.showFontFamily = false,
    this.multiRowsDisplay = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        quill.QuillSimpleToolbar(
          controller: controller,
          config: quill.QuillSimpleToolbarConfig(
            showAlignmentButtons: true,
            multiRowsDisplay: multiRowsDisplay,
            showBoldButton: true,
            showItalicButton: true,
            showUnderLineButton: true,
            showStrikeThrough: true,
            showColorButton: true,
            showBackgroundColorButton: true,
            showListBullets: false,
            showListNumbers: false,
            showListCheck: false,
            showCodeBlock: false,
            showQuote: false,
            showIndent: false,
            showLink: false,
            showUndo: true,
            showRedo: true,
            showFontSize: showFontSize,
            showFontFamily: showFontFamily,
            showClearFormat: false,
            showHeaderStyle: false,
            showSearchButton: false,
            buttonOptions: quill.QuillSimpleToolbarButtonOptions(
              base: quill.QuillToolbarBaseButtonOptions(
                iconButtonFactor: iconButtonFactor,
              ),
            ),
            toolbarRunSpacing: 0,
            toolbarSectionSpacing: 0,
          ),
        ),
        Container(
          height: height,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: quill.QuillEditor.basic(
            controller: controller,
            focusNode: focusNode,
            scrollController: scrollController,
            config: const quill.QuillEditorConfig(
              padding: EdgeInsets.all(8),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '$charCount / $maxCharCount',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: charCount > maxCharCount ? Colors.red : Colors.grey,
                ),
          ),
        ),
      ],
    );
  }
}
