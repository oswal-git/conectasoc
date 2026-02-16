import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:conectasoc/core/services/image_picker_service.dart';
import 'package:conectasoc/features/articles/domain/entities/entities.dart';
import 'package:conectasoc/features/articles/presentation/bloc/bloc.dart';
import 'package:conectasoc/l10n/app_localizations.dart';
import 'section_image.dart';

class ArticleSectionEditor extends StatefulWidget {
  final ArticleSection section;
  final int index;
  final VoidCallback onRemove;
  final bool isEditingEnabled;
  final bool showDragHandle;

  const ArticleSectionEditor({
    super.key,
    required this.section,
    required this.index,
    required this.onRemove,
    required this.isEditingEnabled,
    this.showDragHandle = true,
  });

  @override
  State<ArticleSectionEditor> createState() => _ArticleSectionEditorState();
}

class _ArticleSectionEditorState extends State<ArticleSectionEditor> {
  late quill.QuillController _quillController;
  late FocusNode _focusNode;
  late ScrollController _scrollController;
  Timer? _debounceTimer;
  final ImagePickerService _imagePickerService = ImagePickerService();

  @override
  void initState() {
    super.initState();
    _quillController = quill.QuillController.basic();
    _focusNode = FocusNode();
    _scrollController = ScrollController();
    _loadContent();

    _quillController.readOnly = !widget.isEditingEnabled;
    _quillController.addListener(_onContentChanged);
  }

  @override
  void didUpdateWidget(covariant ArticleSectionEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.section.richTextContent != widget.section.richTextContent) {
      _loadContent();
    }
    if (oldWidget.isEditingEnabled != widget.isEditingEnabled) {
      _quillController.readOnly = !widget.isEditingEnabled;
    }
  }

  void _loadContent() {
    if (widget.section.richTextContent != null &&
        widget.section.richTextContent!.isNotEmpty) {
      _quillController.document =
          quill.Document.fromJson(jsonDecode(widget.section.richTextContent!));
    } else {
      _quillController.document = quill.Document()..insert(0, '');
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _quillController.removeListener(_onContentChanged);
    _quillController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onContentChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      final newContentJson =
          jsonEncode(_quillController.document.toDelta().toJson());
      if (newContentJson != widget.section.richTextContent) {
        context.read<ArticleEditBloc>().add(
              UpdateSectionContent(widget.section.id, newContentJson),
            );
      }
    });
  }

  Future<void> _pickImage() async {
    final bytes = await _imagePickerService.pickImage(context);
    if (!mounted) return;

    if (bytes != null) {
      context.read<ArticleEditBloc>().add(
            UpdateSectionImage(widget.section.id, bytes),
          );
    }
  }

  Future<void> _confirmRemoveSection() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.removeSection),
        content: Text(l10n.removeSectionConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      widget.onRemove();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Using BlocSelector for image bytes to prevent rebuilding for other state changes.
    return BlocSelector<ArticleEditBloc, ArticleEditState, Uint8List?>(
      selector: (state) {
        if (state is ArticleEditLoaded) {
          return state.newSectionImageBytes[widget.section.id];
        }
        return null;
      },
      builder: (context, imageBytes) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${l10n.section} ${widget.index + 1}',
                        style: Theme.of(context).textTheme.titleMedium),
                    Row(
                      children: widget.isEditingEnabled
                          ? [
                              IconButton(
                                  onPressed: _pickImage,
                                  icon: const Icon(Icons.image)),
                              IconButton(
                                  onPressed: _confirmRemoveSection,
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red)),
                              if (widget.showDragHandle)
                                ReorderableDragStartListener(
                                  index: widget.index,
                                  child: const Icon(Icons.drag_handle),
                                ),
                            ]
                          : [],
                    ),
                  ],
                ),
                SectionImage(
                  imageBytes: imageBytes,
                  imageUrl: widget.section.imageUrl,
                ),
                if (widget.isEditingEnabled)
                  quill.QuillSimpleToolbar(
                    controller: _quillController,
                    config: quill.QuillSimpleToolbarConfig(
                      showAlignmentButtons: true,
                      multiRowsDisplay: false,
                      showBoldButton: true,
                      showItalicButton: true,
                      showUnderLineButton: true,
                      showStrikeThrough: true,
                      showColorButton: true,
                      showBackgroundColorButton: true,
                      showListBullets: true,
                      showListNumbers: true,
                      showListCheck: true,
                      showCodeBlock: true,
                      showQuote: true,
                      showIndent: true,
                      showLink: true,
                      showUndo: true,
                      showRedo: true,
                      showFontSize: true,
                      showFontFamily: true,
                      showClearFormat: true,
                      showHeaderStyle: true,
                      showSearchButton: true,
                      buttonOptions: quill.QuillSimpleToolbarButtonOptions(
                        base: quill.QuillToolbarBaseButtonOptions(
                          iconButtonFactor: 1.0,
                        ),
                        fontSize: quill.QuillToolbarFontSizeButtonOptions(
                          items: {
                            'Small': '12',
                            'Medium': '16',
                            'Large': '20',
                            'Clear': '0'
                          },
                        ),
                      ),
                      toolbarRunSpacing: 0,
                      toolbarSectionSpacing: 0,
                    ),
                  ),
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: quill.QuillEditor(
                      controller: _quillController,
                      focusNode: _focusNode,
                      scrollController: _scrollController,
                      config: const quill.QuillEditorConfig(
                          padding: EdgeInsets.all(8))),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
