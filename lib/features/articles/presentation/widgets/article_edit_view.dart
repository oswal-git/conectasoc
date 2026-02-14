import 'dart:async';
import 'dart:convert';

import 'package:conectasoc/features/articles/presentation/bloc/edit/article_edit_bloc.dart';
import 'package:conectasoc/features/articles/presentation/bloc/edit/article_edit_event.dart';
import 'package:conectasoc/features/articles/presentation/bloc/edit/article_edit_state.dart';
import 'package:conectasoc/features/articles/presentation/widgets/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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

  // State for toggling between edit and preview mode
  bool _isPreviewMode = false;

  // Controladores para los editores de texto enriquecido
  late quill.QuillController _titleController;
  late quill.QuillController _abstractController;
  Timer? _debounceTimer; // Para debouncing de los cambios en Quill

  // FocusNodes y ScrollControllers - CRÍTICO: deben ser persistentes
  late FocusNode _titleFocusNode;
  late FocusNode _abstractFocusNode;
  late ScrollController _titleScrollController;
  late ScrollController
      _abstractScrollController; // Already declared, but ensure it's used

  // Mantener un registro del último artículo sincronizado para evitar actualizaciones redundantes
  ArticleEntity? _lastSyncedArticle;

  int _titleCharCount = 0;
  int _abstractCharCount = 0;

  @override
  void initState() {
    super.initState();
    _titleController = quill.QuillController.basic();
    _abstractController = quill.QuillController.basic();

    // Set default styles
    _titleController.formatSelection(quill.Attribute.h1);
    _abstractController
        .formatSelection(quill.Attribute.header); // Normal style (reset header)

    _titleFocusNode = FocusNode();
    _abstractFocusNode = FocusNode();
    _abstractScrollController = ScrollController();
    _titleScrollController = ScrollController();

    _titleController.addListener(_onTitleChanged);
    _abstractController.addListener(_onAbstractChanged);
    _titleController.addListener(_updateTitleCharCount);
    _abstractController.addListener(_updateAbstractCharCount);
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTitleChanged);
    _abstractController.removeListener(_onAbstractChanged);
    _titleController.dispose();
    _titleController.removeListener(_updateTitleCharCount);
    _abstractController.removeListener(_updateAbstractCharCount);
    _abstractController.dispose();
    _titleFocusNode.dispose();
    _abstractFocusNode.dispose();
    _titleScrollController.dispose();
    _abstractScrollController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _updateTitleCharCount() {
    final plainText = _titleController.document.toPlainText().trim();
    if (mounted) {
      setState(() {
        _titleCharCount = plainText.length;
      });
    }
  }

  void _updateAbstractCharCount() {
    final plainText = _abstractController.document.toPlainText().trim();
    if (mounted) {
      setState(() {
        _abstractCharCount = plainText.length;
      });
    }
  }

  void _onTitleChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      final currentArticleState = context.read<ArticleEditBloc>().state;
      if (currentArticleState is ArticleEditLoaded) {
        final newTitleJson =
            jsonEncode(_titleController.document.toDelta().toJson());
        // Solo despachar si el contenido ha cambiado realmente para evitar eventos redundantes
        // Also check if the current state's article title is different from the new one
        if (currentArticleState.article.title != newTitleJson) {
          context.read<ArticleEditBloc>().add(
                ArticleFieldChanged(
                    currentArticleState.article.copyWith(title: newTitleJson)),
              );
        }
      }
    });
  }

  void _onAbstractChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      final currentArticleState = context.read<ArticleEditBloc>().state;
      if (currentArticleState is ArticleEditLoaded) {
        final newAbstractJson =
            jsonEncode(_abstractController.document.toDelta().toJson());
        // Solo despachar si el contenido ha cambiado realmente para evitar eventos redundantes
        // Also check if the current state's article abstract content is different from the new one
        if (currentArticleState.article.abstractContent != newAbstractJson) {
          context.read<ArticleEditBloc>().add(
                ArticleFieldChanged(currentArticleState.article
                    .copyWith(abstractContent: newAbstractJson)),
              );
        }
      }
    });
  }

  /// Sincroniza el contenido de los controladores de Quill con el estado del artículo.
  /// Se llama desde el BlocListener para asegurar que solo se ejecute cuando los datos cambian.
  void _syncQuillControllers(ArticleEntity article) {
    // Prevenir la sincronización si el artículo no ha cambiado o si es el mismo que el último sincronizado
    if (_lastSyncedArticle == article) {
      return; // No hacer nada si el artículo no ha cambiado.
    }

    // Only update if the content has actually changed to avoid cursor issues
    final currentTitleJson =
        jsonEncode(_titleController.document.toDelta().toJson());
    if (currentTitleJson != article.title) {
      _titleController.document = quill.Document.fromJson(
        jsonDecode(
            article.title.isEmpty ? '[{"insert":"\\n"}]' : article.title),
      );
      _titleController.moveCursorToEnd(); // Keep cursor at end after update
    }

    final currentAbstractJson =
        jsonEncode(_abstractController.document.toDelta().toJson());
    if (currentAbstractJson != article.abstractContent) {
      _abstractController.document = quill.Document.fromJson(
        jsonDecode(article.abstractContent.isEmpty
            ? '[{"insert":"\\n"}]'
            : article.abstractContent),
      );
      _abstractController.moveCursorToEnd(); // Keep cursor at end after update
    }

    _lastSyncedArticle = article;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<ArticleEditBloc, ArticleEditState>(
      builder: (context, state) {
        // Determine the title based on the state.
        final bool isCreating = state is! ArticleEditLoaded ||
            state.article.id.isEmpty ||
            state.isCreating;
        final String title = isCreating ? l10n.createArticle : l10n.editArticle;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (bool didPop, dynamic result) async {
            if (didPop) return;

            // Check if there are unsaved changes
            bool hasUnsavedChanges = false;
            if (state is ArticleEditLoaded) {
              // Consider changes unsaved if the article has been modified
              // We can check this by comparing with a saved state or checking if isSaving is false
              // For simplicity, we'll show the dialog if not currently saving
              hasUnsavedChanges = !state.isSaving;
            }

            if (!hasUnsavedChanges || !context.mounted) {
              Navigator.of(context).pop();
              return;
            }

            // Show confirmation dialog
            final shouldPop = await showDialog<bool>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: Text(l10n.unsavedChangesTitle),
                content: Text(l10n.unsavedChangesMessage),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: Text(l10n.stay),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    child: Text(l10n.leaveWithoutSaving),
                  ),
                ],
              ),
            );

            if (shouldPop == true && context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(title),
              actions: [
                IconButton(
                  icon: Icon(_isPreviewMode ? Icons.edit : Icons.visibility),
                  tooltip: _isPreviewMode
                      ? l10n.edit
                      : l10n.previewMode, // Localized
                  onPressed: () {
                    setState(() {
                      _isPreviewMode = !_isPreviewMode;
                    });
                  },
                ),
                if (state is ArticleEditLoaded)
                  IconButton(
                    icon: const Icon(Icons.save),
                    // El botón de guardar se habilita/deshabilita según el estado
                    onPressed: state.isArticleValid
                        ? () {
                            if (_isPreviewMode) {
                              setState(() {
                                _isPreviewMode = false;
                              });
                            }
                            SchedulerBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                context
                                    .read<ArticleEditBloc>()
                                    .add(const SaveArticle());
                              }
                            });
                          }
                        : null, // Se deshabilita si no es válido
                  ),
              ],
            ),
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

  Widget _buildBody(ArticleEditState state, AppLocalizations l10n) {
    if (state is ArticleEditLoading ||
        state is ArticleEditInitial ||
        state is ArticleEditDraftFound) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is ArticleEditLoaded) {
      return _isPreviewMode
          ? ArticlePreview(
              state: state,
              l10n: l10n,
              titleController: _titleController,
              titleFocusNode: _titleFocusNode,
              titleScrollController: _titleScrollController,
              abstractController: _abstractController,
              abstractFocusNode: _abstractFocusNode,
              abstractScrollController: _abstractScrollController,
            )
          : buildForm(context, state, l10n);
    } else if (state is ArticleEditFailure) {
      return Center(child: Text(state.message));
    }
    return const SizedBox.shrink();
  }

  Widget buildForm(
      BuildContext context, ArticleEditLoaded state, AppLocalizations l10n) {
    // La edición está habilitada si estamos creando un nuevo artículo O si el estado es 'En redacción'.
    final bool isEditingEnabled =
        state.isCreating || state.status == ArticleStatus.redaccion;

    _titleController.readOnly =
        !isEditingEnabled; // Actualizar el modo de solo lectura
    _abstractController.readOnly =
        !isEditingEnabled; // Actualizar el modo de solo lectura

    // double parIconSize = 10.0;
    double parIconButtonFactor = 1.0;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CoverImagePicker(
              key: ValueKey(
                  'cover_picker_$isEditingEnabled'), // Añadir una clave única
              isEnabled: isEditingEnabled, // Pasamos el estado de habilitación
              currentCoverUrl: state.article.coverUrl,
              newImageBytes: state.newCoverImageBytes,
              onImageSelected: (bytes) {
                context.read<ArticleEditBloc>().add(UpdateCoverImage(bytes));
              },
              onImageCleared: () =>
                  context // Al borrar, enviamos el marcador especial
                      .read<ArticleEditBloc>()
                      .add(const UpdateCoverImage(null)),
            ),
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
            CategorySelectorSection(
              isEnabled: isEditingEnabled,
              categoryId: state.article.categoryId,
              subcategoryId: state.article.subcategoryId,
              categories: state.categories,
              subcategories: state.subcategories,
              l10n: l10n,
            ),
            const SizedBox(height: 24),
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
            DatePickerSection(
              isEnabled: isEditingEnabled,
              publishDate: state.article.publishDate,
              effectiveDate: state.article.effectiveDate,
              expirationDate: state.article.expirationDate,
              l10n: l10n,
            ),
            const SizedBox(height: 32),
            Text('--- ${l10n.sections.toUpperCase()} ---',
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            SectionList(isEditingEnabled: isEditingEnabled),
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
}
