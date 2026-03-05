import 'dart:async';
import 'dart:convert';

import 'package:conectasoc/features/articles/presentation/bloc/edit/article_edit_bloc.dart';
import 'package:conectasoc/features/articles/presentation/bloc/edit/article_edit_event.dart';
import 'package:conectasoc/features/articles/presentation/bloc/edit/article_edit_state.dart';
import 'package:conectasoc/features/articles/presentation/widgets/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:conectasoc/features/articles/domain/entities/entities.dart';
import 'package:conectasoc/l10n/app_localizations.dart';
import 'package:conectasoc/services/snackbar_service.dart';

class ArticleEditView extends StatefulWidget {
  const ArticleEditView({super.key});

  @override
  State<ArticleEditView> createState() => _ArticleEditViewState();
}

class _ArticleEditViewState extends State<ArticleEditView> {
  final _formKey = GlobalKey<FormState>();
  bool _isPreviewMode = false;

  late quill.QuillController _titleController;
  late quill.QuillController _abstractController;
  Timer? _debounceTimer;

  late FocusNode _titleFocusNode;
  late FocusNode _abstractFocusNode;
  late ScrollController _titleScrollController;
  late ScrollController _abstractScrollController;
  late ScrollController _formScrollController;
  late ScrollController _previewScrollController;

  ArticleEntity? _lastSyncedArticle;
  int _titleCharCount = 0;
  int _abstractCharCount = 0;

  @override
  void initState() {
    super.initState();
    _titleController = quill.QuillController.basic();
    _abstractController = quill.QuillController.basic();
    _titleController.formatSelection(quill.Attribute.h1);
    _abstractController.formatSelection(quill.Attribute.header);

    _titleFocusNode = FocusNode();
    _abstractFocusNode = FocusNode();
    _abstractScrollController = ScrollController();
    _titleScrollController = ScrollController();

    _titleController.addListener(_onTitleChanged);
    _abstractController.addListener(_onAbstractChanged);
    _titleController.addListener(_updateTitleCharCount);
    _abstractController.addListener(_updateAbstractCharCount);

    _formScrollController = ScrollController();
    _previewScrollController = ScrollController();
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTitleChanged);
    _abstractController.removeListener(_onAbstractChanged);
    _titleController.removeListener(_updateTitleCharCount);
    _abstractController.removeListener(_updateAbstractCharCount);
    _titleController.dispose();
    _abstractController.dispose();
    _titleFocusNode.dispose();
    _abstractFocusNode.dispose();
    _titleScrollController.dispose();
    _abstractScrollController.dispose();
    _formScrollController.dispose();
    _previewScrollController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _updateTitleCharCount() {
    final plainText = _titleController.document.toPlainText().trim();
    if (mounted) setState(() => _titleCharCount = plainText.length);
  }

  void _updateAbstractCharCount() {
    final plainText = _abstractController.document.toPlainText().trim();
    if (mounted) setState(() => _abstractCharCount = plainText.length);
  }

