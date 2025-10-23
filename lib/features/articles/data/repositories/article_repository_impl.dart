import 'dart:io';

import 'package:tuple/tuple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conectasoc/core/constants/cloudinary_config.dart';
import 'package:conectasoc/core/errors/failures.dart';
import 'package:conectasoc/features/articles/data/models/models.dart';
import 'package:conectasoc/features/articles/domain/entities/article_entity.dart';
import 'package:conectasoc/features/articles/domain/repositories/article_repository.dart';
import 'package:conectasoc/features/auth/domain/entities/entities.dart';
import 'package:conectasoc/features/users/domain/entities/entities.dart';
import 'package:conectasoc/services/cloudinary_service.dart';
import 'package:dartz/dartz.dart' hide Tuple2;

class ArticleRepositoryImpl implements ArticleRepository {
  final FirebaseFirestore firestore;

  ArticleRepositoryImpl({required this.firestore});

  @override
  Future<Either<Failure, Tuple2<List<ArticleEntity>, DocumentSnapshot?>>>
      getArticles({
    IUser? user,
    bool isEditMode = false,
    String? categoryId,
    String? subcategoryId,
    String? searchTerm,
    DocumentSnapshot? lastDocument,
    int limit = 20,
  }) async {
    try {
      Query query = firestore.collection('articles');

      // 1. Filtrado por permisos y visibilidad
      if (isEditMode && user != null && user.canEditContent) {
        // isEditMode is now passed
        // En modo edición, los usuarios con permisos ven todos los estados
        if (!user.isSuperAdmin) {
          // Admin/Editor ven solo los de su asociación.
          final userAssociationIds = user.associationIds;
          query = query.where('assocId', whereIn: userAssociationIds);
        }
      } else {
        // Modo lectura: solo artículos publicados y vigentes
        query = query.where('status',
            isEqualTo: ArticleStatus.publicado.value); // Use updated enum value

        // Filtrar por asociación según el tipo de usuario usando un switch
        switch (user) {
          case null: // No logueado
            query = query.where('assocId', isEqualTo: '');
            break;
          case LocalUserEntity localUser: // Usuario local
            final assocIds = ['', ...localUser.associationIds];
            query = query.where('assocId', whereIn: assocIds);
            break;
          case UserEntity authUser: // Usuario autenticado
            final userAssociationIds = authUser.associationIds;
            final assocIds = ['', ...userAssociationIds];
            query = query.where('assocId', whereIn: assocIds);
            break;
        }
      }

      // 2. Aplicar filtros de contenido
      if (categoryId != null && categoryId.isNotEmpty) {
        query = query.where('categoryId', isEqualTo: categoryId);
      }
      if (subcategoryId != null && subcategoryId.isNotEmpty) {
        query = query.where('subcategoryId', isEqualTo: subcategoryId);
      }

      // 3. Aplicar filtro de búsqueda de texto
      // Firestore no soporta 'contains', pero podemos simularlo buscando por prefijos.
      if (searchTerm != null && searchTerm.trim().isNotEmpty) {
        final term = searchTerm.toLowerCase().trim();
        query = query.where('searchText', arrayContains: term);
      }

      query = query
          // Ya no podemos filtrar por effectiveDate, así que ordenamos por publishDate.
          .orderBy('publishDate', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();

      final articles = snapshot.docs
          .map((doc) => ArticleModel.fromFirestore(doc))
          .where((article) {
        // Filtro de expiración en el cliente
        final now = DateTime.now();
        final isEffective = article.effectiveDate.isBefore(now) ||
            article.effectiveDate.isAtSameMomentAs(now);
        final isNotExpired = article.expirationDate == null ||
            article.expirationDate!.isAfter(now);

        return (isEffective && isNotExpired) || isEditMode;
      }).toList();

      // Get the last document for the next page's cursor
      final newLastDocument =
          snapshot.docs.isNotEmpty ? snapshot.docs.last : null;

      return Right(Tuple2(articles, newLastDocument));
    } catch (e) {
      return Left(ServerFailure('Error al obtener los artículos: $e'));
    }
  }

  @override
  Future<Either<Failure, ArticleEntity>> createArticle(
      ArticleEntity article, File coverImageFile) async {
    String? uploadedCoverUrl;
    final List<String> uploadedSectionImageUrls = [];

    try {
      // 1. Subir imagen de portada a Cloudinary
      final uploadResult = await CloudinaryService.uploadImage(
        imageFile: coverImageFile,
        imageType: CloudinaryImageType.articleCover,
      );

      if (!uploadResult.success) {
        return Left(ServerFailure(
            uploadResult.error ?? 'Error al subir la imagen de portada.'));
      }
      uploadedCoverUrl = uploadResult.secureUrl;

      // 2. Subir imágenes de las secciones
      final List<ArticleSection> sectionsWithUploadedImages = [];
      for (final section in article.sections) {
        if (section.imageUrl != null && !section.imageUrl!.startsWith('http')) {
          final sectionImageFile = File(section.imageUrl!);
          final sectionUpload = await CloudinaryService.uploadImage(
            imageFile: sectionImageFile,
            imageType: CloudinaryImageType.articleSection,
          );
          if (!sectionUpload.success || sectionUpload.secureUrl == null) {
            // Si falla la subida de una imagen de sección, se lanza una excepción para activar el rollback.
            throw ServerFailure(sectionUpload.error ??
                'Error al subir imagen de sección o URL nula.');
          }
          // Now that we've checked for null, we can use the bang operator (!) safely.
          uploadedSectionImageUrls.add(sectionUpload.secureUrl!);
          sectionsWithUploadedImages
              .add(section.copyWith(imageUrl: sectionUpload.secureUrl!));
        } else {
          sectionsWithUploadedImages.add(section);
        }
      }

      final articleWithCoverAndSections = article.copyWith(
          coverUrl: uploadedCoverUrl, sections: sectionsWithUploadedImages);
      final articleModel = ArticleModel.fromEntity(articleWithCoverAndSections);

      // 3. Escribir en Firestore
      final docRef = await firestore
          .collection('articles')
          .add(articleModel.toFirestore());

      // 4. Devolver la entidad completa con el ID asignado
      return Right(articleModel.copyWith(id: docRef.id));
    } catch (e) {
      // ROLLBACK: Si algo falla (subida de imagen de sección o escritura en Firestore),
      // se borran las imágenes que ya se habían subido.
      if (uploadedCoverUrl != null) {
        await CloudinaryService.deleteImage(uploadedCoverUrl);
      }
      for (final url in uploadedSectionImageUrls) {
        await CloudinaryService.deleteImage(url);
      }
      return Left(ServerFailure('Error al crear el artículo: $e'));
    }
  }

  @override
  Future<Either<Failure, ArticleEntity>> getArticleById(
    String articleId,
  ) async {
    try {
      final docSnapshot =
          await firestore.collection('articles').doc(articleId).get();
      if (docSnapshot.exists) {
        return Right(ArticleModel.fromFirestore(docSnapshot));
      } else {
        return Left(
            ServerFailure('No se encontró el artículo con ID: $articleId'));
      }
    } catch (e) {
      return Left(ServerFailure('Error al obtener el artículo: $e'));
    }
  }

  @override
  Future<Either<Failure, ArticleEntity>> updateArticle(
    ArticleEntity article, {
    File? coverImageFile,
    // sectionImageFiles no es necesario, la lógica se basa en las rutas de los ficheros en la entidad
  }) async {
    try {
      ArticleEntity articleToUpdate = article;

      // 1. Handle cover image update
      if (coverImageFile != null) {
        final uploadResult = await CloudinaryService.uploadImage(
          imageFile: coverImageFile,
          imageType: CloudinaryImageType.articleCover,
        );
        if (!uploadResult.success) {
          return Left(ServerFailure(uploadResult.error ??
              'Error al subir la nueva imagen de portada.'));
        }

        // Delete old cover image if it exists and is different
        // Only delete if the old URL is different from the new one
        // and it's an actual Cloudinary URL (starts with http)
        if (article.coverUrl.isNotEmpty &&
            article.coverUrl.startsWith('http') &&
            article.coverUrl != uploadResult.secureUrl) {
          await CloudinaryService.deleteImage(article.coverUrl);
        }

        articleToUpdate =
            articleToUpdate.copyWith(coverUrl: uploadResult.secureUrl);
      }

      // 2. Handle section images update
      final List<ArticleSection> updatedSections = [];
      for (final section in articleToUpdate.sections) {
        if (section.imageUrl != null && !section.imageUrl!.startsWith('http')) {
          // This is a new image file (path, not URL)
          final sectionImageFile = File(section.imageUrl!);
          final sectionUploadResult = await CloudinaryService.uploadImage(
            imageFile: sectionImageFile,
            imageType: CloudinaryImageType.articleSection,
          );
          if (!sectionUploadResult.success) {
            return Left(ServerFailure(sectionUploadResult.error ??
                'Error al subir imagen de sección.'));
          }
          // If there was an old image URL, delete it
          final oldSection = article.sections
              .firstWhere((s) => s.id == section.id, orElse: () => section);
          if (oldSection.imageUrl != null &&
              oldSection.imageUrl!.startsWith('http') &&
              oldSection.imageUrl != sectionUploadResult.secureUrl) {
            await CloudinaryService.deleteImage(oldSection.imageUrl!);
          }
          updatedSections
              .add(section.copyWith(imageUrl: sectionUploadResult.secureUrl));
        } else {
          updatedSections.add(section); // Keep existing image URL or null
        }
      }
      articleToUpdate = articleToUpdate.copyWith(sections: updatedSections);

      // 3. Update the article in Firestore
      final articleModel = ArticleModel.fromEntity(articleToUpdate);
      await firestore
          .collection('articles')
          .doc(article.id)
          .update(articleModel.toFirestore());

      return Right(articleToUpdate);
    } catch (e) {
      return Left(ServerFailure('Error al actualizar el artículo: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteArticle(
    String articleId, {
    String? coverUrl,
    List<String>? sectionImages,
  }) async {
    try {
      // Delete cover image from Cloudinary
      if (coverUrl != null && coverUrl.isNotEmpty) {
        await CloudinaryService.deleteImage(coverUrl);
      }

      // Delete section images from Cloudinary
      if (sectionImages != null && sectionImages.isNotEmpty) {
        for (final imageUrl in sectionImages) {
          if (imageUrl.isNotEmpty) {
            await CloudinaryService.deleteImage(imageUrl);
          }
        }
      }

      await firestore.collection('articles').doc(articleId).delete();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Error al borrar el artículo: $e'));
    }
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    try {
      final snapshot =
          await firestore.collection('categories').orderBy('order').get();
      final categories = snapshot.docs
          .map((doc) => CategoryModel.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
      return Right(categories);
    } catch (e) {
      return Left(ServerFailure('Error al obtener las categorías: $e'));
    }
  }

  @override
  Future<Either<Failure, List<SubcategoryEntity>>> getSubcategories(
      String categoryId) async {
    try {
      final snapshot = await firestore
          .collection('subcategories')
          .where('categoryId', isEqualTo: categoryId)
          .orderBy('order')
          .get();
      final subcategories = snapshot.docs
          .map((doc) => SubcategoryModel.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
      return Right(subcategories);
    } catch (e) {
      return Left(ServerFailure('Error al obtener las subcategorías: $e'));
    }
  }
}
