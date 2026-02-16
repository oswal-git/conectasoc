import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conectasoc/features/documents/data/models/document_model.dart';

/// Remote data source for documents using Firestore
abstract class DocumentRemoteDataSource {
  /// Create a new document in Firestore
  Future<DocumentModel> createDocument(DocumentModel document);

  /// Get document by ID
  Future<DocumentModel> getDocumentById(String documentId);

  /// Get documents by association
  Future<List<DocumentModel>> getDocumentsByAssociation({
    String? associationId,
    String? categoryId,
    String? subcategoryId,
  });

  /// Search documents
  Future<List<DocumentModel>> searchDocuments({
    required String query,
    String? associationId,
    String? categoryId,
    String? subcategoryId,
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
      return document.copyWith(id: docRef.id) as DocumentModel;
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
  Future<List<DocumentModel>> getDocumentsByAssociation({
    String? associationId,
    String? categoryId,
    String? subcategoryId,
  }) async {
    try {
      Query query = firestore.collection('documents');

      // Filter by association (if not superadmin)
      if (associationId != null) {
        query = query.where('associationId', isEqualTo: associationId);
      }

      // Filter by category
      if (categoryId != null) {
        query = query.where('categoryId', isEqualTo: categoryId);
      }

      // Filter by subcategory
      if (subcategoryId != null) {
        query = query.where('subcategoryId', isEqualTo: subcategoryId);
      }

      // Order by most recent
      query = query.orderBy('dateModification', descending: true);

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => DocumentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error getting documents by association: $e');
    }
  }

  @override
  Future<List<DocumentModel>> searchDocuments({
    required String query,
    String? associationId,
    String? categoryId,
    String? subcategoryId,
  }) async {
    try {
      Query firestoreQuery = firestore.collection('documents');

      // Filter by association
      if (associationId != null) {
        firestoreQuery =
            firestoreQuery.where('associationId', isEqualTo: associationId);
      }

      // Filter by category
      if (categoryId != null) {
        firestoreQuery =
            firestoreQuery.where('categoryId', isEqualTo: categoryId);
      }

      // Filter by subcategory
      if (subcategoryId != null) {
        firestoreQuery =
            firestoreQuery.where('subcategoryId', isEqualTo: subcategoryId);
      }

      final snapshot = await firestoreQuery.get();

      // Filter by search text in memory (Firestore doesn't support full-text search well)
      final searchLower = query.toLowerCase();
      return snapshot.docs
          .map((doc) => DocumentModel.fromFirestore(doc))
          .where((document) =>
              document.descDoc.toLowerCase().contains(searchLower) ||
              document.fileName.toLowerCase().contains(searchLower))
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
    try {
      await firestore.collection('documents').doc(documentId).delete();
    } catch (e) {
      throw Exception('Error deleting document: $e');
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
}