  void _onTitleChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      final currentState = context.read<ArticleEditBloc>().state;
      if (currentState is ArticleEditLoaded) {
        final newTitleJson =
            jsonEncode(_titleController.document.toDelta().toJson());
        if (currentState.article.title != newTitleJson) {
          context.read<ArticleEditBloc>().add(
                ArticleFieldChanged(
                    currentState.article.copyWith(title: newTitleJson)),
              );
        }
      }
    });
  }

  void _onAbstractChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      final currentState = context.read<ArticleEditBloc>().state;
      if (currentState is ArticleEditLoaded) {
        final newAbstractJson =
            jsonEncode(_abstractController.document.toDelta().toJson());
        if (currentState.article.abstractContent != newAbstractJson) {
          context.read<ArticleEditBloc>().add(
                ArticleFieldChanged(currentState.article
                    .copyWith(abstractContent: newAbstractJson)),
              );
        }
      }
    });
  }

  void _syncQuillControllers(ArticleEntity article) {
    if (_lastSyncedArticle == article) return;

    final currentTitleJson =
        jsonEncode(_titleController.document.toDelta().toJson());
    if (currentTitleJson != article.title) {
      _titleController.document = quill.Document.fromJson(
        jsonDecode(
            article.title.isEmpty ? '[{"insert":"\\n"}]' : article.title),
      );
      _titleController.moveCursorToEnd();
    }

    final currentAbstractJson =
        jsonEncode(_abstractController.document.toDelta().toJson());
    if (currentAbstractJson != article.abstractContent) {
      _abstractController.document = quill.Document.fromJson(
        jsonDecode(article.abstractContent.isEmpty
            ? '[{"insert":"\\n"}]'
            : article.abstractContent),
      );
      _abstractController.moveCursorToEnd();
    }

    _lastSyncedArticle = article;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<ArticleEditBloc, ArticleEditState>(
      builder: (context, state) {
        final bool isCreating = state is! ArticleEditLoaded ||
            state.article.id.isEmpty ||
            state.isCreating;
        final String title = isCreating ? l10n.createArticle : l10n.editArticle;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            if (state is ArticleEditLoaded && state.isDirty) {
              _showExitConfirmationDialog(context, l10n);
            } else {
              context.pop();
            }
          },
          child: Scaffold(
            appBar: _buildAppBar(context, state, title, l10n),
            body: BlocListener<ArticleEditBloc, ArticleEditState>(
              listener: (context, state) {
                if (state is ArticleEditSuccess) {
                  final message = state.isCreating
                      ? l10n.articleCreatedSuccess
                      : l10n.articleUpdatedSuccess;
                  SnackBarService.showSnackBar(message);
                  context.pop();
                } else if (state is ArticleEditLoaded) {
                  _syncQuillControllers(state.article);
                  if (state.errorMessage != null) {
                    SnackBarService.showSnackBar(state.errorMessage!() ?? '',
                        isError: true);
                  }
                } else if (state is ArticleEditDraftFound) {
                  final bloc = context.read<ArticleEditBloc>();
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (dialogContext) => AlertDialog(
                      title: Text(l10n.draftFoundTitle),
                      content: Text(l10n.draftFoundMessage),
                      actions: [
                        TextButton(
                          onPressed: () {
                            bloc.add(DiscardDraft(state.originalArticle));
                            Navigator.of(dialogContext).pop();
                          },
                          child: Text(l10n.discard),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            bloc.add(const RestoreDraft());
                            Navigator.of(dialogContext).pop();
                          },
                          child: Text(l10n.restore),
                        ),
                      ],
                    ),
                  );
                } else if (state is ArticleEditFailure) {
                  SnackBarService.showSnackBar(state.message, isError: true);
                }
              },
              child: _buildBody(state, l10n),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ArticleEditState state,
    String title,
    AppLocalizations l10n,
  ) {
    final bool isSaving = state is ArticleEditLoaded && state.isSaving;

    return AppBar(
      title: Text(title),
      actions: [
        if (state is ArticleEditLoaded) ...[
          IconButton(
            icon: Icon(_isPreviewMode ? Icons.edit : Icons.preview),
            tooltip: _isPreviewMode ? l10n.editArticle : l10n.preview,
            onPressed: isSaving
                ? null
                : () => setState(() => _isPreviewMode = !_isPreviewMode),
          ),
          if (!_isPreviewMode && state.canEditContent)
            isSaving
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.save),
                    tooltip: l10n.save,
                    onPressed: () => context
                        .read<ArticleEditBloc>()
                        .add(const SaveArticle()),
                  ),
        ],
      ],
    );
  }

  Widget _buildBody(ArticleEditState state, AppLocalizations l10n) {
    if (state is ArticleEditLoading ||
        state is ArticleEditInitial ||
        state is ArticleEditDraftFound) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is ArticleEditLoaded) {
      final bool isSaving = state.isSaving;

      return Stack(
        children: [
          _isPreviewMode
              ? ArticlePreview(
                  state: state,
                  l10n: l10n,
                  scrollController: _previewScrollController,
                  titleController: _titleController,
                  titleFocusNode: _titleFocusNode,
                  titleScrollController: _titleScrollController,
                  abstractController: _abstractController,
                  abstractFocusNode: _abstractFocusNode,
                  abstractScrollController: _abstractScrollController,
                )
              : buildForm(context, state, l10n),
          if (isSaving)
            Container(
              color: Colors.black26,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Guardando artículo...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    } else if (state is ArticleEditFailure) {
      return Center(child: Text(state.message));
    }
    return const SizedBox.shrink();
  }

  Widget buildForm(
    BuildContext context,
    ArticleEditLoaded state,
    AppLocalizations l10n,
  ) {
    final bool isEditingEnabled = state.canEditContent;

    _titleController.readOnly = !isEditingEnabled;
    _abstractController.readOnly = !isEditingEnabled;

    double parIconButtonFactor = 1.0;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        controller: _formScrollController,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Portada ──────────────────────────────────────────────────
            CoverImagePicker(
              key: ValueKey('cover_picker_$isEditingEnabled'),
              isEnabled: isEditingEnabled,
              currentCoverUrl: state.article.coverUrl,
              newImageBytes: state.newCoverImageBytes,
              onImageSelected: (bytes) {
                context.read<ArticleEditBloc>().add(UpdateCoverImage(bytes));
              },
              onImageCleared: () => context
                  .read<ArticleEditBloc>()
                  .add(const UpdateCoverImage(null)),
            ),

            // ── Título ───────────────────────────────────────────────────
            BlocSelector<ArticleEditBloc, ArticleEditState, int>(
              selector: (state) =>
                  (state is ArticleEditLoaded) ? _titleCharCount : 0,
              builder: (context, charCount) {
                return ArticleQuillEditorField(
                  label: l10n.title,
                  controller: _titleController,
                  focusNode: _titleFocusNode,
                  scrollController: _titleScrollController,
                  charCount: charCount,
                  maxCharCount: 100,
                  height: 100,
                  iconButtonFactor: parIconButtonFactor,
                  showFontSize: false,
                  showFontFamily: false,
                );
              },
            ),
            const SizedBox(height: 16),

            // ── Resumen ──────────────────────────────────────────────────
            BlocSelector<ArticleEditBloc, ArticleEditState, int>(
              selector: (state) =>
                  (state is ArticleEditLoaded) ? _abstractCharCount : 0,
              builder: (context, charCount) {
                return ArticleQuillEditorField(
                  label: l10n.abstractContent,
                  controller: _abstractController,
                  focusNode: _abstractFocusNode,
                  scrollController: _abstractScrollController,
                  charCount: charCount,
                  maxCharCount: 200,
                  height: 150,
                  iconButtonFactor: parIconButtonFactor,
                  showFontSize: true,
                  showFontFamily: true,
                );
              },
            ),
            const SizedBox(height: 24),

            // ── Categoría / Subcategoría ─────────────────────────────────
            CategorySelectorSection(
              isEnabled: isEditingEnabled,
              categoryId: state.article.categoryId,
              subcategoryId: state.article.subcategoryId,
              categories: state.categories,
              subcategories: state.subcategories,
              l10n: l10n,
            ),
            const SizedBox(height: 24),

            // ── Estado ───────────────────────────────────────────────────
            BlocSelector<ArticleEditBloc, ArticleEditState, ArticleStatus>(
              selector: (state) => (state is ArticleEditLoaded)
                  ? state.status
                  : ArticleStatus.redaccion,
              builder: (context, status) {
                return StatusDropdownSection(
                  status: status,
                  isArticleValid: state.isArticleValid,
                  l10n: l10n,
                );
              },
            ),
            const SizedBox(height: 24),

            // ── Fechas ───────────────────────────────────────────────────
            DatePickerSection(
              isEnabled: isEditingEnabled,
              publishDate: state.article.publishDate,
              effectiveDate: state.article.effectiveDate,
              expirationDate: state.article.expirationDate,
              l10n: l10n,
            ),
            const SizedBox(height: 24),

            // ✨ NUEVO: Documento enlazado al artículo ────────────────────
            // _buildArticleDocumentSection(
            //     context, state, isEditingEnabled, l10n),
            // const SizedBox(height: 32),

            // ── Secciones ────────────────────────────────────────────────
            Text('--- ${l10n.sections.toUpperCase()} ---',
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ArticleSectionListWidget(isEditingEnabled: isEditingEnabled),
            const SizedBox(height: 16),
            if (isEditingEnabled)
              ElevatedButton.icon(
                onPressed: () =>
                    context.read<ArticleEditBloc>().add(const AddSection()),
                icon: const Icon(Icons.add),
                label: Text(l10n.addSection),
              ),
            if (isEditingEnabled) const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  // ✨ NUEVO: sección de documento a nivel de artículo
  // Widget _buildArticleDocumentSection(
  //   BuildContext context,
  //   ArticleEditLoaded state,
  //   bool isEditingEnabled,
  //   AppLocalizations l10n,
  // ) {
  //   return Card(
  //     child: Padding(
  //       padding: const EdgeInsets.all(12),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             l10n.linkDocument,
  //             style: Theme.of(context).textTheme.titleSmall?.copyWith(
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //           ),
  //           const SizedBox(height: 4),
  //           Text(
  //             'Documento adjunto al artículo completo',
  //             style: Theme.of(context)
  //                 .textTheme
  //                 .bodySmall
  //                 ?.copyWith(color: Colors.grey),
  //           ),
  //           const SizedBox(height: 12),
  //           DocumentPickerWidget(
  //             currentDocumentLink: state.article.documentLink,
  //             isEnabled: isEditingEnabled,
  //             onDocumentSelected: (DocumentLinkEntity? link) {
  //               context
  //                   .read<ArticleEditBloc>()
  //                   .add(UpdateArticleDocumentLink(link));
  //             },
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Future<void> _showExitConfirmationDialog(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.unsavedChanges),
        content: Text(l10n.unsavedChangesMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child:
                Text(l10n.discard, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) context.pop();
  }
}
