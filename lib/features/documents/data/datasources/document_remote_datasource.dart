import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conectasoc/features/documents/data/models/document_model.dart';
import 'package:conectasoc/features/documents/domain/entities/entities.dart';
import 'package:conectasoc/services/cloudinary_document_service.dart';
import 'package:flutter/material.dart';

/// Remote data source for documents using Firestore
abstract class DocumentRemoteDataSource {
  /// Create a new document in Firestore
  Future<DocumentModel> createDocument(DocumentModel document);

  /// Get document by ID
  Future<DocumentModel> getDocumentById(String documentId);

  /// Get documents by association
  Future<List<DocumentEntity>> getDocumentsByAssociation({
    String? associationId,
    String? categoryId,
    String? subcategoryId,
    // ✨ Parámetros para filtrar por readScope
    required bool isSuperAdmin,
    String? userAssociationId,
    String? userRole,
  });

  /// Search documents
  Future<List<DocumentEntity>> searchDocuments({
    required String query,
    String? associationId,
    String? categoryId,
    String? subcategoryId,
    required bool isSuperAdmin,
    String? userAssociationId,
    String? userRole,
  });

  /// Update document
  Future<DocumentModel> updateDocument(DocumentModel document);

  /// Delete document
  Future<void> deleteDocument(String documentId);

  /// Get documents by category
  Future<List<DocumentModel>> getDocumentsByCategory({
    required String categoryId,
    String? associationId,
  });

  /// Get documents by subcategory
  Future<List<DocumentModel>> getDocumentsBySubcategory({
    required String subcategoryId,
    String? associationId,
  });

  Future<bool> isDocumentLinked(String documentId);
}

/// Implementation of DocumentRemoteDataSource using Firestore
class DocumentRemoteDataSourceImpl implements DocumentRemoteDataSource {
  final FirebaseFirestore firestore;

  DocumentRemoteDataSourceImpl({required this.firestore});

  @override
  Future<DocumentModel> createDocument(DocumentModel document) async {
    try {
      final docRef = await firestore.collection('documents').add(
            document.toFirestore(),
          );

      // Return document with the generated ID
      return document.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Error creating document: $e');
    }
  }

  @override
  Future<DocumentModel> getDocumentById(String documentId) async {
    try {
      final doc = await firestore.collection('documents').doc(documentId).get();

      if (!doc.exists) {
        throw Exception('Document not found');
      }

      return DocumentModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Error getting document: $e');
    }
  }

  @override
  Future<List<DocumentEntity>> getDocumentsByAssociation({
    String? associationId,
    String? categoryId,
    String? subcategoryId,
    required bool isSuperAdmin,
    String? userAssociationId,
    String? userRole,
  }) async {
    try {
      Query query = firestore.collection('documents');

      // Si no es superadmin, filtrar por asociación
      if (!isSuperAdmin && associationId != null) {
        query = query.where('associationId', isEqualTo: associationId);
      }

      // Filtros adicionales
      if (categoryId != null && categoryId.isNotEmpty) {
        query = query.where('categoryId', isEqualTo: categoryId);
      }
      if (subcategoryId != null && subcategoryId.isNotEmpty) {
        query = query.where('subcategoryId', isEqualTo: subcategoryId);
      }

      // Ordenar por fecha de modificación (más recientes primero)
      query = query.orderBy('dateModification', descending: true);

      final snapshot = await query.get();

      final allDocuments = snapshot.docs
          .map((doc) => DocumentModel.fromFirestore(doc).toEntity())
          .toList();

      // ✨ Filtrar por readScope
      return _filterByReadScope(
        documents: allDocuments,
        isSuperAdmin: isSuperAdmin,
        userAssociationId: userAssociationId,
        userRole: userRole,
      );
    } catch (e) {
      throw Exception('Error getting documents by association: $e');
    }
  }

