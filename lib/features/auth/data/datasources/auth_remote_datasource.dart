// lib/features/auth/data/datasources/auth_remote_datasource.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conectasoc/core/errors/errors.dart';
import 'package:conectasoc/features/auth/data/models/models.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;

abstract class AuthRemoteDataSource {
  Stream<firebase.User?> get authStateChanges;

  Future<UserModel?> getCurrentUser();
  Future<UserModel> signInWithEmail(String email, String password);
  Future<firebase.UserCredential> createFirebaseAuthUser(
      String email, String password);
  Future<void> signOut();
  Future<void> resetPasswordWithEmail(String email);
  Future<void> createUserDocument(UserModel user);
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

      return UserModel.fromFirestore(doc, isEmailVerified: user.emailVerified);
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

      return UserModel.fromFirestore(doc,
          isEmailVerified: credential.user!.emailVerified);
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
  Future<void> createUserDocument(UserModel user) async {
    try {
      // Convertir el modelo a un mapa de Firestore y guardarlo.
      await firestore.collection('users').doc(user.uid).set(user.toFirestore());
    } catch (e) {
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
}
