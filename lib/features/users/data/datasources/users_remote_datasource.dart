// lib/features/users/data/datasources/user_remote_datasource.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conectasoc/core/errors/exceptions.dart';
import 'package:conectasoc/features/auth/data/models/models.dart';

abstract class UserRemoteDataSource {
  Future<void> addMembership(String userId, MembershipModel membership);
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
}
