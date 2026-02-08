// lib/features/auth/data/datasources/auth_remote_datasource.dart

// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conectasoc/core/errors/errors.dart';
import 'package:conectasoc/features/auth/data/models/models.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;

abstract class AuthRemoteDataSource {
  Stream<firebase.User?> get authStateChanges;

  Future<UserModel?> getCurrentUser();
  Future<UserModel> signInWithEmail(String email, String password);
  Future<void> signInWithEmailOnly(String email, String password);
  Future<firebase.UserCredential> createFirebaseAuthUser(
      String email, String password);
  Future<void> signOut();
  Future<void> resetPasswordWithEmail(String email);
  Future<void> createUserDocument(UserModel user);
  Future<UserModel?> getSavedUser();
  Future<void> updateUserFechaNotificada(String uid, DateTime fecha);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final firebase.FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  @override
  Stream<firebase.User?> get authStateChanges {
    print('📡 authStateChanges getter called');
    return firebaseAuth.authStateChanges();
  }

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
  Future<void> signInWithEmailOnly(String email, String password) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user?.uid;

      if (uid == null) {
        throw ServerException('No se pudo obtener el UID del usuario');
      }

      // Actualizar último login en Firestore
      await firestore.collection('users').doc(uid).update({
        'lastLoginDate': FieldValue.serverTimestamp(),
      });
    } on firebase.FirebaseAuthException catch (e) {
      throw ServerException(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw ServerException('Error en login: $e');
    }
  }

  @override
  Future<firebase.UserCredential> createFirebaseAuthUser(
      String email, String password) async {
    print('🔵 DataSource: Inicio createFirebaseAuthUser');
    print('🔵 DataSource: Email: $email');
    print('🔵 DataSource: FirebaseAuth instance: ${firebaseAuth.hashCode}');
    try {
      print('🔵 DataSource: Llamando a createUserWithEmailAndPassword...');
      final credential = await firebaseAuth
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('⏰ DataSource: TIMEOUT en createUserWithEmailAndPassword');
          throw ServerException('Timeout al crear usuario en Firebase Auth');
        },
      );

      print('🔵 DataSource: Credential obtenido');
      print('🔵 DataSource: User UID: ${credential.user?.uid}');
      print('🔵 DataSource: Retornando credential...');

      return credential;
    } on firebase.FirebaseAuthException catch (e) {
      print('❌ DataSource: FirebaseAuthException - ${e.code}: ${e.message}');
      throw ServerException(_getAuthErrorMessage(e.code));
    } catch (e) {
      print('❌ DataSource: Exception genérica - $e');
      throw ServerException('Error inesperado al crear usuario: $e');
    }
  }

  @override
  Future<void> createUserDocument(UserModel user) async {
    print('🔵 DataSource: Inicio createUserDocument para UID: ${user.uid}');
    try {
      final userMap = user.toFirestore();
      print('🔵 DataSource: User map generado: ${userMap.keys}');

      // Convertir el modelo a un mapa de Firestore y guardarlo.
      await firestore.collection('users').doc(user.uid).set(userMap);
      print('🔵 DataSource: Documento creado exitosamente');
    } catch (e) {
      print('❌ DataSource: Error creando documento - $e');
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
        return 'No se ha encontrado ningún usuario con este email.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'network-request-failed':
        return 'Error de red. Comprueba tu conexión.';
      case 'email-already-in-use':
        return 'El email ya está en uso por otra cuenta.';
      case 'invalid-email':
        return 'El formato del email no es válido.';
      case 'weak-password':
        return 'La contraseña es demasiado débil.';
      case 'user-disabled':
        return 'Esta cuenta de usuario ha sido deshabilitada.';
      case 'too-many-requests':
        return 'Demasiados intentos. Inténtalo de nuevo más tarde.';
      case 'operation-not-allowed':
        return 'El inicio de sesión con email y contraseña no está habilitado.';
      default:
        return 'Ha ocurrido un error inesperado de autenticación ($code).';
    }
  }

  @override
  Future<UserModel?> getSavedUser() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) return null;
      final doc = await firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc, isEmailVerified: user.emailVerified);
    } catch (e) {
      throw ServerException('Error al obtener usuario guardado: $e');
    }
  }

  @override
  Future<void> updateUserFechaNotificada(String uid, DateTime fecha) async {
    try {
      await firestore.collection('users').doc(uid).update({
        'fechaNotificada': Timestamp.fromDate(fecha),
      });
    } catch (e) {
      throw ServerException('Error al actualizar fechaNotificada: $e');
    }
  }
}