  @override
  Future<List<DocumentEntity>> searchDocuments({
    required String query,
    String? associationId,
    String? categoryId,
    String? subcategoryId,
    required bool isSuperAdmin,
    String? userAssociationId,
    String? userRole,
  }) async {
    try {
      // Primero obtenemos todos los documentos con filtros básicos
      final documents = await getDocumentsByAssociation(
        associationId: associationId,
        categoryId: categoryId,
        subcategoryId: subcategoryId,
        isSuperAdmin: isSuperAdmin,
        userAssociationId: userAssociationId,
        userRole: userRole,
      );

      // Búsqueda en memoria (Firestore no soporta búsqueda full-text bien)
      final lowerQuery = query.toLowerCase();
      return documents
          .where((doc) =>
              doc.descDoc.toLowerCase().contains(lowerQuery) ||
              doc.fileName.toLowerCase().contains(lowerQuery))
          .toList();
    } catch (e) {
      throw Exception('Error searching documents: $e');
    }
  }

  @override
  Future<DocumentModel> updateDocument(DocumentModel document) async {
    try {
      await firestore
          .collection('documents')
          .doc(document.id)
          .update(document.toFirestore());

      return document;
    } catch (e) {
      throw Exception('Error updating document: $e');
    }
  }

  @override
  Future<void> deleteDocument(String documentId) async {
    debugPrint('DocumentRemoteDataSourceImpl -> deleteDocument');
    try {
      // 1. Obtener el documento para tener el publicID y tipo
      final doc = await getDocumentById(documentId);
      final isPdf = doc.fileExtension.toLowerCase() == 'pdf';

      // 2. Borrar el documento principal de Cloudinary
      if (doc.publicId.isNotEmpty) {
        final docDeleted = await CloudinaryDocumentService.deleteDocument(
          doc.publicId,
          isPdf: isPdf,
        );
        debugPrint(
            'DocumentRemoteDataSourceImpl -> doc Cloudinary delete: $docDeleted (publicId: ${doc.publicId})');
      }

      // 3. Borrar el thumbnail de Cloudinary
      //    - Para PDF: el thumb es una transformación del mismo recurso image,
      //      no hay asset separado que borrar (ya fue borrado en el paso 2).
      //    - Para Office: el thumb es un asset independiente (resource_type=image)
      //      cuyo publicId se extrae de urlThumb.
      if (!isPdf) {
        final thumbPublicId = _extractPublicId(doc.urlThumb);
        debugPrint(
            'DocumentRemoteDataSourceImpl -> thumb publicId: $thumbPublicId (urlThumb: ${doc.urlThumb})');
        if (thumbPublicId != null && thumbPublicId.isNotEmpty) {
          final thumbDeleted = await CloudinaryDocumentService.deleteDocument(
            thumbPublicId,
            isPdf: true, // el thumb siempre es resource_type=image
          );
          debugPrint(
              'DocumentRemoteDataSourceImpl -> thumb Cloudinary delete: $thumbDeleted');
        }
      }

      // 4. Borrar de Firestore
      await firestore.collection('documents').doc(documentId).delete();
      debugPrint('DocumentRemoteDataSourceImpl -> deleteDocument Firestore ok');
    } catch (e) {
      debugPrint('DocumentRemoteDataSourceImpl -> Error deleting document: $e');
      throw Exception('Error deleting document: $e');
    }
  }

