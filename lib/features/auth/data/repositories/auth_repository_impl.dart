import 'package:conectasoc/core/services/local_storage_service.dart';
import 'package:conectasoc/features/auth/data/models/association_model.dart';
import 'package:conectasoc/features/auth/data/models/user_model.dart';
import 'package:conectasoc/features/auth/domain/entities/association_entity.dart';
import 'package:conectasoc/features/auth/domain/entities/user_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final LocalStorageService _localStorage;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    required LocalStorageService localStorage,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _localStorage = localStorage;

  // Stream del estado de autenticación
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Usuario actual
  User? get currentUser => _firebaseAuth.currentUser;

  // ============================================
  // USUARIO LOCAL (Tipo 1)
  // ============================================

  /// Guardar usuario local (solo lectura)
  Future<bool> saveLocalUser({
    required String displayName,
    required String associationId,
  }) async {
    try {
      final localUser = LocalUserEntity(
        displayName: displayName,
        associationId: associationId,
      );

      await _localStorage.saveLocalUser(localUser);
      await _localStorage.saveLastAssociationId(associationId);
      return true;
    } catch (e) {
      throw Exception('Error guardando usuario local: $e');
    }
  }

  /// Obtener usuario local guardado
  LocalUserEntity? getLocalUser() {
    return _localStorage.getLocalUser();
  }

  /// Verificar si hay usuario local
  bool hasLocalUser() {
    return _localStorage.hasLocalUser();
  }

  /// Eliminar usuario local (al hacer upgrade)
  Future<void> deleteLocalUser() async {
    await _localStorage.deleteLocalUser();
  }

  // ============================================
  // VERIFICACIÓN DE PRIMER USUARIO
  // ============================================

  /// Verifica si es el primer usuario del sistema
  /// Si es el primero, será SuperAdmin automáticamente
  Future<bool> isFirstUser() async {
    try {
      final usersSnapshot = await _firestore.collection('users').limit(1).get();

      return usersSnapshot.docs.isEmpty;
    } catch (e) {
      throw Exception('Error verificando primer usuario: $e');
    }
  }

  // ============================================
  // GESTIÓN DE ASOCIACIONES
  // ============================================

  /// Obtener todas las asociaciones (solo para SuperAdmin)
  Future<List<AssociationEntity>> getAllAssociations() async {
    try {
      final snapshot = await _firestore
          .collection('associations')
          .where('dateDeleted', isNull: true)
          .orderBy('shortName')
          .get();

      return snapshot.docs
          .map((doc) => AssociationModel.fromFirestore(doc).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error obteniendo asociaciones: $e');
    }
  }

  /// Verificar si existen asociaciones
  Future<bool> hasAssociations() async {
    try {
      final snapshot =
          await _firestore.collection('associations').limit(1).get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Error verificando asociaciones: $e');
    }
  }

  /// Crear nueva asociación
  Future<AssociationEntity> createNewAssociation({
    required String shortName,
    required String longName,
    required String email,
    required String contactName,
    required String phone,
    String? description,
  }) async {
    try {
      // Verificar que el nombre corto no exista
      final existing = await _firestore
          .collection('associations')
          .where('shortName', isEqualTo: shortName)
          .get();

      if (existing.docs.isNotEmpty) {
        throw Exception('Ya existe una asociación con ese nombre corto');
      }

      final now = DateTime.now();
      final docRef = _firestore.collection('associations').doc();

      final association = AssociationModel(
        id: docRef.id,
        shortName: shortName,
        longName: longName,
        email: email,
        contactName: contactName,
        phone: phone,
        description: description,
        dateCreated: now,
        dateUpdated: now,
      );

      await docRef.set(association.toFirestore());

      return association.toEntity();
    } catch (e) {
      throw Exception('Error creando asociación: $e');
    }
  }

  // ============================================
  // REGISTRO CON EMAIL (Usuario Tipo 2)
  // ============================================

  Future<UserEntity> registerWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    String? associationId,
    bool createAssociation = false,
    String? newAssociationName,
    String? newAssociationLongName,
    String? newAssociationEmail,
    String? newAssociationContactName,
    String? newAssociationPhone,
  }) async {
    try {
      // 1. Verificar si es el primer usuario
      final isFirst = await isFirstUser();

      UserRole role;
      String finalAssociationId;

      if (isFirst) {
        // Primer usuario = SuperAdmin sin asociación específica
        role = UserRole.superadmin;
        finalAssociationId = '';
      } else if (createAssociation) {
        // Crear nueva asociación y ser Admin
        if (newAssociationName == null || newAssociationLongName == null) {
          throw Exception('Debe proporcionar datos de la nueva asociación');
        }

        final newAssociation = await createNewAssociation(
          shortName: newAssociationName,
          longName: newAssociationLongName,
          email: newAssociationEmail ?? email,
          contactName: newAssociationContactName ?? '$firstName $lastName',
          phone: newAssociationPhone ?? phone ?? '',
        );

        role = UserRole.admin;
        finalAssociationId = newAssociation.id;
      } else {
        // Unirse a asociación existente como Member
        if (associationId == null || associationId.isEmpty) {
          throw Exception('Debe seleccionar una asociación');
        }

        role = UserRole.member;
        finalAssociationId = associationId;
      }

      // 2. Crear usuario en Firebase Auth
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 3. Enviar verificación de email
      await credential.user!.sendEmailVerification();

      // 4. Crear documento de usuario en Firestore
      final now = DateTime.now();
      final userModel = UserModel(
        uid: credential.user!.uid,
        associationId: finalAssociationId,
        role: role,
        status: UserStatus.active,
        language: 'es',
        dateCreated: now,
        dateUpdated: now,
        email: email,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        authProvider: 'password',
      );

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(userModel.toFirestore());

      // 5. Si había usuario local, eliminarlo (upgrade)
      if (hasLocalUser()) {
        await deleteLocalUser();
      }

      return userModel.toEntity();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Error en registro: $e');
    }
  }

  // ============================================
  // UPGRADE: Usuario Local → Registrado
  // ============================================

  /// Actualizar de usuario local a registrado (mantiene asociación)
  Future<UserEntity> upgradeLocalToRegistered({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    try {
      // Obtener usuario local actual
      final localUser = getLocalUser();
      if (localUser == null) {
        throw Exception('No hay usuario local para actualizar');
      }

      // Registrar manteniendo la asociación del usuario local
      return await registerWithEmail(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        associationId: localUser.associationId,
        createAssociation: false,
      );
    } catch (e) {
      throw Exception('Error actualizando usuario: $e');
    }
  }

  // ============================================
  // LOGIN
  // ============================================

  /// Login con email y password
  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
    String? associationId,
  }) async {
    try {
      // 1. Autenticar con Firebase Auth
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Obtener datos del usuario
      final userDoc =
          await _firestore.collection('users').doc(credential.user!.uid).get();

      if (!userDoc.exists) {
        await _firebaseAuth.signOut();
        throw Exception('Usuario no encontrado en la base de datos');
      }

      final user = UserModel.fromFirestore(userDoc).toEntity();

      // 3. Verificar que el usuario esté activo
      if (user.status != UserStatus.active) {
        await _firebaseAuth.signOut();
        throw Exception('Usuario inactivo o suspendido');
      }

      // 4. Verificar asociación si no es SuperAdmin
      if (!user.isSuperAdmin) {
        if (associationId != null && user.associationId != associationId) {
          await _firebaseAuth.signOut();
          throw Exception('Usuario no pertenece a esta asociación');
        }
      }

      // 5. Actualizar último login
      await _updateLastLogin(credential.user!.uid);

      // 6. Guardar última asociación
      if (user.associationId.isNotEmpty) {
        await _localStorage.saveLastAssociationId(user.associationId);
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Error en login: $e');
    }
  }

  // ============================================
  // RECUPERACIÓN DE CONTRASEÑA
  // ============================================

  /// Recuperar contraseña con email
  Future<void> resetPasswordWithEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // ============================================
  // OBTENER USUARIO
  // ============================================

  Future<UserEntity?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) return null;

      return UserModel.fromFirestore(doc).toEntity();
    } catch (e) {
      throw Exception('Error obteniendo perfil: $e');
    }
  }

  // ============================================
  // LOGOUT
  // ============================================

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Error cerrando sesión: $e');
    }
  }

  // ============================================
  // MÉTODOS AUXILIARES PRIVADOS
  // ============================================

  Future<void> _updateLastLogin(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'lastLoginDate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error actualizando último login: $e');
    }
  }

  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return Exception('La contraseña es demasiado débil');
      case 'email-already-in-use':
        return Exception('El email ya está en uso');
      case 'user-not-found':
        return Exception('Usuario no encontrado');
      case 'wrong-password':
        return Exception('Contraseña incorrecta');
      case 'invalid-email':
        return Exception('Email inválido');
      case 'user-disabled':
        return Exception('Usuario deshabilitado');
      case 'too-many-requests':
        return Exception('Demasiados intentos. Intente más tarde');
      default:
        return Exception('Error de autenticación: ${e.message}');
    }
  }
}
