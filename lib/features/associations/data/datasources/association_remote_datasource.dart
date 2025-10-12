import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conectasoc/core/errors/exceptions.dart';
import 'package:conectasoc/features/associations/data/models/association_model.dart';

abstract class AssociationRemoteDataSource {
  Future<List<AssociationModel>> getAllAssociations();
  Future<AssociationModel> getAssociationById(String id);
  Future<AssociationModel> updateAssociation(
      AssociationModel association, String? newLogoUrl);
  Future<AssociationModel> createAssociation({
    required String shortName,
    required String longName,
    required String email,
    required String contactName,
    required String phone,
    required String creatorId,
  });
  Future<void> deleteAssociation(String associationId);
}

class AssociationRemoteDataSourceImpl implements AssociationRemoteDataSource {
  final FirebaseFirestore firestore;

  AssociationRemoteDataSourceImpl({
    required this.firestore,
  });

  @override
  Future<List<AssociationModel>> getAllAssociations() async {
    try {
      final snapshot = await firestore
          .collection('associations')
          .where('dateDeleted', isNull: true)
          .orderBy('shortName')
          .get();

      return snapshot.docs
          .map((doc) => AssociationModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException('Error obteniendo asociaciones: $e');
    }
  }

  @override
  Future<AssociationModel> getAssociationById(String id) async {
    try {
      final doc = await firestore.collection('associations').doc(id).get();
      if (!doc.exists) {
        throw ServerException('Asociación no encontrada.');
      }
      return AssociationModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException('Error obteniendo la asociación: $e');
    }
  }

  @override
  Future<AssociationModel> updateAssociation(
      AssociationModel association, String? newLogoUrl) async {
    try {
      final updatedAssociation = association.copyWith(
        logoUrl: newLogoUrl ?? association.logoUrl,
      );
      final dataToUpdate = updatedAssociation.toFirestore();
      // Usar el timestamp del servidor para la actualización
      dataToUpdate['dateUpdated'] = FieldValue.serverTimestamp();

      await firestore
          .collection('associations')
          .doc(association.id)
          .update(dataToUpdate);

      // After updating, we fetch the document again to get the most recent data,
      // including the server-generated 'dateUpdated'.
      final updatedDoc =
          await firestore.collection('associations').doc(association.id).get();
      return AssociationModel.fromFirestore(updatedDoc);
    } catch (e) {
      throw ServerException(
          'Error al actualizar la asociación: ${e.toString()}');
    }
  }

  @override
  Future<AssociationModel> createAssociation({
    required String shortName,
    required String longName,
    required String email,
    required String contactName,
    required String phone,
    required String creatorId,
  }) async {
    try {
      // Verificar que no exista una con el mismo nombre corto
      final existing = await firestore
          .collection('associations')
          .where('shortName', isEqualTo: shortName)
          .get();

      if (existing.docs.isNotEmpty) {
        throw ServerException(
            'Ya existe una asociación con el nombre corto "$shortName"');
      }

      final docRef = firestore.collection('associations').doc();
      final newAssociationData = {
        'shortName': shortName,
        'longName': longName,
        'email': email,
        'contactName': contactName,
        'phone': phone,
        'creatorId': creatorId,
        'logoUrl': '', // Inicializar el logo como una cadena vacía
        'dateCreated': FieldValue.serverTimestamp(),
        'dateUpdated': FieldValue.serverTimestamp(),
        'dateDeleted': null, // Asegurar que el campo existe para las consultas
      };

      await docRef.set(newAssociationData);
      final newDoc = await docRef.get();
      return AssociationModel.fromFirestore(newDoc);
    } on ServerException {
      rethrow; // Relanzar la excepción específica
    } catch (e) {
      throw ServerException(
          'Error inesperado al crear la asociación: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteAssociation(String associationId) async {
    try {
      // 1. Verificar si algún usuario pertenece a esta asociación.
      final usersSnapshot = await firestore
          .collection('users')
          .where('associationIds', arrayContains: associationId)
          .limit(1)
          .get();

      if (usersSnapshot.docs.isNotEmpty) {
        throw ServerException('associationHasUsersError');
      }

      // 2. Si no hay usuarios, realizar un borrado lógico.
      await firestore.collection('associations').doc(associationId).update({
        'dateDeleted': FieldValue.serverTimestamp(),
      });
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Error al borrar la asociación: ${e.toString()}');
    }
  }
}
