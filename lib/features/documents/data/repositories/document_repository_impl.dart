import 'package:dartz/dartz.dart';
import 'package:conectasoc/core/errors/failures.dart';
import 'package:conectasoc/features/documents/data/datasources/document_remote_datasource.dart';
import 'package:conectasoc/features/documents/data/models/document_model.dart';
import 'package:conectasoc/features/documents/domain/entities/document_entity.dart';
import 'package:conectasoc/features/documents/domain/repositories/document_repository.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  final DocumentRemoteDataSource remoteDataSource;

  DocumentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, DocumentEntity>> createDocument(
    DocumentEntity document,
  ) async {
    try {
      final documentModel = DocumentModel.fromEntity(document);
      final result = await remoteDataSource.createDocument(documentModel);
      return Right(result.toEntity());
    } catch (e) {
      return Left(ServerFailure('Error al crear documento: $e'));
    }
  }

  @override
  Future<Either<Failure, DocumentEntity>> getDocumentById(
    String documentId,
  ) async {
    try {
      final result = await remoteDataSource.getDocumentById(documentId);
      return Right(result.toEntity());
    } catch (e) {
      return Left(ServerFailure('Error al obtener documento: $e'));
    }
  }

  @override
  Future<Either<Failure, List<DocumentEntity>>> getDocumentsByAssociation({
    String? associationId,
    String? categoryId,
    String? subcategoryId,
  }) async {
    try {
      final result = await remoteDataSource.getDocumentsByAssociation(
        associationId: associationId,
        categoryId: categoryId,
        subcategoryId: subcategoryId,
      );
      return Right(result.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(
          ServerFailure('Error al obtener documentos por asociación: $e'));
    }
  }

  @override
  Future<Either<Failure, List<DocumentEntity>>> searchDocuments({
    required String query,
    String? associationId,
    String? categoryId,
    String? subcategoryId,
  }) async {
    try {
      final result = await remoteDataSource.searchDocuments(
        query: query,
        associationId: associationId,
        categoryId: categoryId,
        subcategoryId: subcategoryId,
      );
      return Right(result.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure('Error al buscar documentos: $e'));
    }
  }

  @override
  Future<Either<Failure, DocumentEntity>> updateDocument(
    DocumentEntity document,
  ) async {
    try {
      final documentModel = DocumentModel.fromEntity(document);
      final result = await remoteDataSource.updateDocument(documentModel);
      return Right(result.toEntity());
    } catch (e) {
      return Left(ServerFailure('Error al actualizar documento: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDocument(String documentId) async {
    try {
      await remoteDataSource.deleteDocument(documentId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Error al eliminar documento: $e'));
    }
  }

  @override
  Future<Either<Failure, List<DocumentEntity>>> getDocumentsByCategory({
    required String categoryId,
    String? associationId,
  }) async {
    try {
      final result = await remoteDataSource.getDocumentsByCategory(
        categoryId: categoryId,
        associationId: associationId,
      );
      return Right(result.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(
          ServerFailure('Error al obtener documentos por categoría: $e'));
    }
  }

  @override
  Future<Either<Failure, List<DocumentEntity>>> getDocumentsBySubcategory({
    required String subcategoryId,
    String? associationId,
  }) async {
    try {
      final result = await remoteDataSource.getDocumentsBySubcategory(
        subcategoryId: subcategoryId,
        associationId: associationId,
      );
      return Right(result.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(
          ServerFailure('Error al obtener documentos por subcategoría: $e'));
    }
  }
}
