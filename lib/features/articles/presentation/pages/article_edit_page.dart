import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:conectasoc/core/services/image_picker_service.dart';
import 'package:conectasoc/features/articles/domain/entities/entities.dart';
import 'package:conectasoc/features/articles/presentation/bloc/bloc.dart';
import 'package:conectasoc/features/auth/presentation/bloc/bloc.dart';
import 'package:conectasoc/injection_container.dart';
import 'package:conectasoc/l10n/app_localizations.dart';
import 'package:conectasoc/services/snackbar_service.dart';

class ArticleEditPage extends StatelessWidget {
  final String? articleId;

  const ArticleEditPage({super.key, this.articleId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ArticleEditBloc>(
        param1: context.read<AuthBloc>(),
      )..add(articleId == null
          ? PrepareArticleCreation() // Si no hay ID, preparamos para crear
          : LoadArticleForEdit(articleId!)), // Si hay ID, cargamos para editar
      child: const ArticleEditView(),
    );
  }
}

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
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<ArticleEditBloc, ArticleEditState>(
      builder: (context, state) {
        // Determine the title based on the state.
        final bool isCreating = state is! ArticleEditLoaded ||
            state.article.id.isEmpty ||
            state.isCreating;
        final String title = isCreating ? l10n.createArticle : l10n.editArticle;

        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            actions: [
              IconButton(
                icon: Icon(_isPreviewMode ? Icons.edit : Icons.visibility),
                tooltip:
                    _isPreviewMode ? l10n.edit : l10n.previewMode, // Localized
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
          ? buildPreview(context, state, l10n)
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

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CoverImagePicker(
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
            const SizedBox(height: 24),
            Text(l10n.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            quill.QuillSimpleToolbar(
              controller: _titleController,
              config: const quill.QuillSimpleToolbarConfig(
                // Botones de alineación
                showAlignmentButtons: true,
                // showLeftAlignment: true,
                // showCenterAlignment: true,
                // showRightAlignment: true,
                // showJustifyAlignment: true,

                // Otros botones útiles (opcional)
                showBoldButton: true,
                showItalicButton: true,
                showUnderLineButton: true,
                showStrikeThrough: true,
                showColorButton: true,
                showBackgroundColorButton: true,
                showListBullets: true,
                showListNumbers: true,
                showListCheck: true,
                showCodeBlock: false,
                showQuote: true,
                showIndent: true,
                showLink: true,
                showUndo: true,
                showRedo: true,
                showFontSize: true,
                showFontFamily: true,
                showSearchButton:
                    false, // Generalmente no es necesario en editores pequeños
              ),
            ),
            Container(
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: quill.QuillEditor.basic(
                controller: _titleController,
                focusNode: _titleFocusNode,
                scrollController: _titleScrollController,
                config: const quill.QuillEditorConfig(
                  padding: EdgeInsets.all(8),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$_titleCharCount / 100',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _titleCharCount > 100 ? Colors.red : Colors.grey,
                    ),
              ),
            ),
            const SizedBox(height: 16),
            Text(l10n.abstractContent,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            quill.QuillSimpleToolbar(
              controller: _abstractController,
              // Puedes añadir otras opciones en el parámetro de 'config'
              config: quill.QuillSimpleToolbarConfig(
                  // opciones adicionales aquí si hicieran falta
                  ),
            ),
            Container(
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: quill.QuillEditor(
                controller: _abstractController,
                focusNode: _abstractFocusNode,
                scrollController: _abstractScrollController,
                config: const quill.QuillEditorConfig(
                  padding: EdgeInsets.all(8),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$_abstractCharCount / 200',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color:
                          _abstractCharCount > 200 ? Colors.red : Colors.grey,
                    ),
              ),
            ),
            const SizedBox(height: 24),
            IgnorePointer(
              ignoring: !isEditingEnabled,
              child: buildCategorySelectors(context, state, l10n),
            ),
            const SizedBox(height: 24),
            buildStatusDropdown(context, state, l10n),
            const SizedBox(height: 24),
            IgnorePointer(
              ignoring: !isEditingEnabled,
              child: buildDatePickers(context, state, l10n),
            ),
            const SizedBox(height: 32),
            Text('--- ${l10n.sections.toUpperCase()} ---',
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            _SectionList(state: state, isEditingEnabled: isEditingEnabled),
            const SizedBox(height: 16),
            if (isEditingEnabled)
              ElevatedButton.icon(
                onPressed: () =>
                    context.read<ArticleEditBloc>().add(const AddSection()),
                icon: const Icon(Icons.add),
                label: Text(l10n.addSection),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildPreview(
      BuildContext context, ArticleEditLoaded state, AppLocalizations l10n) {
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
                  controller: _titleController,
                  focusNode: _titleFocusNode,
                  scrollController: _titleScrollController,
                  config: quill.QuillEditorConfig(
                    padding: const EdgeInsets.only(bottom: 8),
                  ),
                ),
                // Abstract
                quill.QuillEditor(
                  controller: _abstractController,
                  focusNode: _abstractFocusNode,
                  scrollController: _abstractScrollController,
                  config: quill.QuillEditorConfig(
                    padding: const EdgeInsets.only(bottom: 16),
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
                ...article.sections.map(
                    (section) => buildPreviewSection(context, state, section)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPreviewSection(
      BuildContext context, ArticleEditLoaded state, ArticleSection section) {
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

    final imageBytes = state.newSectionImageBytes[section.id];
    final imageUrl = section.imageUrl;
    final isNetworkImage = imageUrl != null &&
        (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'));

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageBytes != null || isNetworkImage)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageBytes != null
                    ? Image.memory(
                        imageBytes,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 150,
                      )
                    : CachedNetworkImage(
                        imageUrl: imageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 150,
                        placeholder: (context, url) => const SizedBox(
                          height: 150,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
              ),
            ),
          if (contentController != null)
            quill.QuillEditor(
              controller: contentController,
              focusNode: contentFocusNode,
              scrollController: contentScrollController,
              config: quill.QuillEditorConfig(
                padding: EdgeInsets.zero,
              ),
            ),
        ],
      ),
    );
  }

  Widget buildCategorySelectors(
      BuildContext context, ArticleEditLoaded state, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            key: Key('category_${state.article.categoryId}'),
            initialValue: state.article.categoryId.isEmpty
                ? null
                : state.article.categoryId,
            decoration: InputDecoration(labelText: l10n.category),
            // Use toSet() to remove duplicates before mapping
            items: state.categories.toSet().map((category) {
              return DropdownMenuItem<String>(
                  value: category.id,
                  child: Text(
                    category.name,
                    overflow: TextOverflow.ellipsis,
                  ));
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                context.read<ArticleEditBloc>().add(CategoryChanged(value));
              }
            },
            validator: (value) =>
                value == null || value.isEmpty ? l10n.requiredField : null,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<String>(
            key: Key('subcategory_${state.article.subcategoryId}'),
            initialValue: state.article.subcategoryId.isEmpty
                ? null
                : state.article.subcategoryId,
            decoration: InputDecoration(labelText: l10n.subcategory),
            // Use toSet() to remove duplicates before mapping
            items: state.subcategories.toSet().map((subcategory) {
              return DropdownMenuItem<String>(
                  value: subcategory.id,
                  child: Text(
                    subcategory.name,
                    overflow: TextOverflow.ellipsis,
                  ));
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                context.read<ArticleEditBloc>().add(SubcategoryChanged(value));
              }
            },
            validator: (value) =>
                value == null || value.isEmpty ? l10n.requiredField : null,
          ),
        ),
      ],
    );
  }

  Widget buildStatusDropdown(
      BuildContext context, ArticleEditLoaded state, AppLocalizations l10n) {
    return DropdownButtonFormField<ArticleStatus>(
      initialValue: state.status,
      decoration: InputDecoration(labelText: l10n.articleStatus),
      items: ArticleStatus.values.map((status) {
        String statusText;
        switch (status) {
          case ArticleStatus.redaccion:
            statusText = l10n.statusRedaccion;
            break;
          case ArticleStatus.publicado:
            statusText = l10n.statusPublicado;
            break;
          case ArticleStatus.revision:
            statusText = l10n.statusRevision;
            break;
          case ArticleStatus.expirado:
            statusText = l10n.statusExpirado;
            break;
          case ArticleStatus.anulado:
            statusText = l10n.statusAnulado;
            break;
        }
        return DropdownMenuItem(
          value: status,
          // Deshabilitar opciones si el artículo no es válido y el estado no es 'redaccion'
          enabled: state.isArticleValid ||
              status == ArticleStatus.redaccion ||
              status == ArticleStatus.anulado,
          child: Text(statusText),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          context.read<ArticleEditBloc>().add(SetArticleStatus(value));
        }
      },
    );
  }

  Widget buildDatePickers(
      BuildContext context, ArticleEditLoaded state, AppLocalizations l10n) {
    return Column(
      children: [
        _DatePickerField(
          label: l10n.publishDateLabel,
          selectedDate: state.article.publishDate,
          onDateSelected: (date) {
            context.read<ArticleEditBloc>().add(PublishDateChanged(date));
          },
        ),
        const SizedBox(height: 16),
        _DatePickerField(
          label: l10n.effectiveDateLabel,
          selectedDate: state.article.effectiveDate,
          onDateSelected: (date) {
            context.read<ArticleEditBloc>().add(EffectiveDateChanged(date));
          },
        ),
        const SizedBox(height: 16),
        _DatePickerField(
          label: l10n.expirationDateLabel,
          selectedDate: state.article.expirationDate,
          onDateSelected: (date) {
            context.read<ArticleEditBloc>().add(ExpirationDateChanged(date));
          },
          onClearDate: () {
            context
                .read<ArticleEditBloc>()
                .add(const ExpirationDateChanged(null));
          },
          isOptional: true,
        ),
      ],
    );
  }
}

class _CoverImagePicker extends StatelessWidget {
  final bool isEnabled;
  final String currentCoverUrl;
  final Uint8List? newImageBytes;
  final Function(Uint8List) onImageSelected;
  final VoidCallback onImageCleared;

  const _CoverImagePicker({
    super.key,
    required this.isEnabled,
    required this.currentCoverUrl,
    this.newImageBytes,
    required this.onImageSelected,
    required this.onImageCleared,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final imagePickerService = ImagePickerService();

    ImageProvider? imageProvider;
    if (newImageBytes != null) {
      imageProvider = MemoryImage(newImageBytes!);
    } else if (currentCoverUrl.isNotEmpty) {
      imageProvider = CachedNetworkImageProvider(currentCoverUrl);
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          image: imageProvider != null
              ? DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: Stack(
          children: [
            // GestureDetector para seleccionar imagen (cubre todo el contenedor)
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: isEnabled
                      ? () async {
                          final bytes =
                              await imagePickerService.pickImage(context);
                          if (!context.mounted) return;
                          if (bytes != null) {
                            onImageSelected(bytes);
                          }
                        }
                      : null,
                  child: imageProvider == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt,
                                  size: 40, color: Colors.grey[600]),
                              const SizedBox(height: 8),
                              Text(
                                l10n.selectCoverImage,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        )
                      : null,
                ),
              ),
            ),
            // Botón de eliminar (solo visible si hay imagen)
            if (imageProvider != null && isEnabled)
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.black54,
                  shape: const CircleBorder(),
                  child: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white),
                    onPressed: onImageCleared,
                    tooltip:
                        "Eliminar imagen", // Añade tooltip si tienes la traducción
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;
  final Function()? onClearDate;
  final bool isOptional;

  const _DatePickerField({
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
    this.onClearDate,
    this.isOptional = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(
      text: selectedDate != null
          ? DateFormat.yMd(AppLocalizations.of(context)!.localeName)
              .format(selectedDate!)
          : '',
    );
    final l10n = AppLocalizations.of(context)!;

    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isOptional && selectedDate != null)
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  onClearDate?.call();
                },
              ),
            const Icon(Icons.calendar_today),
            const SizedBox(width: 12),
          ],
        ),
      ),
      onTap: () async {
        final now = DateTime.now();
        // The context is captured before the async call.
        if (!context.mounted) return;

        final pickedDate = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? now,
          firstDate: DateTime(now.year - 5),
          lastDate: DateTime(now.year + 5),
        );
        // After the async gap, we don't use the context, so this is safe.
        // A mounted check is good practice if we were to use context here.

        if (pickedDate != null) {
          onDateSelected(pickedDate);
        }
      },
      validator: (value) {
        if (!isOptional && (value == null || value.isEmpty)) {
          return l10n.requiredField;
        }
        return null;
      },
    );
  }
}

