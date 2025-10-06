import 'package:equatable/equatable.dart';
import 'package:conectasoc/features/auth/domain/entities/entities.dart' as auth;

/// Entidad que representa los datos editables del perfil de un usuario.
/// Es un subconjunto de la entidad principal `auth.UserEntity`.
class ProfileEntity extends Equatable {
  final String uid;
  final String name;
  final String lastname;
  final String email; // Generalmente no editable, pero se muestra.
  final String? phone;
  final String language;
  final String? photoUrl;

  const ProfileEntity({
    required this.uid,
    required this.name,
    required this.lastname,
    required this.email,
    this.phone,
    required this.language,
    this.photoUrl,
  });

  ProfileEntity copyWith({
    String? uid,
    String? name,
    String? lastname,
    String? email,
    String? phone,
    String? language,
    String? photoUrl,
  }) {
    return ProfileEntity(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      lastname: lastname ?? this.lastname,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      language: language ?? this.language,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  /// Convierte esta entidad de perfil a la entidad de autenticación.
  /// NOTA: Esto es una simplificación. No puede reconstruir el `UserEntity` completo
  /// (con roles, membresías, etc.), solo los campos que comparte.
  /// Se usa para actualizar el AuthBloc después de un cambio de perfil.
  auth.UserEntity toAuthUser(auth.UserEntity originalAuthUser) {
    return originalAuthUser.copyWith(
      firstName: name,
      lastName: lastname,
      phone: phone,
      language: language,
      avatarUrl: photoUrl,
      // Se mantiene el resto de la información del usuario original.
      // uid, email, status, memberships, etc. no se modifican aquí.
    );
  }

  @override
  List<Object?> get props =>
      [uid, name, lastname, email, phone, language, photoUrl];
}
