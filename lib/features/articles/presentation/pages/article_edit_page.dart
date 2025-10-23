import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:conectasoc/core/services/image_picker_service.dart';
import 'package:conectasoc/features/articles/domain/entities/entities.dart';
import 'package:conectasoc/features/articles/presentation/bloc/bloc.dart';
import 'package:conectasoc/features/auth/presentation/bloc/bloc.dart';
import 'package:conectasoc/injection_container.dart';
import 'package:conectasoc/l10n/app_localizations.dart';
import 'package:conectasoc/services/snackbar_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ArticleEditPage extends StatelessWidget {
  final String? articleId;

  const ArticleEditPage({super.key, this.articleId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ArticleEditBloc>(
        param1: context.read<AuthBloc>(),
      )..add(articleId == null
          ? PrepareArticleCreation()
          : LoadArticleForEdit(articleId!)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(articleId == null
              ? AppLocalizations.of(context)!.createArticle
              : AppLocalizations.of(context)!.editArticle),
          actions: [
            BlocBuilder<ArticleEditBloc, ArticleEditState>(
              builder: (context, state) {
                if (state is ArticleEditLoaded) {
                  return IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: () async {
                      context.read<ArticleEditBloc>().add(const SaveArticle());
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: const ArticleEditView(),
      ),
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

  @override
  void initState() {
    super.initState();
    _titleController = quill.QuillController.basic();
    _abstractController = quill.QuillController.basic();

    _titleFocusNode = FocusNode();
    _abstractFocusNode = FocusNode();
    _abstractScrollController = ScrollController();

    _titleController.addListener(_onTitleChanged);
    _abstractController.addListener(_onAbstractChanged);
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTitleChanged);
    _abstractController.removeListener(_onAbstractChanged);
    _titleController.dispose();
    _abstractController.dispose();
    _titleFocusNode.dispose();
    _abstractFocusNode.dispose();
    _abstractScrollController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
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

  void _syncQuillControllers(ArticleEntity article) {
    // Prevenir la sincronización si el artículo no ha cambiado o si es el mismo que el último sincronizado
    if (_lastSyncedArticle == article) {
      return;
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
    _lastSyncedArticle = article; // Almacenar el último artículo sincronizado
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<ArticleEditBloc, ArticleEditState>(
      listener: (context, state) {
        if (state is ArticleEditSuccess) {
          SnackBarService.showSnackBar(
              l10n.articleCreatedSuccess); // Or articleUpdatedSuccess
          context.pop(); // Volver a la pantalla anterior
        } else if (state is ArticleEditLoaded && state.errorMessage != null) {
          SnackBarService.showSnackBar(state.errorMessage!() ?? '',
              isError: true);
        } else if (state is ArticleEditFailure) {
          SnackBarService.showSnackBar(state.message, isError: true);
        }
      },
      child: BlocBuilder<ArticleEditBloc, ArticleEditState>(
        // Usamos BlocBuilder para la UI
        builder: (context, state) {
          if (state is ArticleEditLoading || state is ArticleEditInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ArticleEditLoaded) {
            _syncQuillControllers(state.article);
            return _buildForm(context, state, l10n);
          }
          if (state is ArticleEditFailure) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildForm(
      BuildContext context, ArticleEditLoaded state, AppLocalizations l10n) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CoverImagePicker(
              currentCoverUrl: state.article.coverUrl,
              newImageFile: state.newCoverImageFile,
              onImageSelected: (file) {
                context.read<ArticleEditBloc>().add(UpdateCoverImage(file));
              },
              onImageCleared: () => context
                  .read<ArticleEditBloc>()
                  .add(const UpdateCoverImage(null)),
            ),
            const SizedBox(height: 24),
            Text(l10n.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            quill.QuillSimpleToolbar(
              controller: _titleController,
              // Puedes añadir otras opciones en el parámetro de 'config'
              config: quill.QuillSimpleToolbarConfig(
                  // opciones adicionales aquí si hicieran falta
                  ),
            ),
            Container(
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: quill.QuillEditor(
                controller: _titleController,
                focusNode: _titleFocusNode,
                scrollController: _titleScrollController,
                config: const quill.QuillEditorConfig(
                  padding: EdgeInsets.all(8),
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
            const SizedBox(height: 24),
            _buildCategorySelectors(context, state, l10n),
            const SizedBox(height: 24),
            _buildStatusDropdown(context, state, l10n),
            const SizedBox(height: 24),
            _buildDatePickers(context, state, l10n),
            const SizedBox(height: 32),
            Text('--- ${l10n.sections.toUpperCase()} ---',
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            _SectionList(state: state),
            const SizedBox(height: 16),
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

  Widget _buildCategorySelectors(
      BuildContext context, ArticleEditLoaded state, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: state.article.categoryId.isEmpty
                ? null
                : state.article.categoryId,
            decoration: InputDecoration(labelText: l10n.category),
            items: state.categories.map((category) {
              return DropdownMenuItem(
                value: category.id,
                child: Text(category.name),
              );
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
            initialValue: state.article.subcategoryId.isEmpty
                ? null
                : state.article.subcategoryId,
            decoration: InputDecoration(labelText: l10n.subcategory),
            items: state.subcategories.map((subcategory) {
              return DropdownMenuItem(
                value: subcategory.id,
                child: Text(subcategory.name),
              );
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

  Widget _buildStatusDropdown(
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

  Widget _buildDatePickers(
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
  final String currentCoverUrl;
  final File? newImageFile;
  final Function(File) onImageSelected;
  final VoidCallback onImageCleared;

  const _CoverImagePicker({
    required this.currentCoverUrl,
    this.newImageFile,
    required this.onImageSelected,
    required this.onImageCleared,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final imagePickerService = ImagePickerService();

    ImageProvider? imageProvider;
    if (newImageFile != null) {
      // Prioritize newly selected image
      imageProvider = FileImage(newImageFile!);
    } else if (currentCoverUrl.isNotEmpty) {
      imageProvider = CachedNetworkImageProvider(currentCoverUrl);
    }

    return GestureDetector(
      onTap: () async {
        final path = await imagePickerService.pickImage(context);
        if (path != null) {
          onImageSelected(File(path));
        }
      },
      child: AspectRatio(
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
              if (imageProvider != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white),
                      onPressed: onImageCleared),
                ),
              (imageProvider == null)
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
                  : const SizedBox.shrink(),
            ],
          ),
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
  Widget build(BuildContext anContext) {
    final controller = TextEditingController(
      text: selectedDate != null
          ? DateFormat.yMd(AppLocalizations.of(anContext)!.localeName)
              .format(selectedDate!)
          : '',
    );
    final l10n = AppLocalizations.of(anContext)!;

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
        final pickedDate = await showDatePicker(
          context: anContext,
          initialDate: selectedDate ?? now,
          firstDate: now,
          lastDate: DateTime(now.year + 5),
        );
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

  const _SectionList({required this.state});

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

  const _ArticleSectionEditor({
    super.key,
    required this.section,
    required this.index,
    required this.onRemove,
  });

  @override
  State<_ArticleSectionEditor> createState() => _ArticleSectionEditorState();
}

class _ArticleSectionEditorState extends State<_ArticleSectionEditor> {
  late quill.QuillController _quillController;
  late FocusNode _focusNode;
  Timer? _debounceTimer;
  final ImagePickerService _imagePickerService = ImagePickerService();

  @override
  void initState() {
    super.initState();
    _quillController = quill.QuillController.basic();
    _focusNode = FocusNode();
    _loadContent();
    _quillController.addListener(_onContentChanged);
  }

  @override
  void didUpdateWidget(covariant _ArticleSectionEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.section.richTextContent != widget.section.richTextContent) {
      _loadContent();
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
    final path = await _imagePickerService.pickImage(context);
    if (path != null) {
      context
          .read<ArticleEditBloc>()
          .add(UpdateSectionImage(widget.section.id, File(path)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                  children: [
                    IconButton(
                        onPressed: _pickImage, icon: const Icon(Icons.image)),
                    IconButton(
                        onPressed: widget.onRemove,
                        icon: const Icon(Icons.delete, color: Colors.red)),
                    ReorderableDragStartListener(
                      index: widget.index,
                      child: const Icon(Icons.drag_handle),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (widget.section.imageUrl != null &&
                widget.section.imageUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: CachedNetworkImage(
                    imageUrl: widget.section.imageUrl!,
                    height: 150,
                    fit: BoxFit.cover),
              ),
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
                  scrollController: ScrollController(),
                  config: const quill.QuillEditorConfig(
                      padding: EdgeInsets.all(8))),
            ),
          ],
        ),
      ),
    );
  }
}
