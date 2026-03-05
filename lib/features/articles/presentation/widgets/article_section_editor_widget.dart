import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:conectasoc/features/documents/domain/entities/entities.dart';
import 'package:conectasoc/features/documents/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:conectasoc/core/services/image_picker_service.dart';
import 'package:conectasoc/features/articles/domain/entities/entities.dart';
import 'package:conectasoc/features/articles/presentation/bloc/bloc.dart';
import 'package:conectasoc/l10n/app_localizations.dart';
import 'section_image.dart';

class ArticleSectionEditorWidget extends StatefulWidget {
  final ArticleSection section;
  final int index;
  final VoidCallback onRemove;
  final bool isEditingEnabled;
  final bool showDragHandle;

  const ArticleSectionEditorWidget({
    super.key,
    required this.section,
    required this.index,
    required this.onRemove,
    required this.isEditingEnabled,
    this.showDragHandle = true,
  });

  @override
  State<ArticleSectionEditorWidget> createState() =>
      _ArticleSectionEditorWidgetState();
}

class _ArticleSectionEditorWidgetState
    extends State<ArticleSectionEditorWidget> {
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
  void didUpdateWidget(covariant ArticleSectionEditorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.section.richTextContent != widget.section.richTextContent) {
      // Prevenir recarga del editor (y reseteo del cursor) si el cambio proviene de nosotros mismos
      final currentJson =
          jsonEncode(_quillController.document.toDelta().toJson());
      if (currentJson != widget.section.richTextContent) {
        _loadContent();
      }
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

  Future<void> _removeImage() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n
            .removeSection), // Usar un texto adecuado, o crear uno nuevo si existe para imagen. Usamos el de borrar por ahora. O mejor texto genérico.
        content: const Text(
            '¿Estás seguro de que quieres eliminar esta imagen?'), // TODO: move to l10n if needed
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

    if (confirmed == true && mounted) {
      context.read<ArticleEditBloc>().add(
            UpdateSectionImage(widget.section.id, null),
          );
    }
  }

  void _onDocumentSelected(DocumentLinkEntity? documentLink) {
    context.read<ArticleEditBloc>().add(
          UpdateSectionDocumentLink(widget.section.id, documentLink),
        );
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
    final section = widget.section;

    final hasDocument = section.hasDocument;

    // Using BlocSelector for image bytes to prevent rebuilding for other state changes.
    return BlocSelector<ArticleEditBloc, ArticleEditState, Uint8List?>(
      selector: (state) {
        if (state is ArticleEditLoaded) {
          return state.newSectionImageBytes[widget.section.id];
        }
        return null;
      },
      builder: (context, imageBytes) {
        // Usamos el controlador para saber de forma precisa si el editor está vacío.
        // Convertimos a texto plano y limpiamos espacios para ignorar saltos de línea y formato vacío.
        final hasTextContent =
            _quillController.document.toPlainText().trim().isNotEmpty;
        final hasContent =
            (section.imageUrl != null && section.imageUrl!.isNotEmpty) ||
                hasTextContent ||
                imageBytes != null;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Cabecera con título y acciones ───────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${l10n.section} ${widget.index + 1}',
                        style: Theme.of(context).textTheme.titleMedium),
                    if (widget.isEditingEnabled)
                      Row(
                        children: [
                          // Imagen: Oculta si hay documento
                          if (!hasDocument)
                            IconButton(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.image),
                              tooltip: 'Añadir imagen',
                            ),
                          // Eliminar sección
                          IconButton(
                            onPressed: _confirmRemoveSection,
                            icon: const Icon(Icons.delete, color: Colors.red),
                          ),
                          // Reordenar
                          ReorderableDragStartListener(
                            index: widget.index,
                            child: const Icon(Icons.drag_handle),
                          ),
                        ],
                      ),
                  ],
                ),
                // ── Imagen de la sección ─────────────────────────────────
                if (!hasDocument)
                  SectionImage(
                    imageBytes: imageBytes,
                    imageUrl: section.imageUrl,
                    onRemove: widget.isEditingEnabled &&
                            (imageBytes != null ||
                                (section.imageUrl != null &&
                                    section.imageUrl!.isNotEmpty))
                        ? _removeImage
                        : null,
                  ),
                // ── Editor de texto enriquecido ──────────────────────────
                if (!hasDocument) ...[
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
                              'Clear': '0',
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
                          padding: EdgeInsets.all(8)),
                    ),
                  ),
                ],

                // ── DocumentPickerWidget ─────────────────────────────────
                if (!hasContent) ...[
                  if (widget.isEditingEnabled) const SizedBox(height: 8),
                  DocumentPickerWidget(
                    currentDocumentLink: section.documentLink,
                    isEnabled: widget.isEditingEnabled,
                    onDocumentSelected: _onDocumentSelected,
                  ),
                ]
              ],
            ),
          ),
        );
      },
    );
  }
}
