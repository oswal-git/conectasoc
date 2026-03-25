import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:conectasoc/features/articles/domain/entities/entities.dart';
import 'package:conectasoc/features/articles/domain/usecases/usecases.dart';
import 'package:conectasoc/features/documents/domain/usecases/usecases.dart';
import 'package:conectasoc/features/documents/presentation/bloc/edit/document_edit_event_bloc.dart';
import 'package:conectasoc/features/documents/presentation/bloc/edit/document_edit_state_bloc.dart';
import 'package:conectasoc/services/cloudinary_document_service.dart';

class DocumentEditBloc extends Bloc<DocumentEditEvent, DocumentEditState> {
  final UpdateDocumentUseCase updateDocumentUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;
  final GetSubcategoriesUseCase getSubcategoriesUseCase;

  DocumentEditBloc({
    required this.updateDocumentUseCase,
    required this.getCategoriesUseCase,
    required this.getSubcategoriesUseCase,
  }) : super(DocumentEditInitial()) {
    on<LoadDocumentForEdit>(_onLoadDocumentForEdit);
    on<EditDescriptionChanged>(_onDescriptionChanged);
    on<EditCategoryChanged>(_onCategoryChanged);
    on<EditSubcategoryChanged>(_onSubcategoryChanged);
    on<EditDownloadPermissionChanged>(_onDownloadPermissionChanged);
    on<SubmitDocumentEdit>(_onSubmitDocumentEdit);
  }

  Future<void> _onLoadDocumentForEdit(
    LoadDocumentForEdit event,
    Emitter<DocumentEditState> emit,
  ) async {
    emit(DocumentEditLoading());
    try {
      // Cargar categorías
      final categoriesResult =
          await getCategoriesUseCase(assocId: event.associationId);

      await categoriesResult.fold(
        (failure) async => emit(DocumentEditFailure(failure.message)),
        (categories) async {
          // Cargar subcategorías de la categoría del documento
          final subcategoriesResult = await getSubcategoriesUseCase(
            event.document.categoryId,
            assocId: event.associationId,
          );

          subcategoriesResult.fold(
            (failure) => emit(DocumentEditFailure(failure.message)),
            (subcategories) {
              emit(DocumentEditReady(
                originalDocument: event.document,
                description: event.document.descDoc,
                categoryId: event.document.categoryId,
                subcategoryId: event.document.subcategoryId,
                canDownload: event.document.canDownload,
                categories: categories,
                subcategories: subcategories,
                associationId: event.associationId,
              ));
            },
          );
        },
      );
    } catch (e) {
      emit(DocumentEditFailure('Error al cargar datos de edición: $e'));
    }
  }

  void _onDescriptionChanged(
    EditDescriptionChanged event,
    Emitter<DocumentEditState> emit,
  ) {
    if (state is DocumentEditReady) {
      emit((state as DocumentEditReady).copyWith(description: event.description));
    }
  }

  Future<void> _onCategoryChanged(
    EditCategoryChanged event,
    Emitter<DocumentEditState> emit,
  ) async {
    if (state is DocumentEditReady) {
      final currentState = state as DocumentEditReady;
      
      // Si la categoría no ha cambiado, no hacer nada
      if (currentState.categoryId == event.categoryId) return;

      emit(currentState.copyWith(
        categoryId: event.categoryId,
        subcategoryId: '', // Reset subcategoría al cambiar categoría
      ));

      // Cargar subcategorías para la nueva categoría
      if (event.categoryId.isNotEmpty) {
        final subcategoriesResult = await getSubcategoriesUseCase(
          event.categoryId,
          assocId: currentState.associationId,
        );

        subcategoriesResult.fold(
          (failure) => emit(DocumentEditFailure(failure.message)),
          (subcategories) {
            if (state is DocumentEditReady) {
              emit((state as DocumentEditReady).copyWith(subcategories: subcategories));
            }
          },
        );
      } else {
        emit(currentState.copyWith(subcategories: []));
      }
    }
  }

  void _onSubcategoryChanged(
    EditSubcategoryChanged event,
    Emitter<DocumentEditState> emit,
  ) {
    if (state is DocumentEditReady) {
      emit((state as DocumentEditReady).copyWith(subcategoryId: event.subcategoryId));
    }
  }

  void _onDownloadPermissionChanged(
    EditDownloadPermissionChanged event,
    Emitter<DocumentEditState> emit,
  ) {
    if (state is DocumentEditReady) {
      emit((state as DocumentEditReady).copyWith(canDownload: event.canDownload));
    }
  }

  Future<void> _onSubmitDocumentEdit(
    SubmitDocumentEdit event,
    Emitter<DocumentEditState> emit,
  ) async {
    if (state is! DocumentEditReady) return;
    final currentState = state as DocumentEditReady;

    if (!currentState.hasChanges) {
      emit(DocumentEditSuccess(currentState.originalDocument));
      return;
    }

    emit(const DocumentEditSubmitting(0.2));

    try {
      // 1. Obtener nombres actualizados
      final categoryName = currentState.categories
          .firstWhere((c) => c.id == currentState.categoryId,
              orElse: () => CategoryEntity.empty())
          .name;

      final subcategoryName = currentState.subcategories
          .firstWhere((s) => s.id == currentState.subcategoryId,
              orElse: () => SubcategoryEntity.empty())
          .name;

      // 2. Actualizar metadatos en Cloudinary si han cambiado los campos relevantes
      bool cloudinarySuccess = true;
      final needsCloudinaryUpdate = categoryName != currentState.originalDocument.categoryName ||
          subcategoryName != currentState.originalDocument.subcategoryName ||
          currentState.originalDocument.uploaderName.isEmpty; // por si acaso

      if (needsCloudinaryUpdate) {
        emit(const DocumentEditSubmitting(0.5));
        cloudinarySuccess = await CloudinaryDocumentService.updateDocumentMetadata(
          publicId: currentState.originalDocument.publicId,
          isPdf: currentState.originalDocument.fileExtension.toLowerCase() == 'pdf',
          categoryName: categoryName,
          subcategoryName: subcategoryName,
          uploaderName: currentState.originalDocument.uploaderName,
        );
      }

      if (!cloudinarySuccess) {
        emit(const DocumentEditFailure('Error al actualizar metadatos en Cloudinary'));
        emit(currentState);
        return;
      }

      emit(const DocumentEditSubmitting(0.8));

      // 3. Actualizar en Firestore
      final updatedDoc = currentState.originalDocument.copyWith(
        descDoc: currentState.description,
        categoryId: currentState.categoryId,
        categoryName: categoryName,
        subcategoryId: currentState.subcategoryId,
        subcategoryName: subcategoryName,
        canDownload: currentState.canDownload,
        dateModification: DateTime.now(),
      );

      final result = await updateDocumentUseCase(updatedDoc);

      result.fold(
        (failure) {
          emit(DocumentEditFailure(failure.message));
          emit(currentState);
        },
        (document) => emit(DocumentEditSuccess(document)),
      );
    } catch (e) {
      emit(DocumentEditFailure('Error al guardar cambios: $e'));
      emit(currentState);
    }
  }
}
