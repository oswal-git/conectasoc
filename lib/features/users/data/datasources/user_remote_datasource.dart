// lib/features/users/data/datasources/user_remote_datasource.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conectasoc/core/errors/exceptions.dart';
import 'package:conectasoc/features/auth/data/models/models.dart';
import 'package:conectasoc/features/users/domain/entities/profile_entity.dart';

abstract class UserRemoteDataSource {
  Future<void> addMembership(String userId, MembershipModel membership);

  Future<ProfileEntity> updateUser(ProfileEntity user, String? newImageUrl);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final FirebaseFirestore firestore;

  UserRemoteDataSourceImpl({required this.firestore});

  @override
  Future<void> addMembership(String userId, MembershipModel membership) async {
    try {
      await firestore.collection('users').doc(userId).update({
        'memberships': FieldValue.arrayUnion([membership.toMap()])
      });
    } on FirebaseException catch (e) {
      throw ServerException(
          'Error al unirse a la asociación: ${e.message ?? e.code}');
    } catch (e) {
      throw ServerException('Error inesperado al unirse a la asociación.');
    }
  }

  @override
  Future<ProfileEntity> updateUser(
      ProfileEntity user, String? newImageUrl) async {
    try {
      final userRef = firestore.collection('users').doc(user.uid);

      final Map<String, dynamic> dataToUpdate = {
        'firstName': user.name,
        'lastName': user.lastname,
        'phone': user.phone,
        'language': user.language,
        'dateUpdated': FieldValue.serverTimestamp(),
      };

      // Solo actualiza la URL de la foto si se proporcionó una nueva.
      if (newImageUrl != null) {
        dataToUpdate['avatarUrl'] = newImageUrl;
      }

      await userRef.update(dataToUpdate);

      // Devuelve la entidad actualizada, incluyendo la nueva URL si existe.
      return user.copyWith(
        photoUrl: newImageUrl ?? user.photoUrl,
      );
    } catch (e) {
      throw ServerException('Error al actualizar el usuario: $e');
    }
  }
}