  /// Extrae el publicId de una URL de Cloudinary.
  /// https://res.cloudinary.com/cloud/image/upload/v123/folder/name.jpg → folder/name
  String? _extractPublicId(String url) {
    if (url.isEmpty) return null;
    try {
      const marker = '/upload/';
      final idx = url.indexOf(marker);
      if (idx == -1) return null;
      var after = url.substring(idx + marker.length);
      // Quitar versión si existe (v1234567890/)
      if (after.startsWith('v') && after.contains('/')) {
        final slashIdx = after.indexOf('/');
        if (int.tryParse(after.substring(1, slashIdx)) != null) {
          after = after.substring(slashIdx + 1);
        }
      }
      // Quitar extensión
      final dotIdx = after.lastIndexOf('.');
      if (dotIdx != -1) after = after.substring(0, dotIdx);
      return after.isEmpty ? null : after;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<DocumentModel>> getDocumentsByCategory({
    required String categoryId,
    String? associationId,
  }) async {
    try {
      Query query = firestore
          .collection('documents')
          .where('categoryId', isEqualTo: categoryId);

      if (associationId != null) {
        query = query.where('associationId', isEqualTo: associationId);
      }

      query = query.orderBy('dateModification', descending: true);

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => DocumentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error getting documents by category: $e');
    }
  }

  @override
  Future<List<DocumentModel>> getDocumentsBySubcategory({
    required String subcategoryId,
    String? associationId,
  }) async {
    try {
      Query query = firestore
          .collection('documents')
          .where('subcategoryId', isEqualTo: subcategoryId);

      if (associationId != null) {
        query = query.where('associationId', isEqualTo: associationId);
      }

      query = query.orderBy('dateModification', descending: true);

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => DocumentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error getting documents by subcategory: $e');
    }
  }

// ═══════════════════════════════════════════════════════════
  // ✨ Método para filtrar documentos por readScope
  // ═══════════════════════════════════════════════════════════

  List<DocumentEntity> _filterByReadScope({
    required List<DocumentEntity> documents,
    required bool isSuperAdmin,
    String? userAssociationId,
    String? userRole,
  }) {
    return documents.where((doc) {
      return doc.readScope.allowsAccessFor(
        isSuperAdmin: isSuperAdmin,
        userAssociationId: userAssociationId,
        documentAssociationId: doc.associationId,
        userRole: userRole,
      );
    }).toList();
  }

  // ─── SNIPPET para añadir a DocumentRemoteDataSource ───────────────────────────
//
// Añade este método a la clase DocumentRemoteDataSource existente en:
// lib/features/documents/data/datasources/document_remote_datasource.dart
//
// Requiere que FirebaseFirestore esté inyectado en el datasource (ya lo estará
// si los demás métodos usan Firestore).
//
// ─────────────────────────────────────────────────────────────────────────────

  /// Comprueba si el documento [documentId] está referenciado en algún artículo.
  ///
  /// Estrategia:
  /// 1. Query directa sobre el campo `documentLink.documentId` del artículo
  ///    (cubre el enlace a nivel de artículo completo).
  /// 2. Query sobre `sectionDocumentIds` — campo array desnormalizado que
  ///    contiene los documentId de todas las secciones del artículo.
  ///    → Si tu ArticleModel ya persiste este array, úsalo directamente.
  ///    → Si no existe aún, la query 1 cubre la mayoría de los casos y
  ///      puedes añadir la desnormalización en un segundo paso.
  ///
  /// Devuelve [true] si hay al menos un artículo que lo referencie.
  @override
  Future<bool> isDocumentLinked(String documentId) async {
    // ── Query 1: documentLink a nivel de artículo ─────────────────────────
    final rootQuery = await firestore
        .collection('articles')
        .where('documentLink.documentId', isEqualTo: documentId)
        .limit(1)
        .get();

    if (rootQuery.docs.isNotEmpty) return true;

    // ── Query 2: documentLink dentro de secciones ─────────────────────────
    // Firestore no permite filtrar dentro de arrays de maps directamente,
    // por lo que usamos un campo array desnormalizado `sectionDocumentIds`
    // que debe almacenarse al crear/editar artículos.
    //
    // Si el campo no existe aún en tus documentos, esta query devolverá
    // vacío sin errores (Firestore ignora documentos sin el campo).
    final sectionsQuery = await firestore
        .collection('articles')
        .where('sectionDocumentIds', arrayContains: documentId)
        .limit(1)
        .get();

    return sectionsQuery.docs.isNotEmpty;
  }
}
