import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:conectasoc/features/articles/domain/usecases/usecases.dart';
import 'package:conectasoc/features/documents/domain/entities/entities.dart';
import 'package:conectasoc/features/documents/domain/usecases/usecases.dart';
import 'package:conectasoc/features/documents/presentation/bloc/bloc.dart';
import 'package:conectasoc/services/cloudinary_document_service.dart';

class DocumentUploadBloc
    extends Bloc<DocumentUploadEvent, DocumentUploadState> {
  final CreateDocumentUseCase createDocumentUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;
  final GetSubcategoriesUseCase getSubcategoriesUseCase;

  DocumentUploadBloc({
    required this.createDocumentUseCase,
    required this.getCategoriesUseCase,
    required this.getSubcategoriesUseCase,
  }) : super(DocumentUploadInitial()) {
    on<InitializeUpload>(_onInitializeUpload);
    on<FileSelected>(_onFileSelected);
    on<DescriptionChanged>(_onDescriptionChanged);
    on<CategoryChanged>(_onCategoryChanged);
    on<SubcategoryChanged>(_onSubcategoryChanged);
    on<DownloadPermissionChanged>(_onDownloadPermissionChanged);
    on<SubmitDocumentUpload>(_onSubmitDocumentUpload);
    on<ResetUpload>(_onResetUpload);
  }

  Future<void> _onInitializeUpload(
    InitializeUpload event,
    Emitter<DocumentUploadState> emit,
  ) async {
    try {
      // Load categories
      final categoriesResult = await getCategoriesUseCase();

      await categoriesResult.fold(
        (failure) async {
          emit(DocumentUploadFailure(failure.message));
        },
        (categories) async {
          // Load subcategories if category is provided
          if (event.categoryId.isNotEmpty) {
            final subcategoriesResult =
                await getSubcategoriesUseCase(event.categoryId);

            subcategoriesResult.fold(
              (failure) {
                emit(DocumentUploadFailure(failure.message));
              },
              (subcategories) {
                emit(DocumentUploadReady(
                  associationId: event.associationId,
                  categoryId: event.categoryId,
                  subcategoryId: event.subcategoryId,
                  userId: event.userId,
                  categories: categories,
                  subcategories: subcategories,
                ));
              },
            );
          } else {
            emit(DocumentUploadReady(
              associationId: event.associationId,
              categoryId: '',
              subcategoryId: '',
              userId: event.userId,
              categories: categories,
              subcategories: [],
            ));
          }
        },
      );
    } catch (e) {
      emit(DocumentUploadFailure('Error al inicializar: $e'));
    }
  }

  void _onFileSelected(
    FileSelected event,
    Emitter<DocumentUploadState> emit,
  ) {
    if (state is DocumentUploadReady) {
      final currentState = state as DocumentUploadReady;

      // Validate file type
      if (!CloudinaryDocumentService.isSupportedDocument(event.fileName)) {
        emit(const DocumentUploadFailure(
            'Tipo de archivo no soportado. Use PDF, Word, Excel o PowerPoint.'));
        // Return to ready state after error
        emit(currentState);
        return;
      }

      // Validate file size (max 25MB)
      const maxSize = 25 * 1024 * 1024;
      if (event.fileBytes.length > maxSize) {
        final sizeMB =
            (event.fileBytes.length / (1024 * 1024)).toStringAsFixed(1);
        emit(DocumentUploadFailure(
            'Archivo demasiado grande ($sizeMB MB). Máximo: 25MB'));
        // Return to ready state after error
        emit(currentState);
        return;
      }

      emit(currentState.copyWith(
        selectedFileBytes: event.fileBytes,
        selectedFileName: event.fileName,
      ));
    }
  }

  void _onDescriptionChanged(
    DescriptionChanged event,
    Emitter<DocumentUploadState> emit,
  ) {
    if (state is DocumentUploadReady) {
      final currentState = state as DocumentUploadReady;
      emit(currentState.copyWith(description: event.description));
    }
  }

  Future<void> _onCategoryChanged(
    CategoryChanged event,
    Emitter<DocumentUploadState> emit,
  ) async {
    if (state is DocumentUploadReady) {
      final currentState = state as DocumentUploadReady;

      // Load subcategories for the new category
      final subcategoriesResult =
          await getSubcategoriesUseCase(event.categoryId);

      subcategoriesResult.fold(
        (failure) {
          emit(DocumentUploadFailure(failure.message));
          emit(currentState);
        },
        (subcategories) {
          emit(currentState.copyWith(
            categoryId: event.categoryId,
            subcategoryId: '', // Reset subcategory
            subcategories: subcategories,
          ));
        },
      );
    }
  }

  void _onSubcategoryChanged(
    SubcategoryChanged event,
    Emitter<DocumentUploadState> emit,
  ) {
    if (state is DocumentUploadReady) {
      final currentState = state as DocumentUploadReady;
      emit(currentState.copyWith(subcategoryId: event.subcategoryId));
    }
  }

  void _onDownloadPermissionChanged(
    DownloadPermissionChanged event,
    Emitter<DocumentUploadState> emit,
  ) {
    if (state is DocumentUploadReady) {
      final currentState = state as DocumentUploadReady;
      emit(currentState.copyWith(canDownload: event.canDownload));
    }
  }

  Future<void> _onSubmitDocumentUpload(
    SubmitDocumentUpload event,
    Emitter<DocumentUploadState> emit,
  ) async {
    if (state is! DocumentUploadReady) return;
    final currentState = state as DocumentUploadReady;

    if (!currentState.isValid) {
      emit(const DocumentUploadFailure(
          'Por favor complete todos los campos requeridos'));
      emit(currentState);
      return;
    }

    try {
      emit(const DocumentUploadInProgress(0.0));

      // Upload to Cloudinary
      emit(const DocumentUploadInProgress(0.3));
      final cloudinaryResponse = await CloudinaryDocumentService.uploadDocument(
        fileBytes: currentState.selectedFileBytes!,
        filename: currentState.selectedFileName!,
        associationId: currentState.associationId,
        categoryId: currentState.categoryId,
        subcategoryId: currentState.subcategoryId,
      );

      if (!cloudinaryResponse.success) {
        emit(DocumentUploadFailure(
            cloudinaryResponse.error ?? 'Error al subir documento'));
        emit(currentState);
        return;
      }

      emit(const DocumentUploadInProgress(0.7));

      // Create document entity
      final now = DateTime.now();
      final document = DocumentEntity(
        id: '', // Will be generated by Firestore
        urlDoc: cloudinaryResponse.urlDoc!,
        urlThumb: cloudinaryResponse.urlThumb!,
        descDoc: currentState.description.trim(),
        canDownload: currentState.canDownload,
        associationId: currentState.associationId,
        categoryId: currentState.categoryId,
        subcategoryId: currentState.subcategoryId,
        dateCreation: now,
        dateModification: now,
        uploadedBy: currentState.userId,
        fileName: currentState.selectedFileName!,
        fileExtension: currentState.fileExtension!,
        fileSize: currentState.selectedFileBytes!.length,
      );

      // Save to Firestore
      emit(const DocumentUploadInProgress(0.9));
      final result = await createDocumentUseCase(document);

      result.fold(
        (failure) {
          emit(DocumentUploadFailure(failure.message));
          emit(currentState);
        },
        (savedDocument) {
          emit(DocumentUploadSuccess(savedDocument));
        },
      );
    } catch (e) {
      emit(DocumentUploadFailure('Error al subir documento: $e'));
      emit(currentState);
    }
  }

  void _onResetUpload(
    ResetUpload event,
    Emitter<DocumentUploadState> emit,
  ) {
    if (state is DocumentUploadReady) {
      final currentState = state as DocumentUploadReady;
      emit(currentState.copyWith(
        description: '',
        canDownload: true,
        clearFile: true,
      ));
    }
  }
}
