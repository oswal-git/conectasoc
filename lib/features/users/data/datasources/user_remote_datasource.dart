// lib/features/users/data/datasources/user_remote_datasource.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conectasoc/core/errors/exceptions.dart';
import 'package:conectasoc/features/auth/data/models/models.dart';
import 'package:conectasoc/features/auth/domain/entities/entities.dart';
import 'package:conectasoc/features/users/domain/entities/entities.dart';

abstract class UserRemoteDataSource {
  Future<void> addMembership(String userId, String associationId, String role);
  Future<void> removeMembership(String userId, String associationId);
  Future<List<UserModel>> getUsersByAssociation(String associationId);
  Future<UserModel> getUserById(String userId);
  Future<List<UserModel>> getAllUsers();

  Future<void> updateUserDetails(
      UserEntity user, DateTime? expectedDateUpdated);
  Future<void> deleteUser(String userId);
  Future<ProfileEntity> updateUser(
      ProfileEntity user, String? newImageUrl, DateTime? expectedDateUpdated);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final FirebaseFirestore firestore;

  UserRemoteDataSourceImpl({required this.firestore});

  @override
  Future<void> addMembership(
      String userId, String associationId, String role) async {
    try {
      await firestore.collection('users').doc(userId).update({
        // Usar notación de punto para actualizar un campo dentro de un mapa
        'memberships.$associationId': role,
        // Añadir el ID al array de Ids de asociación para optimizar consultas
        'associationIds': FieldValue.arrayUnion([associationId]),
      });
    } on FirebaseException catch (e) {
      throw ServerException(
          'Error al unirse a la asociación: ${e.message ?? e.code}');
    } catch (e) {
      throw ServerException('Error inesperado al unirse a la asociación.');
    }
  }

  @override
  Future<void> removeMembership(String userId, String associationId) async {
    try {
      await firestore.collection('users').doc(userId).update({
        'memberships.$associationId': FieldValue.delete(),
        'associationIds': FieldValue.arrayRemove([associationId])
      });
    } on FirebaseException catch (e) {
      throw ServerException(
          'Error al abandonar la asociación: ${e.message ?? e.code}');
    } catch (e) {
      throw ServerException('Error inesperado al abandonar la asociación.');
    }
  }

  @override
  Future<List<UserModel>> getUsersByAssociation(String associationId) async {
    try {
      final snapshot = await firestore
          .collection('users')
          .where('associationIds', arrayContains: associationId)
          .get();

      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException(
          'Error obteniendo usuarios por asociación: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> getUserById(String userId) async {
    try {
      final docSnapshot = await firestore.collection('users').doc(userId).get();
      if (docSnapshot.exists) {
        return UserModel.fromFirestore(docSnapshot);
      } else {
        throw ServerException('Usuario no encontrado.');
      }
    } catch (e) {
      throw ServerException('Error obteniendo usuario por ID: ${e.toString()}');
    }
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    try {
      final snapshot = await firestore.collection('users').get();
      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException(
          'Error obteniendo todos los usuarios: ${e.toString()}');
    }
  }

  @override
  Future<void> updateUserDetails(
      UserEntity user, DateTime? expectedDateUpdated) async {
    try {
      await firestore.runTransaction((transaction) async {
        final userRef = firestore.collection('users').doc(user.uid);
        final snapshot = await transaction.get(userRef);

        if (!snapshot.exists) {
          throw ServerException('El usuario no existe.');
        }

        if (expectedDateUpdated != null) {
          final currentData = snapshot.data() as Map<String, dynamic>;
          final currentUpdated =
              (currentData['dateUpdated'] as Timestamp).toDate();

          if (currentUpdated
                  .difference(expectedDateUpdated)
                  .inMilliseconds
                  .abs() >
              100) {
            throw ConcurrencyException();
          }
        }

        final userModel = UserModel.fromEntity(user);
        final dataToUpdate = userModel.toFirestore();
        dataToUpdate['dateUpdated'] = FieldValue.serverTimestamp();

        transaction.update(userRef, dataToUpdate);
      });
    } on ConcurrencyException {
      rethrow;
    } catch (e) {
      throw ServerException('Error al actualizar los detalles del usuario: $e');
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      await firestore.collection('users').doc(userId).delete();
    } catch (e) {
      throw ServerException('Error al eliminar el usuario: $e');
    }
  }

  @override
  Future<ProfileEntity> updateUser(ProfileEntity user, String? newImageUrl,
      DateTime? expectedDateUpdated) async {
    try {
      final result = await firestore.runTransaction((transaction) async {
        final userRef = firestore.collection('users').doc(user.uid);
        final snapshot = await transaction.get(userRef);

        if (!snapshot.exists) {
          throw ServerException('El usuario no existe.');
        }

        if (expectedDateUpdated != null) {
          final currentData = snapshot.data() as Map<String, dynamic>;
          final currentUpdated =
              (currentData['dateUpdated'] as Timestamp).toDate();

          if (currentUpdated
                  .difference(expectedDateUpdated)
                  .inMilliseconds
                  .abs() >
              100) {
            throw ConcurrencyException();
          }
        }

        final Map<String, dynamic> dataToUpdate = {
          'firstName': user.name,
          'lastName': user.lastname,
          'phone': user.phone,
          'language': user.language,
          'dateUpdated': FieldValue.serverTimestamp(),
        };

        if (newImageUrl != null) {
          dataToUpdate['avatarUrl'] = newImageUrl;
        }

        transaction.update(userRef, dataToUpdate);
        return user.copyWith(photoUrl: newImageUrl ?? user.photoUrl);
      });

      return result;
    } on ConcurrencyException {
      rethrow;
    } catch (e) {
      throw ServerException('Error al actualizar el usuario: $e');
    }
  }
}
