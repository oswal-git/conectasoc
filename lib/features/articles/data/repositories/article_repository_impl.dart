import 'dart:typed_data';

import 'package:conectasoc/core/utils/formatters.dart';
import 'package:conectasoc/features/articles/domain/entities/entities.dart';
import 'package:conectasoc/features/articles/presentation/bloc/edit/article_edit_bloc.dart'; // Importamos la constante
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conectasoc/core/constants/cloudinary_config.dart';
import 'package:conectasoc/core/errors/failures.dart';
import 'package:conectasoc/core/errors/exceptions.dart';
import 'package:conectasoc/features/articles/data/models/models.dart';
import 'package:conectasoc/features/articles/domain/repositories/article_repository.dart';
import 'package:conectasoc/features/auth/domain/entities/entities.dart';
import 'package:conectasoc/features/users/domain/entities/entities.dart';
import 'package:conectasoc/services/cloudinary_service.dart';
import 'package:dartz/dartz.dart' hide Tuple2;
import 'package:uuid/uuid.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final FirebaseFirestore firestore;

  // Caché interna para navegación fluida
  final Map<String, ArticleEntity> _articleCache = {};

  ArticleRepositoryImpl({required this.firestore});

  @override
  Future<
          Either<Failure,
              Tuple2<List<ArticleEntity>, DocumentSnapshot<Object?>?>>>
      getArticles({
    IUser? user,
    bool isEditMode = false,
    String? categoryId,
    String? subcategoryId,
    String? searchTerm,
    DocumentSnapshot<Object?>? lastDocument,
    int limit = 20,
  }) async {
    try {
      Query query = firestore.collection('articles');

      // 1. Filtrado por permisos y visibilidad
      debugPrint(
          '${fechaD('🕵️‍♀️')} DEBUG: ArticleRepo.getArticles - isEditMode: $isEditMode, userLoggedIn: ${user != null}, isSuper: ${user?.isSuperAdmin}, canEdit: ${user?.canEditContent}');
      if (isEditMode && user != null && user.canEditContent) {
        // Modo Edición:
        // - Superadmin: Ve todo (no se aplica filtro de assocId ni userId).
        // - Admin: Ve todo de sus asociaciones.
        // - Editor: Ve SOLO lo suyo de sus asociaciones.

        if (!user.isSuperAdmin) {
          // Admin/Editor ven solo los de su asociación.
          final userAssociationIds = user.associationIds;
          debugPrint(
              '${fechaD('🕵️')} DEBUG: ArticleRepo - Admin/Editor filtering by Assocs: $userAssociationIds');
          query = query.where('assocId', whereIn: userAssociationIds);

          if (user is UserEntity) {
            final isAnyAdmin =
                user.memberships.values.any((role) => role == 'admin');
            if (!isAnyAdmin) {
              debugPrint(
                  '${fechaD('🕵️')} DEBUG: ArticleRepo - Editor filtering by userId: ${user.uid}');
              query = query.where('userId', isEqualTo: user.uid);
            }
          }
        } else {
          debugPrint(
              '${fechaD('🕵️')} DEBUG: ArticleRepo - Superadmin in Edit Mode. FETCHING EVERYTHING.');
        }
      } else {
        // Modo Lectura:
        // - Superadmin: Ve todo (para verificar carga).
        // - Autenticado: Ve lo de sus asociaciones + públicos (genéricos).
        // - Anónimo: Ve públicos (genéricos).

        query = query.where('status', isEqualTo: ArticleStatus.publicado.value);

        // Filtrar por asociación
        if (user != null && user.isSuperAdmin) {
          // Superadmin en modo lectura ve todo, no aplicamos filtro de assocId.
        } else {
          switch (user) {
            case null: // No logueado
              query = query.where('assocId', isEqualTo: '');
              break;
            case LocalUserEntity localUser: // Usuario local (solo lectura)
              final userAssociationIds = localUser.associationIds;
              final assocIds = ['', ...userAssociationIds];
              query = query.where('assocId', whereIn: assocIds);
              break;
            case UserEntity authUser: // Usuario autenticado normal
              final userAssociationIds = authUser.associationIds;
              final assocIds = ['', ...userAssociationIds];
              query = query.where('assocId', whereIn: assocIds);
              break;
          }
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
          // TODO: Una vez que todos los documentos tengan 'modifiedAt',
          // volver a usar 'isEditMode ? "modifiedAt" : "publishDate"'.
          // Por ahora usamos 'createdAt' para asegurar que nada quede oculto por falta de campo.
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();
      debugPrint(
          '${fechaD('🕵️')} DEBUG: ArticleRepo - QUERY EXECUTED. Documents found: ${snapshot.docs.length}');

      final articles = snapshot.docs
          .map((doc) => ArticleModel.fromFirestore(doc))
          .where((article) {
        // En modo edición, no se deben aplicar filtros de fecha. Se muestran todos.
        if (isEditMode) {
          return true;
        }

        // Filtro de expiración en el cliente
        final now = DateTime.now();
        final isEffective = article.effectiveDate.isBefore(now) ||
            article.effectiveDate.isAtSameMomentAs(now);
        final isNotExpired = article.expirationDate == null ||
            article.expirationDate!.isAfter(now);

        return isEffective && isNotExpired;
      }).toList();

      // Get the last document for the next page's cursor
      final DocumentSnapshot<Object?>? newLastDocument =
          snapshot.docs.isNotEmpty ? snapshot.docs.last : null;

      return Right(Tuple2(articles, newLastDocument));
    } catch (e) {
      return Left(ServerFailure('Error al obtener los artículos: $e'));
    }
  }

  @override
  Future<Either<Failure, ArticleEntity>> createArticle(
    ArticleEntity article,
    Uint8List? coverImageBytes, {
    Map<String, Uint8List> sectionImageBytes = const {},
  }) async {
    String? uploadedCoverUrl;
    final List<String> uploadedSectionImageUrls = [];
    const uuid = Uuid();
    final bool hasCoverImage =
        coverImageBytes != null && coverImageBytes != kClearImageBytes;

    try {
      // 1. Subir imagen de portada a Cloudinary si existe
      if (hasCoverImage) {
        debugPrint(
            '${fechaD('🧪')} ArticleRepositoryImpl: createArticle ✅ hasCoverImage');
        final uploadResult = await CloudinaryService.uploadImageBytes(
          imageBytes: coverImageBytes,
          filename: uuid.v4(), // Generate a unique filename
          imageType: CloudinaryImageType.articleCover,
        );

        if (!uploadResult.success) {
          debugPrint(
              '${fechaD('🧪')} ArticleRepositoryImpl: createArticle ✅ Error al subir la imagen de portada.');
          return Left(ServerFailure(
              uploadResult.error ?? 'Error al subir la imagen de portada.'));
        }
        uploadedCoverUrl = uploadResult.secureUrl;
      } else {
        uploadedCoverUrl = ''; // Set to empty string if no cover image
      }

      // 2. Subir imágenes de las secciones
      final List<ArticleSection> sectionsWithUploadedImages = [];
      debugPrint(
          '${fechaD('🧪')} ArticleRepositoryImpl: createArticle ✅ Subir imágenes de las secciones');
      for (final section in article.sections) {
        if (sectionImageBytes.containsKey(section.id)) {
          final bytes = sectionImageBytes[section.id]!;
          final sectionUpload = await CloudinaryService.uploadImageBytes(
            imageBytes: bytes,
            imageType: CloudinaryImageType.articleSection,
            filename: uuid.v4(),
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
          coverUrl: uploadedCoverUrl ?? '',
          sections: sectionsWithUploadedImages);
      final articleModel = ArticleModel.fromEntity(articleWithCoverAndSections);

      // 3. Escribir en Firestore usando un batch para asegurar la consistencia
      final batch = firestore.batch();
      final docRef = firestore.collection('articles').doc();

      // Guardar documento principal (ligero)
      final mainData = articleModel.toFirestore();
      mainData['createdAt'] = FieldValue.serverTimestamp();
      mainData['modifiedAt'] = FieldValue.serverTimestamp();
      batch.set(docRef, mainData);

      // Guardar secciones en subcolección
      for (final section in articleModel.sectionsToFirestore()) {
        final sectionId = section['id'] as String;
        final sectionDocRef = docRef
            .collection('sections')
            .doc(sectionId.isEmpty ? null : sectionId);
        batch.set(sectionDocRef, section);
      }

      // Guardar información adicional en subcolección
      // final infoData = articleModel.additionalInfoToFirestore();
      // batch.set(docRef.collection('additionalInfo').doc('info'), infoData);

      await batch.commit();

      // 4. Devolver la entidad completa con el ID asignado
      return Right(articleModel.copyWith(id: docRef.id));
    } catch (e) {
      debugPrint(
          '${fechaD('🧪')} ArticleRepositoryImpl: createArticle ✅ Error al crear el artículo: $e');
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
    String articleId, {
    bool forceRefresh = false,
  }) async {
    try {
      // Servir desde caché solo si no se fuerza refresco.
      if (!forceRefresh && _articleCache.containsKey(articleId)) {
        debugPrint(
            '${fechaD('🧠')} ArticleRepositoryImpl: getArticleById -> Servido desde CACHÉ: $articleId');
        return Right(_articleCache[articleId]!);
      }

      if (forceRefresh) {
        debugPrint(
            '🔄 ArticleRepositoryImpl: getArticleById -> forceRefresh, omitiendo caché: $articleId');
        _articleCache.remove(articleId);
      }

      final docRef = firestore.collection('articles').doc(articleId);

      // Paralelizar las 3 lecturas de Firestore en lugar de hacerlas secuencialmente.
      // Reduce la latencia de (t1 + t2 + t3) a max(t1, t2, t3).
      final results = await Future.wait([
        docRef.get(),
        docRef.collection('sections').orderBy('order').get(),
        // docRef.collection('additionalInfo').doc('info').get(),
      ]);

      final docSnapshot = results[0] as DocumentSnapshot;
      final sectionsSnapshot = results[1] as QuerySnapshot;
      // final additionalInfoSnapshot = results[2] as DocumentSnapshot;

      if (docSnapshot.exists) {
        final article = ArticleModel.fromFirestore(
          docSnapshot,
          sectionsDocs: sectionsSnapshot.docs,
          // additionalInfoDoc: additionalInfoSnapshot,
        );

        // Guardar en caché
        _articleCache[articleId] = article;

        return Right(article);
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
    Uint8List? newCoverImageBytes,
    Map<String, Uint8List> newSectionImageBytes = const {},
    List<String> imagesToDelete = const [],
    DateTime? expectedModifiedAt,
  }) async {
    try {
      ArticleEntity articleToUpdate = article;
      const uuid = Uuid();

      // 1. Handle cover image update
      if (newCoverImageBytes != null &&
          newCoverImageBytes != kClearImageBytes) {
        // Caso 1: El usuario ha seleccionado una nueva imagen.
        final uploadResult = await CloudinaryService.uploadImageBytes(
          imageBytes: newCoverImageBytes,
          filename: article.id,
          imageType: CloudinaryImageType.articleCover,
        );
        if (!uploadResult.success) {
          return Left(ServerFailure(uploadResult.error ??
              'Error al subir la nueva imagen de portada.'));
        }
        // Borrar la imagen antigua si existe y es diferente a la nueva.
        if (article.coverUrl.isNotEmpty &&
            article.coverUrl.startsWith('http') &&
            article.coverUrl != uploadResult.secureUrl) {
          await CloudinaryService.deleteImage(article.coverUrl);
        }
        articleToUpdate =
            articleToUpdate.copyWith(coverUrl: uploadResult.secureUrl);
      } else if (newCoverImageBytes == kClearImageBytes) {
        // Caso 2: El usuario ha borrado explícitamente la imagen existente.
        // newCoverImageBytes es kClearImageBytes.
        // La coverUrl del artículo original (article.coverUrl) aún contiene la URL antigua
        // porque el BLoC no la actualiza hasta que se guarda.

        // Borramos la imagen antigua de Cloudinary.
        if (article.coverUrl.startsWith('http')) {
          await CloudinaryService.deleteImage(article.coverUrl);
        }
        // Actualizamos la URL a una cadena vacía.
        articleToUpdate = articleToUpdate.copyWith(coverUrl: '');
      }
      // Caso 3: newCoverImageBytes es null.
      // Esto significa que el usuario no ha tocado la imagen.
      // En este caso, articleToUpdate.coverUrl ya tiene el valor correcto (la URL original),
      // por lo que no se necesita ninguna acción.

      // Borrar imágenes marcadas para eliminación (de portada o secciones)
      for (final url in imagesToDelete) {
        await CloudinaryService.deleteImage(url);
      }

      // 2. Handle section image updates
      final List<ArticleSection> updatedSections = [];
      for (final section in articleToUpdate.sections) {
        if (newSectionImageBytes.containsKey(section.id)) {
          final bytes = newSectionImageBytes[section.id]!;
          final sectionUpload = await CloudinaryService.uploadImageBytes(
            imageBytes: bytes,
            imageType: CloudinaryImageType.articleSection,
            filename: uuid.v4(),
          );

          if (!sectionUpload.success || sectionUpload.secureUrl == null) {
            return Left(ServerFailure(sectionUpload.error ??
                'Error al subir imagen de sección o URL nula.'));
          }

          // Borrar la imagen antigua de la sección si existía.
          if (section.imageUrl != null &&
              section.imageUrl!.isNotEmpty &&
              section.imageUrl!.startsWith('http')) {
            await CloudinaryService.deleteImage(section.imageUrl!);
          }

          updatedSections
              .add(section.copyWith(imageUrl: sectionUpload.secureUrl!));
        } else {
          updatedSections.add(section);
        }
      }

      // Si hubo cambios en las secciones, actualizamos el artículo.
      if (updatedSections.isNotEmpty) {
        articleToUpdate = articleToUpdate.copyWith(sections: updatedSections);
      }

      // 3. Update the article in Firestore using a transaction for concurrency control
      await firestore.runTransaction((transaction) async {
        final docRef = firestore.collection('articles').doc(article.id);
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw ServerException('El artículo no existe.');
        }

        if (expectedModifiedAt != null) {
          final currentData = snapshot.data() as Map<String, dynamic>;
          final currentModifiedAt =
              (currentData['modifiedAt'] as Timestamp).toDate();

          // Comparamos permitiendo una pequeña diferencia por la precisión de Firestore
          // Relajamos a 500ms para evitar problemas de micro-discrepancias entre raíz y subcolecciones
          if (currentModifiedAt
                  .difference(expectedModifiedAt)
                  .inMilliseconds
                  .abs() >
              500) {
            debugPrint(
                '${fechaD('💥')} ArticleRepositoryImpl -> updateArticle: currentModifiedAt  = $currentModifiedAt');
            debugPrint(
                '${fechaD('💥')} ArticleRepositoryImpl -> updateArticle: expectedModifiedAt = $expectedModifiedAt');
            throw ConcurrencyException();
          }
        }

        final articleModel = ArticleModel.fromEntity(articleToUpdate);
        final dataToUpdate = articleModel.toFirestore();

        // Sincronizamos modifiedAt en la raíz con el servidor
        dataToUpdate['modifiedAt'] = FieldValue.serverTimestamp();

        transaction.update(docRef, dataToUpdate);

        // Actualizar secciones
        final sectionsRef = docRef.collection('sections');
        for (final section in articleModel.sectionsToFirestore()) {
          final sId = section['id'] as String;
          transaction.set(sectionsRef.doc(sId.isEmpty ? null : sId), section);
        }

        // Actualizar additionalInfo
        // final infoDoc = articleModel.additionalInfoToFirestore();
        // infoDoc['modifiedAt'] = FieldValue.serverTimestamp();
        // transaction.set(docRef.collection('additionalInfo').doc('info'),
        //     infoDoc, SetOptions(merge: true));
      });

      // Limpiar caché para forzar recarga fresca en la próxima lectura
      _articleCache.remove(article.id);

      // Recargamos el artículo completo para devolver la entidad actualizada
      final refreshed = await getArticleById(article.id);
      return refreshed.fold(
        (failure) => Left(failure),
        (updatedArticle) => Right(updatedArticle),
      );
    } on ConcurrencyException catch (_) {
      return Left(ConcurrencyFailure());
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

      // 3. Delete sections subcollection
      final articleRef = firestore.collection('articles').doc(articleId);
      final sectionsSnapshot = await articleRef.collection('sections').get();
      for (final doc in sectionsSnapshot.docs) {
        await doc.reference.delete();
      }

      // 4. Delete additional info
      await articleRef.collection('additionalInfo').doc('info').delete();

      // 5. Delete main document
      await articleRef.delete();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Error al borrar el artículo: $e'));
    }
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories(
      {String? assocId}) async {
    try {
      Query query = firestore.collection('categories').orderBy('order');

      if (assocId != null) {
        query = query.where('assocId', whereIn: ['system', assocId]);
      } else {
        query = query.where('isSystem', isEqualTo: true);
      }

      final snapshot = await query.get();
      final categories = snapshot.docs
          .map((doc) => CategoryModel.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>))
          .map((model) => model.toEntity())
          .toList();
      return Right(categories);
    } catch (e) {
      debugPrint(
          '${fechaD('🗑️')} ArticleRepositoryImpl: getCategories ➡️ EXCEPTION: $e');
      return Left(ServerFailure('Error al obtener las categorías: $e'));
    }
  }

  @override
  Future<Either<Failure, List<SubcategoryEntity>>> getSubcategories(
      String categoryId,
      {String? assocId}) async {
    try {
      Query query = firestore
          .collection('subcategories')
          .where('categoryId', isEqualTo: categoryId);

      if (assocId != null) {
        query = query.where('assocId', whereIn: ['system', assocId]);
      } else {
        query = query.where('isSystem', isEqualTo: true);
      }

      final snapshot = await query.get();
      final subcategories = snapshot.docs
          .map((doc) => SubcategoryModel.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>))
          .map((model) => model.toEntity())
          .toList();
      // Ordenar en el cliente para evitar la necesidad de un índice compuesto
      subcategories.sort((a, b) => a.order.compareTo(b.order));
      return Right(subcategories);
    } catch (e) {
      debugPrint(
          '${fechaD('🗑️')} ArticleRepositoryImpl: getSubcategories ➡️ EXCEPTION: $e');
      return Left(ServerFailure('Error al obtener las subcategorías: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ArticleEntity>>> getArticlesForNotification({
    required DateTime lastNotified,
    required List<String> associationIds,
  }) async {
    try {
      debugPrint(
          '${fechaD('👌')} ArticleRepositoryImpl -> getArticlesForNotification: lastNotified = $lastNotified');
      debugPrint(
          '${fechaD('👌')} ArticleRepositoryImpl -> getArticlesForNotification: associationIds = $associationIds');
      // 1. Filtrar artículos publicados
      Query query = firestore
          .collection('articles')
          .where('status', isEqualTo: ArticleStatus.publicado.value);

      // 2. Filtrar por asociaciones del usuario
      final assocIds = ['', ...associationIds];
      query = query.where('assocId', whereIn: assocIds);

      // 3. Filtrar artículos cuya fechaNotificacion sea posterior a la última vez que el usuario fue notificado
      query = query
          .where('fechaNotificacion',
              isGreaterThan: Timestamp.fromDate(lastNotified))
          .orderBy('fechaNotificacion', descending: true);

      final snapshot = await query.get();
      debugPrint(
          '${fechaD('👌')} ArticleRepositoryImpl -> getArticlesForNotification: snapshot = $snapshot');

      final articles = snapshot.docs
          .map((doc) => ArticleModel.fromFirestore(doc))
          .where((article) {
        // Filtro adicional para asegurar que la fecha es realmente mayor
        final articleNotifDate = article.fechaNotificacion;
        if (articleNotifDate == null) {
          debugPrint('⚠️ Article ${article.id} has null fechaNotificacion');
          return false;
        }
        final isAfter = articleNotifDate.isAfter(lastNotified);
        if (!isAfter) {
          debugPrint(
              '⏭️ Skipping article ${article.id}: notifDate=$articleNotifDate <= lastNotified=$lastNotified');
        }
        return isAfter;
      }).toList();

      debugPrint(
          '${fechaD('👌')} ArticleRepositoryImpl -> getArticlesForNotification: articles = $articles');

      return Right(articles);
    } catch (e) {
      debugPrint(
          '${fechaD('🚨')} ArticleRepositoryImpl: getArticlesForNotification ➡️ EXCEPTION: $e');
      return Left(
          ServerFailure('Error al obtener artículos para notificación: $e'));
    }
  }

  @override
  Future<void> prefetchArticles(List<String> articleIds) async {
    for (final id in articleIds) {
      if (!_articleCache.containsKey(id)) {
        debugPrint(
            '${fechaD('🚀')} ArticleRepositoryImpl: PREFETCHING article $id');
        // No esperamos (await) individualmente para que sea paralelo,
        // pero lo hacemos de forma que no bloquee.
        getArticleById(id);
      }
    }
  }
}
