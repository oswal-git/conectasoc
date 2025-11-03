import 'dart:convert';
import 'dart:typed_data';
import 'package:conectasoc/core/utils/quill_helpers.dart';
import 'package:conectasoc/features/articles/data/models/models.dart';
import 'package:conectasoc/features/articles/domain/entities/entities.dart';
import 'package:conectasoc/features/articles/presentation/bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:conectasoc/features/articles/domain/usecases/usecases.dart';
import 'package:conectasoc/features/auth/presentation/bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Un valor especial para indicar que la imagen de portada ha sido borrada explícitamente.
Uint8List kClearImageBytes = Uint8List(0);

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
          final titleCharCount = quillJsonToPlainText(newArticle!.title).length;
          final abstractCharCount =
              quillJsonToPlainText(newArticle!.abstractContent).length;

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
      final titleCharCount = quillJsonToPlainText(article.title).length;
      final abstractCharCount =
          quillJsonToPlainText(article.abstractContent).length;

      final initialState = ArticleEditLoaded(
          article: article,
          status: article.status, // Initialize status in state
          categories: categories,
          subcategories: subcategories,
          titleCharCount: titleCharCount,
          abstractCharCount: abstractCharCount);

      // Validar el estado inicial antes de emitirlo
      final isValid = _isArticleValid(initialState.article, null, false);
      emit(initialState.copyWith(isArticleValid: isValid));

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

  bool _isArticleValid(
      ArticleEntity article, Uint8List? newCoverImageBytes, bool isCreating) {
    final now = DateUtils.dateOnly(DateTime.now());
    final publishDate = DateUtils.dateOnly(article.publishDate);
    final effectiveDate = DateUtils.dateOnly(article.effectiveDate);
    final expirationDate = article.expirationDate != null
        ? DateUtils.dateOnly(article.expirationDate!)
        : null;

    final isExpirationDateValid =
        expirationDate == null || !expirationDate.isBefore(effectiveDate);

    // La portada es válida si:
    // 1. Se está creando y se ha seleccionado una imagen (que no sea el marcador de borrado).
    // 2. Se está editando y:
    //    a) Hay una nueva imagen seleccionada (que no sea el marcador de borrado).
    //    b) O no se ha tocado la imagen (newCoverImageBytes es null) y ya existía una URL de portada.
    final isCoverOk = (newCoverImageBytes != null &&
            newCoverImageBytes != kClearImageBytes) ||
        (!isCreating &&
            newCoverImageBytes == null &&
            article.coverUrl.isNotEmpty);

    return quillJsonToPlainText(article.title).length > 5 &&
        isCoverOk &&
        quillJsonToPlainText(article.abstractContent).length > 5 &&
        article.categoryId.isNotEmpty &&
        article.subcategoryId.isNotEmpty &&
        !publishDate.isBefore(now) &&
        !effectiveDate.isBefore(publishDate) &&
        isExpirationDateValid;
  }

  void _validateAndEmit(
      ArticleEditLoaded currentState, Emitter<ArticleEditState> emit) {
    final isValid = _isArticleValid(currentState.article,
        currentState.newCoverImageBytes, currentState.isCreating);
    emit(currentState.copyWith(isArticleValid: isValid));
  }

  Future<void> _onSaveArticle(
    SaveArticle event,
    Emitter<ArticleEditState> emit,
  ) async {
    if (state is! ArticleEditLoaded) return;

    final currentState = state as ArticleEditLoaded;
    emit(currentState.copyWith(isSaving: true));

    // Re-validar antes de guardar por si acaso.
    if (!currentState.isArticleValid) {
      emit(currentState.copyWith(
          isSaving: false,
          errorMessage: () =>
              'El artículo no cumple los requisitos para ser guardado.'));
      return;
    }

    // Si hay secciones, ninguna puede estar completamente vacía.
    if (currentState.article.sections.any((section) {
      final hasText =
          quillJsonToPlainText(section.richTextContent ?? '').isNotEmpty;
      final hasExistingImage =
          section.imageUrl != null && section.imageUrl!.isNotEmpty;
      final hasNewImage =
          currentState.newSectionImageBytes.containsKey(section.id);

      return !hasText && !hasExistingImage && !hasNewImage;
    })) {
      emit(currentState.copyWith(
          isSaving: false,
          errorMessage: () =>
              'Una sección no puede estar vacía. Debe tener texto o una imagen.'));
      //return; // Comentado para permitir guardar secciones vacías si se desea
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
          emit(const ArticleEditSuccess(isCreating: true));
        },
      );
    } else {
      final result = await _updateArticleUseCase(articleToSave,
          newCoverImageBytes: currentState.newCoverImageBytes,
          newSectionImageBytes: currentState.newSectionImageBytes,
          imagesToDelete:
              currentState.imagesToDelete); // Pasar las imágenes a borrar
      result.fold(
        (failure) => emit(currentState.copyWith(
            isSaving: false, errorMessage: () => failure.message)),
        (_) {
          // On success, clear the draft
          _sharedPreferences.remove(_getDraftKey(articleToSave.id));
          emit(const ArticleEditSuccess(isCreating: false));
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
      emit(const ArticleEditSuccess());
    });
  }

  void _onArticleFieldChanged(
    ArticleFieldChanged event,
    Emitter<ArticleEditState> emit,
  ) {
    if (state is ArticleEditLoaded) {
      final currentState = state as ArticleEditLoaded;
      final titleCharCount = quillJsonToPlainText(event.article.title).length;
      final abstractCharCount =
          quillJsonToPlainText(event.article.abstractContent).length;
      final newState = currentState.copyWith(
          article: event.article,
          titleCharCount: titleCharCount,
          abstractCharCount: abstractCharCount);
      _validateAndEmit(newState, emit);
      add(const AutoSaveDraft());
    }
  }

  void _onSetArticleStatus(
      SetArticleStatus event, Emitter<ArticleEditState> emit) {
    if (state is ArticleEditLoaded) {
      final currentState = state as ArticleEditLoaded;
      // Validar el artículo con el nuevo estado
      final isValid = _isArticleValid(
          currentState.article.copyWith(status: event.status),
          currentState.newCoverImageBytes,
          currentState.isCreating);
      // Emitir el estado con el status y la validez actualizados
      emit(
          currentState.copyWith(status: event.status, isArticleValid: isValid));
      add(const AutoSaveDraft());
    }
  }

  Future<void> _onCategoryChanged(
    CategoryChanged event,
    Emitter<ArticleEditState> emit,
  ) async {
    if (state is! ArticleEditLoaded) return;
    final currentState = state as ArticleEditLoaded;

    // 1. Cargar las nuevas subcategorías de forma asíncrona.
    final subcategoriesResult =
        await _getSubcategoriesUseCase(event.categoryId);

    // 2. Usar 'fold' para manejar el éxito o el fallo de la carga.
    subcategoriesResult.fold(
      (failure) {
        // En caso de fallo, emitir un estado de error.
        emit(currentState.copyWith(errorMessage: () => failure.message));
      },
      (newSubcategories) {
        // En caso de éxito, actualizar todo el estado de una vez.
        final categoryName = currentState.categories
            .firstWhere((c) => c.id == event.categoryId,
                orElse: () => CategoryEntity.empty())
            .name;

        final newState = currentState.copyWith(
            article: currentState.article.copyWith(
                categoryId: event.categoryId,
                categoryName: categoryName,
                subcategoryId: '',
                subcategoryName: ''),
            subcategories: newSubcategories);
        _validateAndEmit(newState, emit);
      },
    );
  }

  void _onSubcategoryChanged(
    SubcategoryChanged event,
    Emitter<ArticleEditState> emit,
  ) {
    if (state is ArticleEditLoaded) {
      final currentState = state as ArticleEditLoaded;
      final subcategoryName = currentState.subcategories
          .firstWhere((s) => s.id == event.subcategoryId,
              orElse: () => SubcategoryEntity.empty())
          .name;
      final newState = currentState.copyWith(
        article: currentState.article.copyWith(
          subcategoryId: event.subcategoryId,
          subcategoryName: subcategoryName,
        ),
      );
      _validateAndEmit(newState, emit);
      add(const AutoSaveDraft());
    }
  }

  void _onPublishDateChanged(
      PublishDateChanged event, Emitter<ArticleEditState> emit) {
    if (state is ArticleEditLoaded) {
      final currentState = state as ArticleEditLoaded;
      final newState = currentState.copyWith(
          article: currentState.article.copyWith(publishDate: event.date));
      _validateAndEmit(newState, emit);
      add(const AutoSaveDraft());
    }
  }

  void _onEffectiveDateChanged(
      EffectiveDateChanged event, Emitter<ArticleEditState> emit) {
    if (state is ArticleEditLoaded) {
      final currentState = state as ArticleEditLoaded;
      final newState = currentState.copyWith(
          article: currentState.article.copyWith(effectiveDate: event.date));
      _validateAndEmit(newState, emit);
      add(const AutoSaveDraft());
    }
  }

  void _onExpirationDateChanged(
      ExpirationDateChanged event, Emitter<ArticleEditState> emit) {
    if (state is ArticleEditLoaded) {
      final currentState = state as ArticleEditLoaded;
      // Usamos `copyWithNull` para asegurar que el null se propague.
      final newState = currentState.copyWith(
        article: currentState.article.copyWith(
          expirationDate: event.date,
        ),
        // Forzamos la re-evaluación del campo `newCoverImageBytes` para la validación.
        newCoverImageBytes: currentState.newCoverImageBytes,
      );
      _validateAndEmit(newState, emit);
      add(const AutoSaveDraft());
    }
  }

  void _onUpdateCoverImage(
      UpdateCoverImage event, Emitter<ArticleEditState> emit) {
    if (state is ArticleEditLoaded) {
      final currentState = state as ArticleEditLoaded;
      final newState =
          currentState.copyWith(newCoverImageBytes: event.newCoverImageBytes);
      _validateAndEmit(newState, emit); // Re-validar el artículo
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

      final imagesToDelete = List<String>.from(currentState.imagesToDelete);
      final sectionToUpdate = currentState.article.sections
          .firstWhere((s) => s.id == event.sectionId);

      if (event.imageBytes != null) {
        newBytesMap[event.sectionId] = event.imageBytes!;
      } else {
        // Si se está eliminando una imagen (imageBytes es null)
        newBytesMap.remove(event.sectionId);
        // Y si la sección tenía una URL de imagen guardada, la añadimos a la lista de borrado.
        if (sectionToUpdate.imageUrl != null &&
            sectionToUpdate.imageUrl!.isNotEmpty) {
          imagesToDelete.add(sectionToUpdate.imageUrl!);
        }
      }

      // Cuando se actualiza una imagen, siempre limpiamos la imageUrl de la entidad
      // para que la UI muestre la nueva imagen en memoria (o nada si se borró).
      final newSections = currentState.article.sections.map((s) {
        return s.id == event.sectionId ? s.copyWith(imageUrl: '') : s;
      }).toList();
      emit(currentState.copyWith(
          article: currentState.article.copyWith(sections: newSections),
          newSectionImageBytes: newBytesMap,
          imagesToDelete: imagesToDelete));
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

      // Calcular la validez y los contadores para el artículo del borrador.
      final isDraftValid = _isArticleValid(
        currentState.draftArticle,
        null, // No hay nueva imagen de portada al restaurar.
        currentState.draftArticle.id.isEmpty,
      );
      final titleCharCount =
          quillJsonToPlainText(currentState.draftArticle.title).length;
      final abstractCharCount =
          quillJsonToPlainText(currentState.draftArticle.abstractContent)
              .length;

      emit(ArticleEditLoaded(
        article: currentState.draftArticle,
        status: currentState.draftArticle.status,
        categories: categoriesResult.getOrElse(() => []),
        subcategories: subcategories,
        isCreating: currentState.draftArticle.id.isEmpty,
        isArticleValid: isDraftValid, // Pasar la validez calculada.
        titleCharCount: titleCharCount, // Pasar el contador de caracteres.
        abstractCharCount:
            abstractCharCount, // Pasar el contador de caracteres.
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
}
