import 'package:conectasoc/features/articles/domain/entities/entities.dart';
import 'package:conectasoc/features/articles/presentation/bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:conectasoc/features/articles/domain/usecases/usecases.dart';
import 'package:conectasoc/features/auth/presentation/bloc/bloc.dart';

class ArticleEditBloc extends Bloc<ArticleEditEvent, ArticleEditState> {
  final CreateArticleUseCase _createArticleUseCase;
  final UpdateArticleUseCase _updateArticleUseCase;
  final GetArticleByIdUseCase _getArticleByIdUseCase;
  final DeleteArticleUseCase _deleteArticleUseCase;
  final GetCategoriesUseCase _getCategoriesUseCase;
  final GetSubcategoriesUseCase _getSubcategoriesUseCase;
  final AuthBloc _authBloc;

  ArticleEditBloc({
    required CreateArticleUseCase createArticleUseCase,
    required UpdateArticleUseCase updateArticleUseCase,
    required GetArticleByIdUseCase getArticleByIdUseCase,
    required DeleteArticleUseCase deleteArticleUseCase,
    required GetCategoriesUseCase getCategoriesUseCase,
    required GetSubcategoriesUseCase getSubcategoriesUseCase,
    required AuthBloc authBloc,
  })  : _createArticleUseCase = createArticleUseCase,
        _updateArticleUseCase = updateArticleUseCase,
        _getArticleByIdUseCase = getArticleByIdUseCase,
        _deleteArticleUseCase = deleteArticleUseCase,
        _getCategoriesUseCase = getCategoriesUseCase,
        _getSubcategoriesUseCase = getSubcategoriesUseCase,
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
  }

  Future<void> _onPrepareArticleCreation(
    PrepareArticleCreation event,
    Emitter<ArticleEditState> emit,
  ) async {
    emit(ArticleEditLoading());

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

      categoriesResult.fold(
        (failure) => emit(ArticleEditFailure(failure.message)),
        (categories) {
          final newArticle = ArticleEntity.empty().copyWith(
            userId: user.uid,
            authorName: user.fullName,
            authorAvatarUrl: user.avatarUrl,
            assocId: currentMembership
                .associationId, // Use current membership's assocId
            associationShortName: currentMembership
                .associationId, // Placeholder, should be fetched
            status: ArticleStatus.redaccion, // Default status for new articles
            sections: [
              ArticleSection(id: UniqueKey().toString(), order: 0)
            ], // Start with one empty section
          );

          emit(ArticleEditLoaded(
            article: newArticle,
            categories: categories,
            subcategories: const [],
            isCreating: true,
          ));
        },
      );
    } catch (e) {
      emit(ArticleEditFailure(
          'Error inesperado al preparar la creación: ${e.toString()}'));
    }
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

      emit(ArticleEditLoaded(
          article: article,
          status: article.status, // Initialize status in state
          categories: categories,
          subcategories: subcategories));
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

    // Perform validation
    if (currentState.article.title.isEmpty ||
        currentState.article.abstractContent.isEmpty ||
        currentState.article.categoryId.isEmpty ||
        currentState.article.subcategoryId.isEmpty ||
        currentState.article.sections.isEmpty ||
        currentState.article.sections
            .every((s) => s.richTextContent == null && s.imageUrl == null)) {
      emit(currentState.copyWith(
          isSaving: false,
          errorMessage: () =>
              'Por favor, complete todos los campos obligatorios y asegúrese de que las secciones tengan contenido.'));
      return;
    }

    final articleToSave = currentState.article.copyWith(
      modifiedAt: DateTime.now(),
      status: currentState.status, // Use status from state
    );

    if (currentState.isCreating) {
      if (currentState.newCoverImageFile == null) {
        emit(currentState.copyWith(
            isSaving: false,
            errorMessage: () => 'La imagen de portada es obligatoria.'));
        return;
      }
      final result = await _createArticleUseCase(
          articleToSave, currentState.newCoverImageFile!);
      result.fold(
        (failure) => emit(currentState.copyWith(
            isSaving: false, errorMessage: () => failure.message)),
        (_) => emit(ArticleEditSuccess()),
      );
    } else {
      final result = await _updateArticleUseCase(articleToSave,
          coverImageFile: currentState.newCoverImageFile);
      result.fold(
        (failure) => emit(currentState.copyWith(
            isSaving: false, errorMessage: () => failure.message)),
        (_) => emit(ArticleEditSuccess()),
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
    result.fold((failure) => emit(ArticleEditFailure(failure.message)),
        (_) => emit(ArticleEditSuccess()));
  }

  void _onArticleFieldChanged(
    ArticleFieldChanged event,
    Emitter<ArticleEditState> emit,
  ) {
    if (state is ArticleEditLoaded) {
      final currentState = state as ArticleEditLoaded;
      emit(currentState.copyWith(article: event.article));
    }
  }

  void _onSetArticleStatus(
      SetArticleStatus event, Emitter<ArticleEditState> emit) {
    if (state is ArticleEditLoaded) {
      final currentState = state as ArticleEditLoaded;
      emit(currentState.copyWith(status: event.status));
    }
  }

  Future<void> _onCategoryChanged(
    CategoryChanged event,
    Emitter<ArticleEditState> emit,
  ) async {
    if (state is ArticleEditLoaded) {
      final currentState = state as ArticleEditLoaded;
      // Actualiza la categoría y limpia la subcategoría
      final updatedArticle = currentState.article
          .copyWith(categoryId: event.categoryId, subcategoryId: '');
      emit(currentState.copyWith(article: updatedArticle, subcategories: []));

      // Carga las nuevas subcategorías
      final subcategoriesResult =
          await _getSubcategoriesUseCase(event.categoryId);
      subcategoriesResult.fold(
        (failure) => emit(currentState.copyWith(
            errorMessage: () =>
                'Error al cargar subcategorías: ${failure.message}')),
        (subcategories) =>
            emit(currentState.copyWith(subcategories: subcategories)),
      );
    }
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
    }
  }

  void _onPublishDateChanged(
      PublishDateChanged event, Emitter<ArticleEditState> emit) {
    if (state is ArticleEditLoaded) {
      final currentState = state as ArticleEditLoaded;
      emit(currentState.copyWith(
          article: currentState.article.copyWith(publishDate: event.date)));
    }
  }

  void _onEffectiveDateChanged(
      EffectiveDateChanged event, Emitter<ArticleEditState> emit) {
    if (state is ArticleEditLoaded) {
      final currentState = state as ArticleEditLoaded;
      emit(currentState.copyWith(
          article: currentState.article.copyWith(effectiveDate: event.date)));
    }
  }

  void _onExpirationDateChanged(
      ExpirationDateChanged event, Emitter<ArticleEditState> emit) {
    if (state is ArticleEditLoaded) {
      final currentState = state as ArticleEditLoaded;
      emit(currentState.copyWith(
          article: currentState.article.copyWith(expirationDate: event.date)));
    }
  }

  void _onUpdateCoverImage(
      UpdateCoverImage event, Emitter<ArticleEditState> emit) {
    if (state is ArticleEditLoaded) {
      final currentState = state as ArticleEditLoaded;
      emit(currentState.copyWith(newCoverImageFile: event.newCoverImageFile));
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
      // Update order property
      for (int i = 0; i < newSections.length; i++) {
        newSections[i] = newSections[i].copyWith(order: i);
      }
      emit(currentState.copyWith(
          article: currentState.article.copyWith(sections: newSections)));
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
    }
  }

  void _onUpdateSectionImage(
      UpdateSectionImage event, Emitter<ArticleEditState> emit) {
    if (state is ArticleEditLoaded) {
      final currentState = state as ArticleEditLoaded;
      final newSections = currentState.article.sections.map((s) {
        return s.id == event.sectionId
            ? s.copyWith(imageUrl: event.imageFile?.path)
            : s; // Store path temporarily
      }).toList();
      emit(currentState.copyWith(
          article: currentState.article.copyWith(sections: newSections)));
    }
  }
}
