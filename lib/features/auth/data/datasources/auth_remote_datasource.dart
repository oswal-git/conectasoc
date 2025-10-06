// lib/features/auth/data/datasources/auth_remote_datasource.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conectasoc/core/errors/errors.dart';
import 'package:conectasoc/features/auth/data/models/models.dart';
import 'package:conectasoc/features/auth/domain/entities/entities.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;

abstract class AuthRemoteDataSource {
  Stream<firebase.User?> get authStateChanges;

  Future<UserModel?> getCurrentUser();
  Future<UserModel> signInWithEmail(String email, String password);
  Future<firebase.UserCredential> createFirebaseAuthUser(
      String email, String password);
  Future<UserModel> createUserDocument({
    required String uid,
    required String email,
    required String firstName,
    required String lastName,
    String? phone,
    required List<Map<String, dynamic>> memberships,
  });
  Future<void> signOut();
  Future<void> resetPasswordWithEmail(String email);
  Future<List<AssociationModel>> getAllAssociations();
  Future<void> removeMembership(String associationId, String role);
  Future<AssociationModel> createAssociation(AssociationModel association);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final firebase.FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  @override
  Stream<firebase.User?> get authStateChanges =>
      firebaseAuth.authStateChanges();

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) return null;

      final doc = await firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;

      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException('Error obteniendo usuario actual: $e');
    }
  }

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user?.uid;
      if (uid == null) {
        throw ServerException('No se pudo obtener el UID del usuario');
      }

      final doc = await firestore.collection('users').doc(uid).get();
      if (!doc.exists) {
        throw ServerException('Usuario no encontrado en Firestore');
      }

      // Actualizar último login
      await firestore.collection('users').doc(uid).update({
        'lastLoginDate': FieldValue.serverTimestamp(),
      });

      return UserModel.fromFirestore(doc);
    } on firebase.FirebaseAuthException catch (e) {
      throw ServerException(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw ServerException('Error en login: $e');
    }
  }

  @override
  Future<firebase.UserCredential> createFirebaseAuthUser(
      String email, String password) async {
    try {
      return await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on firebase.FirebaseAuthException catch (e) {
      throw ServerException(_getAuthErrorMessage(e.code));
    }
  }

  @override
  Future<UserModel> createUserDocument({
    required String uid,
    required String email,
    required String firstName,
    required String lastName,
    String? phone,
    required List<Map<String, dynamic>> memberships,
  }) async {
    try {
      // Crear documento en Firestore
      final now = DateTime.now();
      final userData = {
        'uid': uid,
        'memberships': memberships,
        'status': 'active', // from UserStatus enum
        'language': 'es',
        'timezone': null,
        'dateCreated': Timestamp.fromDate(now),
        'dateUpdated': Timestamp.fromDate(now),
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'avatarUrl': null,
        'authProvider': 'password',
        'notificationSettings': const NotificationSettings().toMap(),
        'stats': const {}, // Default empty map
      };

      await firestore.collection('users').doc(uid).set(userData);

      final doc = await firestore.collection('users').doc(uid).get();
      return UserModel.fromFirestore(doc);
    } catch (e) {
      // Si la creación del documento falla, es importante manejarlo.
      // El repositorio se encarga de borrar el usuario de Auth.
      throw ServerException('Error en registro: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      throw ServerException('Error cerrando sesión: $e');
    }
  }

  @override
  Future<void> resetPasswordWithEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase.FirebaseAuthException catch (e) {
      throw ServerException(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw ServerException('Error enviando email de recuperación: $e');
    }
  }

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
  Future<AssociationModel> createAssociation(
      AssociationModel association) async {
    try {
      // Verificar que no exista
      final existing = await firestore
          .collection('associations')
          .where('shortName', isEqualTo: association.shortName)
          .get();

      if (existing.docs.isNotEmpty) {
        throw ServerException('Ya existe una asociación con ese nombre');
      }

      final docRef = firestore.collection('associations').doc();
      // Crear nuevo modelo con el ID generado
      final newAssociation = AssociationModel(
        id: docRef.id,
        shortName: association.shortName,
        longName: association.longName,
        email: association.email,
        contactName: association.contactName,
        phone: association.phone,
        description: association.description,
        logoUrl: association.logoUrl ?? '',
        dateCreated: association.dateCreated,
        dateUpdated: association.dateUpdated,
        dateDeleted: association.dateDeleted,
      );

      await docRef.set(newAssociation.toFirestore());

      return newAssociation;
    } catch (e) {
      throw ServerException('Error creando asociación: $e');
    }
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Usuario no encontrado';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'email-already-in-use':
        return 'El email ya está registrado';
      case 'invalid-email':
        return 'Email inválido';
      case 'weak-password':
        return 'Contraseña demasiado débil';
      case 'user-disabled':
        return 'Usuario deshabilitado';
      case 'too-many-requests':
        return 'Demasiados intentos. Intente más tarde';
      default:
        return 'Error de autenticación: $code';
    }
  }

  @override
  Future<void> removeMembership(String associationId, String role) async {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw ServerException('Usuario no autenticado');
    }

    try {
      await firestore.collection('users').doc(user.uid).update({
        'memberships': FieldValue.arrayRemove([
          {
            'associationId': associationId,
            'role': role,
          }
        ])
      });
    } catch (e) {
      throw ServerException('Error al eliminar la membresía: $e');
    }
  }
}
