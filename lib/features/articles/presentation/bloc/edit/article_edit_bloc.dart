import 'dart:convert';
import 'dart:typed_data';
import 'package:conectasoc/features/articles/data/models/models.dart';
import 'package:conectasoc/features/articles/domain/entities/entities.dart';
import 'package:conectasoc/features/articles/presentation/bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:conectasoc/features/articles/domain/usecases/usecases.dart';
import 'package:conectasoc/features/auth/presentation/bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ArticleEditBloc extends Bloc<ArticleEditEvent, ArticleEditState> {
  final CreateArticleUseCase _createArticleUseCase;
  final UpdateArticleUseCase _updateArticleUseCase;
  final GetArticleByIdUseCase _getArticleByIdUseCase;
  final DeleteArticleUseCase _deleteArticleUseCase;
  final GetCategoriesUseCase _getCategoriesUseCase;
  final GetSubcategoriesUseCase _getSubcategoriesUseCase;
  final SharedPreferences _sharedPreferences;
  final AuthBloc _authBloc;

  ArticleEditBloc({
    required CreateArticleUseCase createArticleUseCase,
    required UpdateArticleUseCase updateArticleUseCase,
    required GetArticleByIdUseCase getArticleByIdUseCase,
    required DeleteArticleUseCase deleteArticleUseCase,
    required GetCategoriesUseCase getCategoriesUseCase,
    required GetSubcategoriesUseCase getSubcategoriesUseCase,
    required SharedPreferences sharedPreferences,
    required AuthBloc authBloc,
  })  : _createArticleUseCase = createArticleUseCase,
        _updateArticleUseCase = updateArticleUseCase,
        _getArticleByIdUseCase = getArticleByIdUseCase,
        _deleteArticleUseCase = deleteArticleUseCase,
        _getCategoriesUseCase = getCategoriesUseCase,
        _getSubcategoriesUseCase = getSubcategoriesUseCase,
        _sharedPreferences = sharedPreferences,
        _authBloc = authBloc,
        super(ArticleEditInitial()) {
    on<LoadArticleForEdit>(_onLoadArticleForEdit);
    on<PrepareArticleCreation>(_onPrepareArticleCreation);
    on<SaveArticle>(_onSaveArticle);
    on<DeleteArticle>(_onDeleteArticle);
    on<ArticleFieldChanged>(_onArticleFieldChanged);
    on<CategoryChanged>(_onCategoryChanged);
    on<SubcategoryChanged>(_onSubcategoryChanged);
    on<SetArticleStatus>(_onSetArticleStatus);
    on<PublishDateChanged>(_onPublishDateChanged);
    on<EffectiveDateChanged>(_onEffectiveDateChanged);
    on<ExpirationDateChanged>(_onExpirationDateChanged);
    on<UpdateCoverImage>(_onUpdateCoverImage);
    on<AddSection>(_onAddSection);
    on<RemoveSection>(_onRemoveSection);
    on<ReorderSectionsEvent>(_onReorderSections);
    on<UpdateSectionContent>(_onUpdateSectionContent);
    on<UpdateSectionImage>(_onUpdateSectionImage);
    on<AutoSaveDraft>(_onAutoSaveDraft);
    on<RestoreDraft>(_onRestoreDraft);
    on<TogglePreviewMode>(_onTogglePreviewMode);
    on<DiscardDraft>(_onDiscardDraft);
  }

  Future<void> _onPrepareArticleCreation(
    PrepareArticleCreation event,
    Emitter<ArticleEditState> emit,
  ) async {
    emit(ArticleEditLoading());

    // Limpiar cualquier borrador antiguo de "nuevo artículo" al empezar.
    await _sharedPreferences.remove(_getDraftKey(null));

    final authState = _authBloc.state;
    if (authState is! AuthAuthenticated) {
      emit(const ArticleEditFailure('Usuario no autenticado.'));
      return;
    }

    final user = authState.user;
    final currentMembership = authState.currentMembership;

    if (currentMembership == null) {
      emit(const ArticleEditFailure('No se ha seleccionado una asociación.'));
      return;
    }

    try {
      final categoriesResult = await _getCategoriesUseCase();
      ArticleEntity? newArticle;

      categoriesResult.fold(
        (failure) => emit(ArticleEditFailure(failure.message)),
        (categories) {
          newArticle = ArticleEntity.empty().copyWith(
            userId: user.uid,
            authorName: user.fullName,
            authorAvatarUrl: user.avatarUrl,
            assocId: currentMembership
                .associationId, // Use current membership's assocId
            associationShortName: currentMembership.associationId,
            status: ArticleStatus.redaccion,
            sections: const [], // Empezar sin secciones
          );

          final titleCharCount =
              _quillJsonToPlainText(newArticle!.title).length;
          final abstractCharCount =
              _quillJsonToPlainText(newArticle!.abstractContent).length;

          emit(ArticleEditLoaded(
            article: newArticle!,
            categories: categories,
            subcategories: const [],
            isCreating: true,
            titleCharCount: titleCharCount,
            abstractCharCount: abstractCharCount,
          ));
        },
      );

      if (newArticle == null) {
        return; // Exit if article creation failed inside the fold.
      }

      // After setting the initial state, check for a draft.
      final draftJson = _sharedPreferences.getString('draft_new_article');
      if (draftJson != null) {
        final draftArticle = ArticleModel.fromEntity(
            ArticleEntity.fromJson(jsonDecode(draftJson)));
        emit(ArticleEditDraftFound(
            originalArticle: newArticle!, draftArticle: draftArticle));
      }
    } catch (e) {
      emit(ArticleEditFailure(
          'Error inesperado al preparar la creación: ${e.toString()}'));
    }
  }

  String _getDraftKey(String? articleId) {
    return articleId == null || articleId.isEmpty
        ? 'draft_new_article'
        : 'draft_$articleId';
  }

  Future<void> _onLoadArticleForEdit(
    LoadArticleForEdit event,
    Emitter<ArticleEditState> emit,
  ) async {
    emit(ArticleEditLoading());
    try {
      // Cargar el artículo, las categorías y las subcategorías en paralelo
      final results = await Future.wait([
        _getArticleByIdUseCase(event.articleId),
        _getCategoriesUseCase(),
      ]);

      final articleResult = results[0];
      final categoriesResult = results[1];

      final article = (articleResult as dynamic).fold((l) => throw l, (r) => r);
      final categories =
          (categoriesResult as dynamic).fold((l) => throw l, (r) => r);

      final subcategoriesResult =
          await _getSubcategoriesUseCase(article.categoryId);
      final subcategories = subcategoriesResult.fold((l) => throw l, (r) => r);

      final titleCharCount = _quillJsonToPlainText(article.title).length;
      final abstractCharCount =
          _quillJsonToPlainText(article.abstractContent).length;

      final initialState = ArticleEditLoaded(
          article: article,
          status: article.status, // Initialize status in state
          categories: categories,
          subcategories: subcategories,
          titleCharCount: titleCharCount,
          abstractCharCount: abstractCharCount);
      emit(initialState);

      // After loading, check for a local draft.
      final draftKey = _getDraftKey(event.articleId);
      final draftJson = _sharedPreferences.getString(draftKey);
      if (draftJson != null) {
        final draftArticle = ArticleModel.fromEntity(
            ArticleEntity.fromJson(jsonDecode(draftJson)));
        emit(ArticleEditDraftFound(
            originalArticle: article, draftArticle: draftArticle));
      }
    } catch (e) {
      emit(ArticleEditFailure(
          'Error al cargar el artículo para editar: ${e.toString()}'));
    }
  }

  Future<void> _onSaveArticle(
    SaveArticle event,
    Emitter<ArticleEditState> emit,
  ) async {
    if (state is! ArticleEditLoaded) return;

    final currentState = state as ArticleEditLoaded;
    emit(currentState.copyWith(isSaving: true));

    final titlePlainText = _quillJsonToPlainText(currentState.article.title);
    final abstractPlainText =
        _quillJsonToPlainText(currentState.article.abstractContent);

    final l10n = event.l10n;

    if (currentState.isCreating && currentState.newCoverImageBytes == null) {
      emit(currentState.copyWith(
          isSaving: false, errorMessage: () => l10n.coverRequired));
      return;
    }

    if (titlePlainText.isEmpty) {
      emit(currentState.copyWith(
          isSaving: false, errorMessage: () => l10n.titleRequired));
      return;
    }

    if (titlePlainText.length > 100) {
      emit(currentState.copyWith(
        isSaving: false,
        errorMessage: () => l10n.titleCharLimitExceeded,
      ));
      return;
    }

    if (abstractPlainText.isEmpty) {
      emit(currentState.copyWith(
          isSaving: false, errorMessage: () => l10n.abstractRequired));
      return;
    }

    if (abstractPlainText.length > 200) {
      emit(currentState.copyWith(
        isSaving: false,
        errorMessage: () => l10n.abstractCharLimitExceeded,
      ));
      return;
    }

    if (currentState.article.categoryId.isEmpty) {
      emit(currentState.copyWith(
          isSaving: false, errorMessage: () => l10n.categoryRequired));
      return;
    }

    if (currentState.article.subcategoryId.isEmpty) {
      emit(currentState.copyWith(
          isSaving: false, errorMessage: () => l10n.subcategoryRequired));
      return;
    }

    // Si hay secciones, ninguna puede estar completamente vacía.
    if (currentState.article.sections.any((s) =>
        (_quillJsonToPlainText(s.richTextContent ?? '').isEmpty) &&
        (s.imageUrl == null || s.imageUrl!.isEmpty))) {
      emit(currentState.copyWith(
          isSaving: false, errorMessage: () => l10n.sectionContentRequired));
      return;
    }

    final articleToSave = currentState.article.copyWith(
      modifiedAt: DateTime.now(),
      status: currentState.status, // Use status from state
    );

    if (currentState.isCreating) {
      final result = await _createArticleUseCase(articleToSave,
          currentState.newCoverImageBytes!, currentState.newSectionImageBytes);
      result.fold(
        (failure) => emit(currentState.copyWith(
            isSaving: false, errorMessage: () => failure.message)),
        (_) {
          // On success, clear the draft
          _sharedPreferences.remove(_getDraftKey(null));
          emit(ArticleEditSuccess());
        },
      );
    } else {
      final result = await _updateArticleUseCase(articleToSave,
          newCoverImageBytes: currentState.newCoverImageBytes);
      result.fold(
        (failure) => emit(currentState.copyWith(
            isSaving: false, errorMessage: () => failure.message)),
        (_) {
          // On success, clear the draft
          _sharedPreferences.remove(_getDraftKey(articleToSave.id));
          emit(ArticleEditSuccess());
        },
      );
    }
  }

  Future<void> _onDeleteArticle(
    DeleteArticle event,
    Emitter<ArticleEditState> emit,
  ) async {
    if (state is! ArticleEditLoaded) return;
    final currentState = state as ArticleEditLoaded;

    emit(
        currentState.copyWith(isSaving: true)); // Indicate deletion in progress
    final result = await _deleteArticleUseCase(
      event.articleId,
      coverUrl: currentState.article.coverUrl,
      sectionImages: currentState.article.sections
          .where((s) => s.imageUrl != null)
          .map((s) => s.imageUrl!)
          .toList(),
    );
    result.fold((failure) => emit(ArticleEditFailure(failure.message)), (_) {
      // On success, clear the draft
      _sharedPreferences.remove(_getDraftKey(event.articleId));
      emit(ArticleEditSuccess());
    });
  }

  void _onArticleFieldChanged(
    ArticleFieldChanged event,
    Emitter<ArticleEditState> emit,
  ) {
    if (state is ArticleEditLoaded) {
      final currentState = state as ArticleEditLoaded;
      final titleCharCount = _quillJsonToPlainText(event.article.title).length;
      final abstractCharCount =
          _quillJsonToPlainText(event.article.abstractContent).length;
      emit(currentState.copyWith(
          article: event.article,
          titleCharCount: titleCharCount,
          abstractCharCount: abstractCharCount));
      add(const AutoSaveDraft());
    }
  }

  void _onSetArticleStatus(
      SetArticleStatus event, Emitter<ArticleEditState> emit) {
    if (state is ArticleEditLoaded) {
      final currentState = state as ArticleEditLoaded;
      emit(currentState.copyWith(status: event.status));
      add(const AutoSaveDraft());
    }
  }

  Future<void> _onCategoryChanged(
    CategoryChanged event,
    Emitter<ArticleEditState> emit,
  ) async {
    if (state is! ArticleEditLoaded) return;
    final currentState = state as ArticleEditLoaded;
    // Actualiza la categoría y limpia la subcategoría
    final updatedArticle = currentState.article
        .copyWith(categoryId: event.categoryId, subcategoryId: '');

    // Emite estado intermedio
    emit(currentState.copyWith(article: updatedArticle, subcategories: []));

    add(const AutoSaveDraft());

    // Carga las nuevas subcategorías
    final subcategoriesResult =
        await _getSubcategoriesUseCase(event.categoryId);

    // ⭐ Siempre usa state (no currentState) después de un await
    if (state is! ArticleEditLoaded) return;
    final latestState = state as ArticleEditLoaded;

    subcategoriesResult.fold(
      (failure) => emit(latestState.copyWith(
          errorMessage: () =>
              'Error al cargar subcategorías: ${failure.message}')),
      (subcategories) =>
          emit(latestState.copyWith(subcategories: subcategories)),
    );
  }

  void _onSubcategoryChanged(
    SubcategoryChanged event,
    Emitter<ArticleEditState> emit,
  ) {
    if (state is ArticleEditLoaded) {
      final currentState = state as ArticleEditLoaded;
      emit(currentState.copyWith(
          article: currentState.article
              .copyWith(subcategoryId: event.subcategoryId)));
      add(const AutoSaveDraft());
    }
  }

  void _onPublishDateChanged(
      PublishDateChanged event, Emitter<ArticleEditState> emit) {
    if (state is ArticleEditLoaded) {
      final currentState = state as ArticleEditLoaded;
      emit(currentState.copyWith(
          article: currentState.article.copyWith(publishDate: event.date)));
      add(const AutoSaveDraft());
    }
  }

  void _onEffectiveDateChanged(
      EffectiveDateChanged event, Emitter<ArticleEditState> emit) {
    if (state is ArticleEditLoaded) {
      final currentState = state as ArticleEditLoaded;
      emit(currentState.copyWith(
          article: currentState.article.copyWith(effectiveDate: event.date)));
      add(const AutoSaveDraft());
    }
  }

  void _onExpirationDateChanged(
      ExpirationDateChanged event, Emitter<ArticleEditState> emit) {
    if (state is ArticleEditLoaded) {
      final currentState = state as ArticleEditLoaded;
      emit(currentState.copyWith(
          article: currentState.article.copyWith(expirationDate: event.date)));
      add(const AutoSaveDraft());
    }
  }

  void _onUpdateCoverImage(
      UpdateCoverImage event, Emitter<ArticleEditState> emit) {
    if (state is ArticleEditLoaded) {
      final currentState = state as ArticleEditLoaded;
      emit(currentState.copyWith(newCoverImageBytes: event.newCoverImageBytes));
      add(const AutoSaveDraft());
    }
  }

  void _onAddSection(AddSection event, Emitter<ArticleEditState> emit) {
    if (state is ArticleEditLoaded) {
      final currentState = state as ArticleEditLoaded;
      final newSections =
          List<ArticleSection>.from(currentState.article.sections);
      newSections.add(ArticleSection(
        id: UniqueKey().toString(),
        order: newSections.length,
      ));
      emit(currentState.copyWith(
          article: currentState.article.copyWith(sections: newSections)));
      add(const AutoSaveDraft());
    }
  }

  void _onRemoveSection(RemoveSection event, Emitter<ArticleEditState> emit) {
    if (state is ArticleEditLoaded) {
      final currentState = state as ArticleEditLoaded;
      final newSections = currentState.article.sections
          .where((section) => section.id != event.sectionId)
          .toList();
      // Re-order remaining sections
      for (int i = 0; i < newSections.length; i++) {
        newSections[i] = newSections[i].copyWith(order: i);
      }
      emit(currentState.copyWith(
          article: currentState.article.copyWith(sections: newSections)));
      add(const AutoSaveDraft());
    }
  }

  void _onReorderSections(
      ReorderSectionsEvent event, Emitter<ArticleEditState> emit) {
    if (state is ArticleEditLoaded) {
      final currentState = state as ArticleEditLoaded;
      final newSections =
          List<ArticleSection>.from(currentState.article.sections);
      final ArticleSection movedSection = newSections.removeAt(event.oldIndex);
      newSections.insert(event.newIndex, movedSection);
      // Actualizar la propiedad 'order' para reflejar la nueva posición
      for (int i = 0; i < newSections.length; i++) {
        newSections[i] = newSections[i].copyWith(order: i);
      }

      emit(currentState.copyWith(
          article: currentState.article.copyWith(sections: newSections)));
      add(const AutoSaveDraft());
    }
  }

  void _onUpdateSectionContent(
      UpdateSectionContent event, Emitter<ArticleEditState> emit) {
    if (state is ArticleEditLoaded) {
      final currentState = state as ArticleEditLoaded;
      final newSections = currentState.article.sections.map((s) {
        return s.id == event.sectionId
            ? s.copyWith(richTextContent: event.richTextContent)
            : s;
      }).toList();
      emit(currentState.copyWith(
          article: currentState.article.copyWith(sections: newSections)));
      add(const AutoSaveDraft());
    }
  }

  void _onUpdateSectionImage(
      UpdateSectionImage event, Emitter<ArticleEditState> emit) {
    if (state is ArticleEditLoaded) {
      final currentState = state as ArticleEditLoaded;
      final newBytesMap =
          Map<String, Uint8List>.from(currentState.newSectionImageBytes);

      if (event.imageBytes != null) {
        newBytesMap[event.sectionId] = event.imageBytes!;
      } else {
        newBytesMap.remove(event.sectionId);
      }

      final newSections = currentState.article.sections.map((s) {
        return s.id == event.sectionId ? s.copyWith(imageUrl: '') : s;
      }).toList();
      emit(currentState.copyWith(
          article: currentState.article.copyWith(sections: newSections),
          newSectionImageBytes: newBytesMap));
      add(const AutoSaveDraft());
    }
  }

  Future<void> _onAutoSaveDraft(
    AutoSaveDraft event,
    Emitter<ArticleEditState> emit,
  ) async {
    if (state is ArticleEditLoaded) {
      final currentState = state as ArticleEditLoaded;
      final draftKey = _getDraftKey(currentState.article.id);
      final articleJson =
          jsonEncode(ArticleModel.fromEntity(currentState.article).toJson());
      await _sharedPreferences.setString(draftKey, articleJson);
    }
  }

  Future<void> _onRestoreDraft(
    RestoreDraft event,
    Emitter<ArticleEditState> emit,
  ) async {
    if (state is ArticleEditDraftFound) {
      final currentState = state as ArticleEditDraftFound;
      // To restore, we just need to emit an ArticleEditLoaded state with the draft article.
      // We need to fetch categories/subcategories again for the draft.
      final List<SubcategoryEntity> subcategories;
      final categoriesResult = await _getCategoriesUseCase();

      // Only fetch subcategories if a category is actually selected in the draft
      if (currentState.draftArticle.categoryId.isNotEmpty) {
        final subcategoriesResult = await _getSubcategoriesUseCase(
            currentState.draftArticle.categoryId);
        subcategories = subcategoriesResult.getOrElse(() => []);
      } else {
        subcategories = [];
      }

      emit(ArticleEditLoaded(
        article: currentState.draftArticle,
        status: currentState.draftArticle.status,
        categories: categoriesResult.getOrElse(() => []),
        subcategories: subcategories,
        isCreating: currentState.draftArticle.id.isEmpty,
      ));
    }
  }

  void _onDiscardDraft(DiscardDraft event, Emitter<ArticleEditState> emit) {
    if (state is ArticleEditDraftFound) {
      final draftKey = _getDraftKey(event.originalArticle.id);
      _sharedPreferences.remove(draftKey);
      // Reload the original article to discard draft changes
      add(LoadArticleForEdit(event.originalArticle.id));
    }
  }

  void _onTogglePreviewMode(
    TogglePreviewMode event,
    Emitter<ArticleEditState> emit,
  ) {
    if (state is ArticleEditLoaded) {
      final currentState = state as ArticleEditLoaded;
      emit(currentState.copyWith(isPreviewMode: !currentState.isPreviewMode));
    }
  }

  String _quillJsonToPlainText(String quillJson) {
    if (quillJson.isEmpty) return '';
    try {
      final doc = quill.Document.fromJson(jsonDecode(quillJson));
      return doc.toPlainText().trim();
    } catch (e) {
      // If JSON is malformed, it's likely not valid rich text.
      return quillJson;
    }
  }
}
