// class AuthRepository {
//   final FirebaseAuth _firebaseAuth;
//   final FirebaseFirestore _firestore;

//   // Registro con email
//   Future<UserCredential> registerWithEmail({
//     required String email,
//     required String password,
//     required String firstName,
//     required String lastName,
//     String? phone,
//     required String associationId,
//     required UserRole role,
//   }) async {
//     try {
//       // 1. Crear usuario en Firebase Auth
//       UserCredential credential = await _firebaseAuth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       // 2. Enviar verificación de email
//       await credential.user!.sendEmailVerification();

//       // 3. Crear documento de usuario
//       await _createUserDocument(
//         uid: credential.user!.uid,
//         email: email,
//         firstName: firstName,
//         lastName: lastName,
//         phone: phone,
//         associationId: associationId,
//         role: role,
//         hasSensitiveData: true,
//       );

//       return credential;
//     } catch (e) {
//       throw AuthException(e.toString());
//     }
//   }

//   // Registro sin email (datos no sensibles)
//   Future<UserCredential> registerAnonymous({
//     required String username,
//     required String password,
//     required String securityQuestion,
//     required String securityAnswer,
//     required String associationId,
//     String? displayName,
//   }) async {
//     try {
//       // 1. Generar email temporal único
//       String tempEmail = '${username}_${associationId}@temp.conectasoc.local';

//       // 2. Verificar que username es único en la asociación
//       await _validateUniqueUsername(username, associationId);

//       // 3. Crear usuario en Firebase Auth
//       UserCredential credential = await _firebaseAuth.createUserWithEmailAndPassword(
//         email: tempEmail,
//         password: password,
//       );

//       // 4. Crear documento de usuario
//       await _createUserDocument(
//         uid: credential.user!.uid,
//         username: username,
//         displayName: displayName,
//         securityQuestion: securityQuestion,
//         securityAnswer: securityAnswer,
//         associationId: associationId,
//         role: UserRole.member,
//         hasSensitiveData: false,
//       );

//       return credential;
//     } catch (e) {
//       throw AuthException(e.toString());
//     }
//   }

//   // Login con email
//   Future<UserCredential> signInWithEmail({
//     required String email,
//     required String password,
//     required String associationId,
//   }) async {
//     try {
//       // 1. Autenticar con Firebase Auth
//       UserCredential credential = await _firebaseAuth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       // 2. Verificar que el usuario pertenece a la asociación
//       await _validateUserAssociation(credential.user!.uid, associationId);

//       // 3. Actualizar último login
//       await _updateLastLogin(credential.user!.uid);

//       return credential;
//     } catch (e) {
//       throw AuthException(e.toString());
//     }
//   }

//   // Login sin email (con username)
//   Future<UserCredential> signInWithUsername({
//     required String username,
//     required String password,
//     required String associationId,
//   }) async {
//     try {
//       // 1. Buscar usuario por username y asociación
//       String? tempEmail = await _getTempEmailByUsername(username, associationId);

//       if (tempEmail == null) {
//         throw AuthException('Usuario no encontrado');
//       }

//       // 2. Autenticar con email temporal
//       UserCredential credential = await _firebaseAuth.signInWithEmailAndPassword(
//         email: tempEmail,
//         password: password,
//       );

//       // 3. Actualizar último login
//       await _updateLastLogin(credential.user!.uid);

//       return credential;
//     } catch (e) {
//       throw AuthException(e.toString());
//     }
//   }

//   // Recuperación de contraseña con email
//   Future<void> resetPasswordWithEmail(String email) async {
//     try {
//       await _firebaseAuth.sendPasswordResetEmail(email: email);
//     } catch (e) {
//       throw AuthException(e.toString());
//     }
//   }

//   // Recuperación de contraseña sin email (con pregunta de seguridad)
//   Future<bool> resetPasswordWithSecurityQuestion({
//     required String username,
//     required String associationId,
//     required String securityAnswer,
//     required String newPassword,
//   }) async {
//     try {
//       // 1. Buscar usuario y verificar respuesta de seguridad
//       DocumentSnapshot userDoc = await _getUserByUsername(username, associationId);

//       if (!userDoc.exists) {
//         throw AuthException('Usuario no encontrado');
//       }

//       Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
//       String storedHash = userData['securityAnswerHash'];

//       // 2. Verificar respuesta de seguridad
//       if (!_verifySecurityAnswer(securityAnswer, storedHash)) {
//         throw AuthException('Respuesta de seguridad incorrecta');
//       }

//       // 3. Actualizar contraseña usando Admin SDK (Cloud Function)
//       await _callCloudFunction('updateUserPassword', {
//         'uid': userDoc.id,
//         'newPassword': newPassword,
//       });

//       return true;
//     } catch (e) {
//       throw AuthException(e.toString());
//     }
//   }
// }