class _SectionList extends StatelessWidget {
  final ArticleEditLoaded state;
  final bool isEditingEnabled;

  const _SectionList({required this.state, required this.isEditingEnabled});

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      physics:
          const NeverScrollableScrollPhysics(), // Disable internal scrolling
      shrinkWrap: true,
      itemCount: state.article.sections.length,
      itemBuilder: (context, index) {
        final section = state.article.sections[index];
        return _ArticleSectionEditor(
          key: ValueKey(section.id), // Use ValueKey for ReorderableListView
          section: section,
          index: index,
          isEditingEnabled: isEditingEnabled,
          onRemove: () =>
              context.read<ArticleEditBloc>().add(RemoveSection(section.id)),
        );
      },
      onReorder: (oldIndex, newIndex) {
        // Adjust newIndex when moving items downwards
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }
        context
            .read<ArticleEditBloc>()
            .add(ReorderSectionsEvent(oldIndex, newIndex));
      },
    );
  }
}

class _ArticleSectionEditor extends StatefulWidget {
  final ArticleSection section;
  final int index;
  final VoidCallback onRemove;
  final bool isEditingEnabled;

  const _ArticleSectionEditor({
    super.key,
    required this.section,
    required this.index,
    required this.onRemove,
    required this.isEditingEnabled,
  });

