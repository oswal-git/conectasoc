import 'dart:typed_data';
import 'package:conectasoc/core/constants/cloudinary_config.dart';
import 'package:conectasoc/services/cloudinary_service.dart';
import 'package:dartz/dartz.dart';

import 'package:conectasoc/core/errors/exceptions.dart';
import 'package:conectasoc/core/errors/failures.dart';
import 'package:conectasoc/features/associations/data/datasources/association_remote_datasource.dart';
import 'package:conectasoc/features/associations/data/models/association_model.dart';
import 'package:conectasoc/features/associations/domain/entities/association_entity.dart';
import 'package:conectasoc/features/associations/domain/repositories/association_repository.dart';

class AssociationRepositoryImpl implements AssociationRepository {
  final AssociationRemoteDataSource remoteDataSource;

  AssociationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<AssociationEntity>>> getAllAssociations() async {
    try {
      final associationModels = await remoteDataSource.getAllAssociations();
      // Los modelos se convierten a entidades para la capa de dominio.
      // Filtramos cualquier posible nulo antes de mapear para garantizar la seguridad de tipos.
      final entities = associationModels
          .whereType<AssociationModel>()
          .map((model) => model.toEntity())
          .toList();
      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
          ServerFailure('Ocurrió un error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, AssociationEntity>> getAssociationById(
      String id) async {
    try {
      final associationModel = await remoteDataSource.getAssociationById(id);
      return Right(associationModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
          ServerFailure('Ocurrió un error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, AssociationEntity>> updateAssociation({
    required AssociationEntity association,
    Uint8List? logoBytes,
  }) async {
    try {
      // Gestionar la subida y borrado del logo
      final logoResult = await _handleLogoUpdate(
          logoBytes, association.logoUrl, association.shortName);
      final newLogoUrl = logoResult.getOrElse(() => null);

      final associationModel = AssociationModel.fromEntity(association);

      // Llamar al datasource para actualizar la asociación en Firestore
      final updatedAssociationModel = await remoteDataSource.updateAssociation(
          associationModel, newLogoUrl);

      return Right(updatedAssociationModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
          ServerFailure('Ocurrió un error inesperado: ${e.toString()}'));
    }
  }

  /// Método privado para manejar la lógica de actualización del logo.
  /// Devuelve la nueva URL del logo si la subida es exitosa.
  Future<Either<Failure, String?>> _handleLogoUpdate(
      Uint8List? newLogoBytes, String? currentLogoUrl, String shortName) async {
    if (newLogoBytes == null) {
      return const Right(null); // No hay cambios en el logo
    }

    String? oldPublicId;
    if (currentLogoUrl != null && currentLogoUrl.isNotEmpty) {
      oldPublicId = CloudinaryService.getPublicIdFromUrl(currentLogoUrl);
    }

    final uploadResult = await CloudinaryService.uploadImageBytes(
      imageBytes: newLogoBytes,
      imageType: CloudinaryImageType.logoAssociation,
      filename: shortName,
    );

    if (!uploadResult.success) {
      return Left(
          ServerFailure(uploadResult.error ?? 'Error al subir el logo'));
    }

    // Si la subida fue exitosa y había una imagen anterior, la borramos.
    // Hacemos esto después de la subida para no perder la imagen antigua si la nueva falla.
    if (oldPublicId != null) {
      // No necesitamos esperar a que termine, puede hacerse en segundo plano.
      CloudinaryService.deleteImage(oldPublicId);
    }

    return Right(uploadResult.secureUrl);
  }

  @override
  Future<Either<Failure, AssociationEntity>> createAssociation({
    required String shortName,
    required String longName,
    required String email,
    required String contactName,
    required String phone,
    String? creatorId,
    String? contactUserId,
    Uint8List? logoBytes,
  }) async {
    try {
      String? logoUrl;
      if (logoBytes != null) {
        final uploadResult = await CloudinaryService.uploadImageBytes(
          imageBytes: logoBytes,
          imageType: CloudinaryImageType.logoAssociation,
          filename: shortName, // Use shortName for a somewhat unique filename
        );
        if (uploadResult.success) {
          logoUrl = uploadResult.secureUrl;
        } else {
          return Left(ServerFailure(
              uploadResult.error ?? 'Error al subir el logo de la asociación'));
        }
      }

      final createdModel = await remoteDataSource.createAssociation(
        shortName: shortName,
        longName: longName,
        email: email,
        contactName: contactName,
        phone: phone,
        creatorId: creatorId,
        contactUserId: contactUserId,
        logoUrl: logoUrl,
      );
      return Right(createdModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAssociation(String associationId) async {
    try {
      await remoteDataSource.deleteAssociation(associationId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> undoDeleteAssociation(String id) async {
    try {
      await remoteDataSource.undoDeleteAssociation(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