  @override
  State<_ArticleSectionEditor> createState() => _ArticleSectionEditorState();
}

class _ArticleSectionEditorState extends State<_ArticleSectionEditor> {
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

    // Aplicar el estado de solo lectura inicial
    _quillController.readOnly = !widget.isEditingEnabled;

    _quillController.addListener(_onContentChanged);
  }

  @override
  void didUpdateWidget(covariant _ArticleSectionEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.section.richTextContent != widget.section.richTextContent) {
      _loadContent();
    }
    // Actualizar el estado de solo lectura si cambia
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
    // After an async gap, check if the widget is still in the tree
    if (!mounted) return;

    if (bytes != null) {
      if (!mounted) return;
      context.read<ArticleEditBloc>().add(
            UpdateSectionImage(widget.section.id, bytes),
          );
    }
  }

  Future<void> _confirmRemoveSection() async {
    final l10n = AppLocalizations.of(context)!;
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
    final l10n = AppLocalizations.of(context)!;
    final state = context.watch<ArticleEditBloc>().state as ArticleEditLoaded;
    final imageBytes = state.newSectionImageBytes[widget.section.id];
    final imageUrl = widget.section.imageUrl;
    final hasImage =
        imageBytes != null || (imageUrl != null && imageUrl.isNotEmpty);

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
                          if (hasImage)
                            IconButton(
                              icon: const Icon(Icons.image_not_supported,
                                  color: Colors.orange),
                              onPressed: () => context
                                  .read<ArticleEditBloc>()
                                  .add(UpdateSectionImage(
                                      widget.section.id, null)),
                              tooltip: 'Eliminar imagen',
                            ),
                          IconButton(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.image)),
                          IconButton(
                              onPressed: _confirmRemoveSection,
                              icon:
                                  const Icon(Icons.delete, color: Colors.red)),
                          ReorderableDragStartListener(
                            index: widget.index,
                            child: const Icon(Icons.drag_handle),
                          ),
                        ]
                      : [
                          // No mostrar botones si la edición está deshabilitada
                        ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            BlocBuilder<ArticleEditBloc, ArticleEditState>(
              builder: (context, state) {
                if (state is ArticleEditLoaded) {
                  return buildSectionImage(context, state, widget.section);
                }
                return const SizedBox.shrink();
              },
            ),
            if (widget.isEditingEnabled)
              quill.QuillSimpleToolbar(controller: _quillController),
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
  }

  Widget buildSectionImage(
      BuildContext context, ArticleEditLoaded state, ArticleSection section) {
    final imageBytes = state.newSectionImageBytes[section.id];
    final imageUrl = section.imageUrl;
    final isNetworkImage = imageUrl != null &&
        (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'));

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: imageBytes != null
            ? Image.memory(
                imageBytes,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              )
            : isNetworkImage
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  )
                : const SizedBox.shrink(),
      ),
    );
  }
}
